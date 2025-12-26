import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:permission_handler/permission_handler.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  String currentVersion = "";
  String buildNumber = "";
  String latestVersion = "";
  String apkUrl = "";

  bool loading = true;
  bool updateAvailable = false;
  bool downloading = false;

  @override
  void initState() {
    super.initState();
    checkForUpdate();
  }

  /// -------------------------------
  /// CHECK FOR UPDATE FROM GITHUB
  /// -------------------------------
  Future<void> checkForUpdate() async {
    try {
      final info = await PackageInfo.fromPlatform();
      currentVersion = info.version;
      buildNumber = info.buildNumber;

      final response = await http.get(
        Uri.parse(
          "https://api.github.com/repos/kolekarmahadev20/Scrap-Management-App/releases/latest",
        ),
      );

      if (response.statusCode != 200) {
        loading = false;
        setState(() {});
        return;
      }

      final data = jsonDecode(response.body);

      latestVersion = data['tag_name']
          .toString()
          .replaceFirst('v', '')
          .split('+')
          .first;

      if (data['assets'] == null || data['assets'].isEmpty) {
        loading = false;
        setState(() {});
        return;
      }

      apkUrl = data['assets'][0]['browser_download_url'];
      updateAvailable = _isNewerVersion(latestVersion, currentVersion);

      loading = false;
      setState(() {});
    } catch (e) {
      loading = false;
      setState(() {});
    }
  }

  /// -------------------------------
  /// VERSION COMPARISON
  /// -------------------------------
  bool _isNewerVersion(String latest, String current) {
    final latestParts =
    latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final currentParts =
    current.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLength =
    latestParts.length > currentParts.length ? latestParts.length : currentParts.length;

    for (int i = 0; i < maxLength; i++) {
      final l = i < latestParts.length ? latestParts[i] : 0;
      final c = i < currentParts.length ? currentParts[i] : 0;

      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }

  /// -------------------------------
  /// DOWNLOAD & INSTALL APK
  /// -------------------------------
  Future<void> downloadAndInstall() async {
    setState(() => downloading = true);

    try {
      // 1️⃣ Storage permission
      if (!await Permission.storage.request().isGranted) {
        openAppSettings();
        return;
      }

      // 2️⃣ Install unknown apps permission
      if (!await Permission.requestInstallPackages.isGranted) {
        await Permission.requestInstallPackages.request();
        if (!await Permission.requestInstallPackages.isGranted) {
          openAppSettings();
          return;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Downloading update...")),
      );

      final path = await _downloadApk();

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // 3️⃣ Open installer
      await OpenFile.open(path);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    }

    setState(() => downloading = false);
  }

  Future<String> _downloadApk() async {
    final directory = await getExternalStorageDirectory();

    if (directory == null) {
      throw Exception("Storage not available");
    }

    final filePath = "${directory.path}/scrapapp_update.apk";

    final response = await http.get(Uri.parse(apkUrl));

    if (response.statusCode != 200) {
      throw Exception("Failed to download APK");
    }

    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    return filePath;
  }



  /// -------------------------------
  /// UI
  /// -------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("App Update"),
        backgroundColor: Colors.deepPurple,
      ),
      body: loading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.deepPurple),
            SizedBox(height: 20),
            Text(
              "Checking for updates...",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      )
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 25),
                  child: Column(
                    children: [
                      const Text("Current Version"),
                      const SizedBox(height: 5),
                      Text(
                        "$currentVersion ($buildNumber)",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text("Latest Version"),
                      const SizedBox(height: 5),
                      Text(
                        latestVersion,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              updateAvailable
                  ? ElevatedButton.icon(
                onPressed:
                downloading ? null : downloadAndInstall,
                icon: const Icon(Icons.download, size: 28),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    downloading
                        ? "Downloading..."
                        : "Download & Install Update",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              )
                  : Column(
                children: const [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 50,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Your app is up to date!",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

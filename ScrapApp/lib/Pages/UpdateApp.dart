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

  /// --------------------------------
  /// CHECK UPDATE
  /// --------------------------------
  Future<void> checkForUpdate() async {
    final info = await PackageInfo.fromPlatform();
    currentVersion = info.version;

    final res = await http.get(Uri.parse(
      "https://api.github.com/repos/kolekarmahadev20/Scrap-Management-App/releases/latest",
    ));

    final data = jsonDecode(res.body);

    latestVersion = data["tag_name"].replaceAll("v", "").split("+").first;
    apkUrl = data["assets"][0]["browser_download_url"];

    updateAvailable = _isNewer(latestVersion, currentVersion);

    setState(() => loading = false);
  }

  bool _isNewer(String latest, String current) {
    final l = latest.split(".").map(int.parse).toList();
    final c = current.split(".").map(int.parse).toList();
    for (int i = 0; i < 3; i++) {
      if (l[i] > c[i]) return true;
      if (l[i] < c[i]) return false;
    }
    return false;
  }

  /// --------------------------------
  /// DOWNLOAD APK
  /// --------------------------------
  Future<String> _downloadApk() async {
    final dir = await getExternalStorageDirectory();
    final file = File("${dir!.path}/update.apk");

    final res = await http.get(Uri.parse(apkUrl));
    await file.writeAsBytes(res.bodyBytes);

    return file.path;
  }

  /// --------------------------------
  /// INSTALL APK
  /// --------------------------------
  Future<void> _installApk(String path) async {
    final intent = AndroidIntent(
      action: 'action_view',
      data: Uri.file(path).toString(),
      type: 'application/vnd.android.package-archive',
      flags: [1 << 0, 1 << 2],
    );

    await intent.launch();
  }

  /// --------------------------------
  /// MAIN UPDATE FLOW
  /// --------------------------------
  Future<void> downloadAndInstall() async {
    setState(() => downloading = true);

    // Storage permission
    if (!await Permission.storage.request().isGranted) {
      setState(() => downloading = false);
      return;
    }

    // Install packages permission (Android 8+)
    if (!await Permission.requestInstallPackages.request().isGranted) {
      openAppSettings();
      setState(() => downloading = false);
      return;
    }

    final path = await _downloadApk();

    await OpenFile.open(path);       // works on most phones
    await _installApk(path);        // fallback for Samsung / MIUI

    setState(() => downloading = false);
  }

  /// --------------------------------
  /// UI
  /// --------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("App Update")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Current: $currentVersion"),
            Text("Latest: $latestVersion"),
            const SizedBox(height: 20),
            updateAvailable
                ? ElevatedButton(
              onPressed: downloading ? null : downloadAndInstall,
              child: Text(downloading ? "Downloading..." : "Update App"),
            )
                : const Text("App is up to date"),
          ],
        ),
      ),
    );
  }
}

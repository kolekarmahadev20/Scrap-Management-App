import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdatePage extends StatefulWidget {
  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  String currentVersion = "";
  String latestVersion = "";
  String apkUrl = "";
  bool loading = true;
  bool updateAvailable = false;

  @override
  void initState() {
    super.initState();
    checkForUpdate();
  }

  Future<void> checkForUpdate() async {
    final info = await PackageInfo.fromPlatform();
    currentVersion = info.version;

    final url = Uri.parse(
        "https://api.github.com/repos/kolekarmahadev20/Scrap-Management-App/releases/latest");

    final response = await http.get(url);
    if (response.statusCode != 200) {
      setState(() => loading = false);
      return;
    }

    final data = jsonDecode(response.body);
    latestVersion = data['tag_name'];
    apkUrl = data['assets'][0]['browser_download_url'];

    updateAvailable = latestVersion != currentVersion;

    setState(() => loading = false);
  }

  Future<String> downloadApk() async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/update.apk';

    final res = await http.get(Uri.parse(apkUrl));
    final file = File(filePath);

    await file.writeAsBytes(res.bodyBytes);
    return filePath;
  }

  Future<void> downloadAndInstall() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Downloading update...")),
    );

    final path = await downloadApk();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Download complete. Installing...")),
    );

    await OpenFilex.open(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("App Update")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Current Version: $currentVersion",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Latest Version: $latestVersion",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 30),

            updateAvailable
                ? ElevatedButton.icon(
              onPressed: downloadAndInstall,
              icon: Icon(Icons.download),
              label: Text("Download & Install Update"),
            )
                : Text(
              "Your app is up to date!",
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

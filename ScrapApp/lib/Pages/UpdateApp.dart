import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
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
  bool downloading = false; // ✅ CHANGED

  @override
  void initState() {
    super.initState();
    checkForUpdate();
  }

  Future<void> checkForUpdate() async {
    final info = await PackageInfo.fromPlatform();

    // ✅ CHANGED: normalize current version
    currentVersion = "${info.version}+${info.buildNumber}";

    final url = Uri.parse(
      "https://api.github.com/repos/kolekarmahadev20/Scrap-Management-App/releases/latest",
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      setState(() => loading = false);
      return;
    }

    final data = jsonDecode(response.body);

    // ✅ CHANGED: normalize latest version
    latestVersion = data['tag_name'].toString().replaceFirst('v', '');

    // ✅ Safety check
    if (data['assets'] == null || data['assets'].isEmpty) {
      setState(() => loading = false);
      return;
    }

    apkUrl = data['assets'][0]['browser_download_url'];

    // ✅ CHANGED: correct comparison
    updateAvailable = latestVersion.trim() != currentVersion.trim();

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
    setState(() => downloading = true); // ✅ CHANGED

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Downloading update..."),
        duration: Duration(days: 1),
      ),
    );

    final path = await downloadApk();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Download complete. Installing..."),
        duration: Duration(days: 1),
      ),
    );

    await OpenFile.open(path);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Update installed. Please reopen the app to use the latest version.",
        ),
        duration: Duration(seconds: 5),
      ),
    );

    setState(() => downloading = false); // ✅ CHANGED
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("App Update"),
        backgroundColor: Colors.deepPurple,
      ),
      body: loading
          ? Center(
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20, vertical: 25),
                    child: Column(
                      children: [
                        Text("Current Version"),
                        SizedBox(height: 5),
                        Text(
                          currentVersion,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text("Latest Version"),
                        SizedBox(height: 5),
                        Text(
                          latestVersion,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40),
                updateAvailable
                    ? ElevatedButton.icon(
                  onPressed:
                  downloading ? null : downloadAndInstall,
                  icon: Icon(Icons.download, size: 28),
                  label: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      downloading
                          ? "Downloading..."
                          : "Download & Install Update",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
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
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green, size: 50),
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
      ),
    );
  }
}

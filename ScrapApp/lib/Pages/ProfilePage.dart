import 'package:flutter/material.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';

class ProfilePage extends StatelessWidget {
  final String name = "John Doe";
  final String bio = "Software Engineer based in San Francisco.";
  final String contact = "Contact";
  final String email = "Email";
  final String otherDetails = "Other Details";

  final Icon contactIcon = Icon(Icons.contacts, color: Colors.blue.shade900, size: 40);
  final Icon emailIcon = Icon(Icons.email_outlined, color: Colors.blue.shade900, size: 40);
  final Icon otherDetailsIcon = Icon(Icons.devices_other_sharp, color: Colors.blue.shade900, size: 40);

  Widget buildProfileListTile(String text, Icon icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: SizedBox(
        height: 100,
        child: Card(
          color: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            leading: icon,
            title: Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            subtitle: Text("XYZ", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: CustomAppBar(),
      body: Container(
        height: double.infinity,
        width : double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo[300]!, Colors.indigo.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.black12,
                  child: Icon(
                    Icons.account_circle,
                    size: 120,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo[800]),
                ),
                SizedBox(height: 5),
                Text(
                  bio,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 120),
                buildProfileListTile(contact, contactIcon),
                buildProfileListTile(email, emailIcon),
                buildProfileListTile(otherDetails, otherDetailsIcon),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

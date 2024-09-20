import 'package:flutter/material.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Pages/StartPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  String name = '';

   String contact = '';

   String email = '';

   String address = '';

   String empCode = '';

   bool isLoggedIn = false;

  getCredentialDetails() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn')!;
      name = prefs.getString('name') ?? 'N/A';
      contact = prefs.getString('contact') ?? 'N/A';
      email = prefs.getString('email') ?? 'N/A';
      address = prefs.getString('address') ?? 'N/A';
      empCode = prefs.getString('empCode') ?? 'N/A';
    });
    if(isLoggedIn != true){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StartPage()),
      );
    }

  }




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCredentialDetails();
  }

  final Icon nameIcon =
      Icon(Icons.person, color: Colors.blue.shade900, size: 40);

  final Icon contactIcon =
      Icon(Icons.contacts, color: Colors.blue.shade900, size: 40);

  final Icon emailIcon =
      Icon(Icons.email_outlined, color: Colors.blue.shade900, size: 40);

  final Icon empCodeIcon =
      Icon(Icons.person, color: Colors.blue.shade900, size: 40);

  final Icon addressIcon =
      Icon(Icons.location_pin, color: Colors.blue.shade900, size: 40);

  Widget buildProfileListTile(String text, String detail, Icon icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: SizedBox(
        child: Card(
          color: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.indigo[800]!)),
          child: ListTile(
            leading: icon,
            title: Text(text,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            subtitle: Text(detail,
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
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
        width: double.infinity,
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
                Center(
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin: 1.0, end: 24),
                    duration: Duration(seconds: 1),
                    builder: (BuildContext context, double value, child) {
                      return Text(
                        'नमस्ते ${name} जी',
                        style: TextStyle(
                            fontSize: value,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo[800]),
                      );
                    },
                  ),
                ),
                buildProfileListTile("Name", name, nameIcon),
                buildProfileListTile("Contact", contact, contactIcon),
                buildProfileListTile("Email", email, emailIcon),
                buildProfileListTile("Employee Code", empCode, empCodeIcon),
                buildProfileListTile("Address", address, addressIcon),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

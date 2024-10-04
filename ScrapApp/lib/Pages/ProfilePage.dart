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


  String? username ;

  String? password ;

  String name = '';

   String contact = '';

   String email = '';

   String address = '';

   String empCode = '';

   bool isLoggedIn = false;


  checkLogin()async{
    final login = await SharedPreferences.getInstance();
    username = await login.getString("username");
    password = await login.getString("password");
    print(username);
  }

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
    checkLogin();
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

  // Widget buildProfileListTile(String text, String detail, Icon icon) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  //     child: SizedBox(
  //       child: Card(
  //         color: Colors.white,
  //         elevation: 5,
  //         shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(15),
  //             side: BorderSide(color: Colors.indigo[800]!)),
  //         child: ListTile(
  //           leading: icon,
  //           title: Text(text,
  //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
  //           subtitle: Text(detail,
  //               style: TextStyle(fontSize: 16, color: Colors.grey[600])),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: CustomAppBar(),
      backgroundColor: Color(0xFFF5FFFA), // Mint Cream Background Color
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Picture Section
              Container(
                height: 230,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF87CEEB), Color(0xFFfadced)], // Primary Blue and Accent Color
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/welcome_image.gif'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      name,
                      style: TextStyle(
                        color: Color(0xFF2F4F4F), // Dark Slate Gray Text Color
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      email,
                      style: TextStyle(
                        color: Color(0xFF2F4F4F), // Dark Slate Gray Text Color
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
              // User Details
              _buildProfileItem(Icons.person, 'Name', name),
              _buildProfileItem(Icons.email, 'Email', email),
              _buildProfileItem(Icons.phone, 'Phone',contact ),
              _buildProfileItem(Icons.home, 'Address',address ),
              _buildProfileItem(Icons.code, 'Employee Code', empCode),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget for Profile Info Items
  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF87CEEB)), // Primary Blue Icon Color
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2F4F4F), // Dark Slate Gray Text Color
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
  String? username;
  String? password;
  String name = '';
  String contact = '';
  String email = '';
  String address = '';
  String empCode = '';
  bool isLoggedIn = false;

  checkLogin() async {
    final login = await SharedPreferences.getInstance();
    username = await login.getString("username");
    password = await login.getString("password");
    print(username);
  }

  getCredentialDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn')!;
      name = prefs.getString('name') ?? 'N/A';
      contact = prefs.getString('contact') ?? 'N/A';
      email = prefs.getString('email') ?? 'N/A';
      address = prefs.getString('address') ?? 'N/A';
      empCode = prefs.getString('empCode') ?? 'N/A';
    });
    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StartPage()),
      );
    }
  }

  @override
  void initState() {
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

  Widget buildCard(String text, Icon icon, String path) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(16),
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color(0xFF2F4F4F), width: 2),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                path,
                fit: BoxFit.fill,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Picture Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blueGrey.shade400,
                ),
                child: Stack(children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          21), // Ensure the image also respects the border radius
                      child: Image.asset(
                        'assets/images/themeimg1.jpeg',
                        fit: BoxFit
                            .cover, // Use BoxFit.cover to ensure the image covers the entire area
                        width: double
                            .infinity, // Ensure the image takes the full width of the container
                        height: 250, // Set a fixed height or adjust as needed
                        colorBlendMode: BlendMode.darken,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(
                              'assets/images/hello.gif'), // Replace with user's image
                          backgroundColor: Colors.blueGrey.shade100,
                        ),
                        SizedBox(height: 10),
                        Text(
                          name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
            // User Details Section (Cards)
            Row(
              children: [
                Expanded(
                    child:
                        buildCard(name, nameIcon, 'assets/images/user2.jpg')),
                SizedBox(width: 8),
                Expanded(
                    child: buildCard(
                        contact, contactIcon, 'assets/images/contact3.jpeg')),
              ],
            ),
            //Additional Info
            buildListTile('Email', email, 'assets/images/email2.jpeg'),
            buildListTile('Address', address, 'assets/images/location.jpeg'),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      child: Text("Punch In", style: TextStyle(color: Colors.white)),
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        shadowColor: Colors.greenAccent[700],
                      ).copyWith(
                        backgroundColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.greenAccent[400];
                          }
                          return Colors.greenAccent[200];
                        }),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      child: Text("Punch Out", style: TextStyle(color: Colors.white)),
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        shadowColor: Colors.redAccent[700],
                      ).copyWith(
                        backgroundColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.redAccent[400];
                          }
                          return Colors.redAccent[200];
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListTile(String text, String value, String path) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFF6482AD), width: 2), // Input border
          borderRadius: BorderRadius.circular(12), // Rounded corners
          color: Colors.white, // Background color
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(8), // Padding inside ListTile
          title: Row(
            children: [
              // Icon
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: ClipOval(
                  // Clip the image to ensure it fits within the rounded container
                  child: Image.asset(
                    path,
                    fit: BoxFit.cover, // Change to BoxFit.cover or BoxFit.contain
                    width: 50, // Ensure the width matches the container's width
                    height: 50, // Ensure the height matches the container's height
                  ),
                ),
              ),
              // Vertical Divider
              Container(
                width: 1, // Width of the vertical line
                height: 60, // Height of the vertical line
                color: Colors.green.shade900, // Color of the vertical line
                margin: EdgeInsets.symmetric(
                    horizontal: 16), // Space around the vertical line
              ),
              // Text Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        color: Color(0xFF2F4F4F),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4), // Space between title and subtitle
                    Text(
                      value,
                      style: TextStyle(
                        color: Color(0xFF2F4F4F),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

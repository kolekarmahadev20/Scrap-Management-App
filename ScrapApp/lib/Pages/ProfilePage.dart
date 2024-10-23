import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Pages/StartPage.dart';
import 'package:scrapapp/URL_CONSTANT.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'attendance.dart';


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
  bool isPunchedIn = false;
  bool isPunchedOut = false;
  DateTime? punchTime;
  DateTime? punchOutTime;
  String? attendanceType ;
  int _currentIndex = 0; // Current tab index



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


  @override
  void initState() {
    super.initState();
    getCredentialDetails();
    checkLogin();
    fetchPunchTimeFromDatabase();
    fetchLogoutPunchTimeFromDatabase();
  }

  checkLogin() async {
    final login = await SharedPreferences.getInstance();
    username = login.getString("username");
    password = login.getString("password");
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

  void sendPunchTimeToDatabase(String status) async{
    try {
      await checkLogin();
      final url = Uri.parse('${URL}set_user_attendance');
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id':username,
          'user_pass':password,
          'status' : status,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          var data = jsonDecode(response.body);
          Fluttertoast.showToast(msg: data['msg']);
          print("status : $status");
          if(status == 'logged in') {
            fetchPunchTimeFromDatabase();
          }else{
            fetchLogoutPunchTimeFromDatabase();
          }
        });
      } else {
        Fluttertoast.showToast(msg: 'Unable to mark punch time');
      }
    }catch(e){
      print('Server Exception : $e');
    }finally{

    }
  }

  void fetchPunchTimeFromDatabase() async{
    try {
      await checkLogin();
      final url = Uri.parse('${URL}fetch_attendance_time');
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id':username,
          'user_pass':password,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          var data = jsonDecode(response.body);
          punchTime = DateTime.parse(data['login_time']);
          print("PunchIn Time : $punchTime");
          enablePunching("logged in");
        });
      } else {
        Fluttertoast.showToast(msg: 'Unable to fetch punch time');
      }
    }catch(e){
      print('Server Exception : $e');
    }finally{

    }
  }

  void fetchLogoutPunchTimeFromDatabase() async{
    try {
      await checkLogin();
      final url = Uri.parse('${URL}fetch_attendance_Outime');
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id':username,
          'user_pass':password,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          var data = jsonDecode(response.body);
          punchOutTime = DateTime.parse(data['logout_time']);
          enablePunching("logged out");
        });
      } else {
        Fluttertoast.showToast(msg: 'Unable to fetch punch time');
      }
    }catch(e){
      print('Server Exception : $e');
    }finally{

    }
  }

  enablePunching(String status) {
    DateTime currentDateTime = DateTime.now();
    String currentformattedDate = DateFormat('yyyy-MM-dd').format(currentDateTime);
    print('Current Time : $currentformattedDate');
    if (status == 'logged in'){
      String punchFormattedDate = DateFormat('yyyy-MM-dd').format(punchTime!);
      print('punchIn Time : $punchFormattedDate');
      if (currentformattedDate != punchFormattedDate) {
        setState(() {
          isPunchedIn = false;
        });
      }
      else {
        setState(() {
          isPunchedIn = true;
        });
      }
  }
    if(status == 'logged out') {
      String punchOutFormattedDate = DateFormat('yyyy-MM-dd').format(punchOutTime!);
      print('punchOut Time : $punchOutFormattedDate');
      if(currentformattedDate != punchOutFormattedDate){
        setState(() {
          isPunchedOut = false;
        });
      }
      else{
        setState(() {
          isPunchedOut = true;
        });
      }
    }





  }

  void _onItemTapped(int index) {
    setState(() {
      if(isPunchedIn){
        _currentIndex = index; // Update current index
      }else{
        Fluttertoast.showToast(msg: 'Please mark attendance first.');
      }

      if(_currentIndex == 1){
        if (punchTime != null && punchOutTime != null) {
          Navigator.push(
            context,
            SlidePageRoute(
              page: AttendanceMarkedPage(punchTime: punchTime!, punchOutTime: punchOutTime!),
            ),
          ).then((value) {
            _currentIndex = 0;
            _onItemTapped(_currentIndex);
          });
        } else if (punchTime != null) {
          Navigator.push(
            context,
            SlidePageRoute(
              page: AttendanceMarkedPage(punchTime: punchTime!, punchOutTime: null),
            ),
          ).then((value) {
            _currentIndex = 0;
            _onItemTapped(_currentIndex);
          });
        } else if (punchOutTime != null) {
          Navigator.push(
            context,
            SlidePageRoute(
              page: AttendanceMarkedPage(punchTime: null, punchOutTime: punchOutTime!),
            ),
          ).then((value) {
            _currentIndex = 0;
            _onItemTapped(_currentIndex);
          });
        } else {
          Fluttertoast.showToast(msg: 'Please mark attendance first.');
        }
      }
    });
  }

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
    return StatefulBuilder(builder: (BuildContext context , StateSetter setState) {
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
                            21),
                        // Ensure the image also respects the border radius
                        child: Image.asset(
                          'assets/images/themeimg1.jpeg',
                          fit: BoxFit
                              .cover,
                          // Use BoxFit.cover to ensure the image covers the entire area
                          width: double
                              .infinity,
                          // Ensure the image takes the full width of the container
                          height: 250,
                          // Set a fixed height or adjust as needed
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
                                'assets/images/hello.gif'),
                            // Replace with user's image
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
                      child: buildCard(
                          name, nameIcon, 'assets/images/user2.jpg')),
                  SizedBox(width: 8),
                  Expanded(
                      child: buildCard(
                          contact, contactIcon, 'assets/images/contact3.jpeg')),
                ],
              ),
              //Additional Info
              buildListTile('Email', email, 'assets/images/email2.jpeg'),
              buildListTile('Address', address, 'assets/images/location.jpeg'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.login_rounded, color: Colors.white),
                        label: Text("Punch In", style: TextStyle(color: Colors.white)),
                        onPressed: isPunchedIn
                            ? () {
                          Fluttertoast.showToast(msg: 'Your attendance marked for today');
                        }
                            : () {
                          sendPunchTimeToDatabase("logged in");
                          print('isPunchedIn :$isPunchedIn');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPunchedIn
                              ? Colors.grey[400]
                              : Colors.greenAccent[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                          padding: EdgeInsets.symmetric(vertical: 14.0),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.logout_rounded, color: Colors.white),
                        label: Text("Punch Out", style: TextStyle(color: Colors.white)),
                        onPressed: isPunchedOut
                          ? () {
                          Fluttertoast.showToast(msg: 'Your attendance marked for today');
                          }
                          : () {
                            if(isPunchedIn) {
                              sendPunchTimeToDatabase("logged out");
                            }else{
                              Fluttertoast.showToast(msg: 'Please punch in first');
                            }
                          },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPunchedOut
                              ? Colors.grey[400]
                              :Colors.redAccent[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                          padding: EdgeInsets.symmetric(vertical: 14.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        //   floatingActionButton: FloatingActionButton(
        //     onPressed: () {
        //       if (punchTime != null && punchOutTime != null) {
        //         Navigator.push(
        //           context,
        //           SlidePageRoute(
        //             page: AttendanceMarkedPage(punchTime: punchTime!, punchOutTime: punchOutTime!),
        //           ),
        //         );
        //       } else if (punchTime != null) {
        //         Navigator.push(
        //           context,
        //           SlidePageRoute(
        //             page: AttendanceMarkedPage(punchTime: punchTime!, punchOutTime: null),
        //           ),
        //         );
        //       } else if (punchOutTime != null) {
        //         Navigator.push(
        //           context,
        //           SlidePageRoute(
        //             page: AttendanceMarkedPage(punchTime: null, punchOutTime: punchOutTime!),
        //           ),
        //         );
        //       } else {
        //         ScaffoldMessenger.of(context).showSnackBar(
        //           SnackBar(content: Text("Please mark attendance first.")),
        //         );
        //       }
        //     },
        //     child:  Icon(Icons.fingerprint,color: Colors.blueGrey[900]!,),
        //     backgroundColor:Colors.blueGrey[200]!,
        // )
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle),
              label: 'Attendance',
            ),
          ],
          currentIndex: _currentIndex, // Set the index for the current tab
          selectedItemColor: Colors.blueGrey[900],
          onTap: _onItemTapped
        ),
      );
    });
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


class SlidePageRoute extends PageRouteBuilder {
  final Widget page;

  SlidePageRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}


import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Pages/StartPage.dart';
import 'package:scrapapp/URL_CONSTANT.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'attendance.dart';


class ProfilePage extends StatefulWidget {

  final int currentPage;
  ProfilePage({required this.currentPage});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? username;
  String? password;
  String? loginType = '';
  String? userType = '';
  String name = '';
  String contact = '';
  String email = '';
  String address = '';
  String empCode = '';
  String personId = '';
  String uuid = '';



  bool isLoggedIn = false;
  bool isPunchedIn = false;
  bool isPunchedOut = false;
  DateTime? punchTime;
  DateTime? punchOutTime;
  String? attendanceType ;
  int _currentIndex = 0; // Current tab index
  LocationData? _locationData;

  late Timer _lateloginCheckTimer;

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

    _initLocation();
    getCredentialDetails();
    checkLogin().then((_){
      setState(() {
         // if(userType != 'S')
         //  check_first_login();
      });
    });

    fetchPunchTimeFromDatabase();
    fetchLogoutPunchTimeFromDatabase();
  }

  @override
  void dispose() {
    _lateloginCheckTimer.cancel();
    super.dispose();
  }

  // Method to initialize location
  void _initLocation() async {
    try {
      _locationData = await Location().getLocation();
      if (_locationData != null) {
        double latitude = _locationData!.latitude!;
        double longitude = _locationData!.longitude!;
      } else {
        print('Failed to fetch location data.');
      }
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  Future<void> checkLogin() async {
     final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    uuid = prefs.getString("uuid")!;
    uuid = prefs.getString("uuid")!;
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
    uuid = prefs.getString("uuid")!;
    print("UUID:$uuid");


  }

  getCredentialDetails() async {
     final prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn')!;
      username = prefs.getString("username");
      uuid = prefs.getString("uuid")!;
      name = prefs.getString('name') ?? 'N/A';
      contact = prefs.getString('contact') ?? 'N/A';
      email = prefs.getString('email') ?? 'N/A';
      address = prefs.getString('address') ?? 'N/A';
      empCode = prefs.getString('empCode') ?? 'N/A';
      personId = prefs.getString('person_id') ?? 'N/A';
      // uuid = prefs.getString('uuid') ?? 'N/A';


      print("UUID:$uuid");
    });
    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StartPage()),
      );
    }
  }

  Future<String> getAddress(double latitude, double longitude) async {
    final apiKey = 'AIzaSyCdIqus6Zv1nGHQtQA-JmoVxotbLtr1Cv0';
    final endpoint = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>;
        if (results.isNotEmpty) {
          final formattedAddress = results[0]['formatted_address'];
          return formattedAddress;
        }
      }
      return 'Address not found';
    } catch (e) {
      print('Error getting address: $e');
      return 'Error';
    }
  }

  //Fetching API for User Attendance
  Future<void> set_user_attendance(
      String punchType, double? latitude, double? longitude) async {
    print("username");

    print(username);
    print(password);
    print(uuid);
    print( latitude?.toString());
    print( longitude?.toString());
    print(address);
    try {
      final address = await getAddress(latitude ?? 0.0, longitude ?? 0.0);



      final response = await http.post(
        Uri.parse('${URL}set_user_attend'),
        headers: {"Accept": "application/json"},
        body: {
          'user_id':username,
          'user_pass':password,
          'uuid':uuid,
          'punch_type': punchType,
          'location[lat]': latitude?.toString() ?? '',
          'location[long]': longitude?.toString() ?? '',
          'address': address ?? ''
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("DASDasdasd:$data");

      } else {
        print('Response Body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e'); // Log any errors that occur
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
          'uuid':uuid,
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
          'uuid':uuid
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
        //Fluttertoast.showToast(msg: 'Unable to fetch punch time');
      }
    }catch(e){
      print('Server Exception : $e');
    }finally{

    }
  }

  void check_first_login() async{
    try {
      await checkLogin();
      final url = Uri.parse('${URL}check_first_login');
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id':username,
          'user_pass':password,
          'uuid':uuid
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          var data = jsonDecode(response.body);

          var firstLoginCheck = data['admin_id'];

          print("Admin ID: $firstLoginCheck");

          // Check for empty or null admin_id
          if (firstLoginCheck == null || firstLoginCheck.toString().trim().isEmpty|| firstLoginCheck == 'Not Found' ) {
            print("Admin ID is empty, showing alert");
            _showLateLoginRemarkDialog();
          }
          else {
            print("Admin ID is valid: $firstLoginCheck");
          }


        });
      } else {
       // Fluttertoast.showToast(msg: 'Unable to fetch punch time');
      }
    }catch(e){
      print('Server Exception : $e');
    }finally{

    }
  }



  void fetchLogoutPunchTimeFromDatabase() async{
    try {
      print("uuid");

      print(uuid);
      await checkLogin();
      final url = Uri.parse('${URL}fetch_attendance_Outime');
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          // 'user_id':'Bantu',
          // 'user_pass':'Bantu#123',
          // 'uuid':'UKQ1.231108.001'
          'user_id':username,
          'user_pass':password,
          'uuid':uuid,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          var data = jsonDecode(response.body);
          print("data");

          print(data);


          punchOutTime = DateTime.parse(data['logout_time']);
          enablePunching("logged out");

          DateTime today = DateTime.now();
          String todayDate = DateFormat('yyyy-MM-dd').format(today);

          if (punchOutTime == null || punchOutTime! == "0000-00-00" ) {
            print("punchOutTime is NULL, skipping logic.");
          } else {
            String punchOutDate = DateFormat('yyyy-MM-dd').format(punchOutTime!);
            print("Today's Date: $todayDate");
            print("Punch Out Date: $punchOutDate");

            if (punchOutTime!.isBefore(today) && userType != 'S') {
              print("Hitting trackadminresponse...");
              trackadminresponse();
            } else {
              print("Condition not met: No dialog shown");
            }
          }



          // //Get today's date
          // DateTime today = DateTime.now();
          // String todayDate = DateFormat('yyyy-MM-dd').format(today);
          // String punchOutDate = DateFormat('yyyy-MM-dd').format(punchOutTime!);
          //
          // print("Todays:$todayDate");
          //
          // print("punchOutTime:$punchOutDate");
          //
          // // Check if punchOutDate is before today
          // if(punchOutTime! == "0000-00-00" && userType != 'S')
          // {
          //   if (punchOutTime!.isBefore(today) && userType != 'S') {
          //     print("Hitting trackadminresponse...");
          //     trackadminresponse();
          //   }
          //   else {
          //     print('Condition not met: No dialog shown');
          //   }
          // }
          // else
          // {
          //   print("Invalid date detected, not hitting trackadminresponse.");
          // }

        });
      } else {
       // Fluttertoast.showToast(msg: 'Unable to fetch punch time');
      }
    }catch(e){
      print('Server Exceptionasfs : $e');
    }finally{

    }
  }

  Future<void> trackadminresponse() async {
    print(username);
    print(password);

    try {
      await checkLogin();
      final response = await http.post(
        Uri.parse('${URL}track_admin_response'),
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'user_pass': password,
          'id': personId,
          'uuid':uuid,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);

        // If status is 0 and message is "Failed To Track Admin Activity...", do nothing
        if (responseData['status'] == '0' && responseData['msg'] == "Failed To Track Admin Activity...") {
          print("Condition met: Do nothing");
          return;
        }

        if (responseData['status'] == '1') {
          final adminActivity = responseData['tracked_admin_activity'];

          if (adminActivity != null) {
            final adminremarkmsg = adminActivity['remark'] ?? 'No remark found';

            setState(() {
              print("Admin remark message: $adminremarkmsg");

              if (adminremarkmsg == "No remark found") {
                print("Condition met: Showing Late Login Remark Dialog");
                _showLateLoginRemarkDialog();
              } else {
                print("Condition met: Showing Late Login Admin Remark Dialog");
                _showLateLoginAdminRemarkDialog();
              }
            });
          } else {
            print("No tracked admin activity found.");
          }
        } else if (responseData['status'] == '0') {
          print("Status is 0: Showing Late Login Remark Dialog");
          _showLateLoginRemarkDialog();
        } else {
          print('Unexpected status: ${responseData['status']}');
        }
      } else {
        print('Failed. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _submitLateLoginRemark(String remark) async {
    try {

      print(personId);
      print(remark);
      print(password);
      print(username);

      await checkLogin();
      final url = Uri.parse('${URL}submit_late_remark');
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id':username,
          'user_pass':password,
          'id':personId,
          'remark': remark,
          'uuid':uuid
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        print("data");

        if (data['status'] == '1') {
          // Refresh the page by calling setState
          setState(() {
            trackadminresponse();
          });
          // Handle success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Remark submitted successfully')),
          );



          Navigator.pop(context); // Close the dialog
        } else {
          // Handle failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit remark')),
          );
        }
      }
    } catch (e) {
      // Handle exception
      print('Error submitting remark: $e');

    }
  }

  void _showLateLoginRemarkDialog() {
    showDialog(
      context: context,
      barrierDismissible : false,
      builder: (context) {
        final TextEditingController remarkController = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text('Enter Late Login Remark'),
          content: TextField(
            controller: remarkController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Write your remark here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (remarkController.text.isNotEmpty) {
                  await _submitLateLoginRemark(remarkController.text);
                  // Refresh the page by calling setState


                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Remark cannot be empty')),
                  );
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showLateLoginAdminRemarkDialog() {
    showDialog(
      context: context,
      barrierDismissible : false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title:  Text(
            "Admin will shortly connect to you. Please wait for their response.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  enablePunching(String status) {
    DateTime currentDateTime = DateTime.now();
    String currentformattedDate = DateFormat('yyyy-MM-dd').format(currentDateTime);
    if (status == 'logged in'){
      String punchFormattedDate = DateFormat('yyyy-MM-dd').format(punchTime!);
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
    print(isPunchedIn);
    print("isPunchedIn");

    return StatefulBuilder(builder: (BuildContext context , StateSetter setState) {
      return Scaffold(
        drawer: userType != 'S'
            ? (isPunchedIn ? AppDrawer(currentPage: widget.currentPage) : null)
            : AppDrawer(currentPage: widget.currentPage),

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
              // Row(
              //   children: [
              //     Expanded(
              //         child: buildCard(
              //             name, nameIcon, 'assets/images/user2.jpg')),
              //     SizedBox(width: 8),
              //     Expanded(
              //         child: buildCard(
              //             contact, contactIcon, 'assets/images/contact3.jpeg')),
              //   ],
              // ),
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
                          set_user_attendance('logged in', _locationData?.latitude,
                              _locationData?.longitude);
                          Fluttertoast.showToast(msg: 'Your attendance marked for today');
                        }
                            : () {
                          set_user_attendance('logged in', _locationData?.latitude,
                              _locationData?.longitude);
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
                          set_user_attendance('logged out', _locationData?.latitude,
                              _locationData?.longitude);
                          Fluttertoast.showToast(msg: 'Your attendance marked for today');
                          }
                          : () {
                            if(isPunchedIn) {
                              set_user_attendance('logged out', _locationData?.latitude,
                                  _locationData?.longitude);
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


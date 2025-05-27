import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Pages/StartPage.dart';
import 'package:scrapapp/URL_CONSTANT.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../LocationService.dart';
import 'attendance.dart';
import 'dart:math' as math;

class ProfilePage extends StatefulWidget {
  final int currentPage;
  ProfilePage({required this.currentPage});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String uuid = '';
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
  String remainingDays = '';
  String logINTimeString = "";
  String logoutTimeString = "";
  String remainingDaysString = '';
  String? readonly = '';
  String? attendonly = '';

  bool isLoggedIn = false;
  bool isPunchedIn = false;
  bool isPunchedOut = false;
  DateTime? punchTime;
  DateTime? punchOutTime;
  String? attendanceType;
  int _currentIndex = 0; // Current tab index
  LocationData? _locationData;
  late Timer _gpsCheckTimer;

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

  double? latitude;
  double? longitude;

  String? appVersion;

  String? _buildNumber;
  bool _isUpdateAvailable = false;

  @override
  void initState() {
    super.initState();
    getCredentialDetails();
    _loadLocation();
    checkLogin().then((_) {
      setState(() {});
    });
    fetchPunchTimeFromDatabase(); // First call
    Future.delayed(Duration(milliseconds: 500), () {
      fetchLogoutPunchTimeFromDatabase(); // Second call after a small delay
    });
    fetchAttendanceData();
  }

  @override
  void dispose() {
    super.dispose();
    _gpsCheckTimer.cancel();
  }

  Future<void> _loadLocation() async {
    final prefs = await SharedPreferences.getInstance();
    latitude = prefs.getDouble('latitude');
    longitude = prefs.getDouble('longitude');

    if (latitude != null && longitude != null) {
      debugPrint('Saved Latitude: $latitude');
      debugPrint('Saved Longitude: $longitude');
    } else {
      debugPrint('Location not found in SharedPreferences');
    }
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
    remainingDays = prefs.getString("remainingDays")!;
    readonly = prefs.getString("readonly");
    attendonly = prefs.getString("attendonly");
    appVersion = prefs.getString("appVersion");

    DateTime today = DateTime.now();
    DateTime targetDate = DateTime.parse(remainingDays);

    Duration difference = targetDate.difference(today);
    remainingDaysString =
        difference.inDays.toString(); // Convert duration to string

    print("Remaining Days: $remainingDaysString");

    uuid = prefs.getString("uuid")!;
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
      personId = prefs.getString('person_id') ?? 'N/A';
    });
    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StartPage()),
      );
    }
  }

  void showUpdateDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 16,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.system_update, size: 60,
                        color: Colors.blueAccent),
                    const SizedBox(height: 10),
                    Text(
                      "New Update Available!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "We've added new features and fixed some bugs. Please update to the latest version for the best experience.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Add redirect logic here
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.download_rounded),
                      label: Text("Update Now"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        elevation: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );
    });
  }

  Future<String> getAddress(double latitude, double longitude) async {
    final apiKey = 'AIzaSyBrZfvGsraZRBZjSgYTFlfgsqAtinPhzss';
    final latlng = '$latitude,$longitude';

    final endpoint = Uri.https(
      'maps.googleapis.com',
      '/maps/api/geocode/json',
      {
        'latlng': latlng,
        'key': apiKey,
      },
    );

    print('Fetching address for: Latitude=$latitude, Longitude=$longitude');
    print('Endpoint URL: $endpoint');

    try {
      final response = await http.get(endpoint);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');


      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>;
        if (results.isNotEmpty) {
          final formattedAddress = results[0]['formatted_address'];
          return formattedAddress;
        } else {
          return 'No address found';
        }
      } else {
        return 'API call failed';
      }
    } catch (e) {
      print('Error getting address: $e');
      return 'Error';
    }
  }

  bool isLoading = false;
  bool isPunchOutLoading = false;

  //Fetching API for User Attendance
  Future<void> set_user_attendances(String punchType) async {
    try {
      setState(() {
        if (punchType == 'logged in') {
          isLoading = true;
        } else {
          isPunchOutLoading = true;
        }
      });

      final address = await getAddress(latitude!, longitude!);

      final url = Uri.parse('${URL}set_user_attend');
      final requestBody = {
        'user_id': username,
        'user_pass': password,
        'uuid': uuid,
        'punch_type': punchType,
        'location[lat]': latitude?.toString() ?? '',
        'location[long]': longitude?.toString() ?? '',
        'address': address ?? ''
      };

      final response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['msg'] == 'Attendance updated successfully.') {
          Fluttertoast.showToast(msg: 'Attendance marked successfully.');

          if (punchType == 'logged in') {
            fetchPunchTimeFromDatabase();
            fetchAttendanceData();
          } else {
            fetchLogoutPunchTimeFromDatabase();
            fetchAttendanceData();
            // 🔴 Clear stored latitude & longitude on punch-out
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('latitude');
            await prefs.remove('longitude');
            latitude = null;
            longitude = null;
            // debugPrint("Cleared latitude and longitude from SharedPreferences on punch-out.");
          }
        } else {
          Fluttertoast.showToast(msg: data['msg']);
        }
      } else {
        print("Error: ${response.body}");
      }
    } catch (e, stackTrace) {
      print("Error: $e\n$stackTrace");
    } finally {
      setState(() {
        if (punchType == 'logged in') {
          isLoading = false;
        } else {
          isPunchOutLoading = false;
        }
      });
    }
  }

  void sendPunchTimeToDatabase(String status) async {
    try {
      await checkLogin();
      final url = Uri.parse('${URL}set_user_attendance');
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'user_pass': password,
          'status': status,
          'uuid': uuid,
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        Fluttertoast.showToast(msg: data['msg']);
        print("Punch Status: $status");

        if (status == 'logged in') {
          fetchPunchTimeFromDatabase();
        } else {
          fetchLogoutPunchTimeFromDatabase();
        }
      } else {
        Fluttertoast.showToast(msg: 'Unable to mark punch time');
      }
    } catch (e) {
      print('Server Exception: $e');
    }
  }

  void fetchPunchTimeFromDatabase() async {
    try {
      await checkLogin();
      final url = Uri.parse('${URL}fetch_attendance_time');
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid': uuid,
          'user_pass': password,
        },
      );
      var data = jsonDecode(response.body);

      if (data.containsKey('login_time') &&
          data['login_time'] == "0000-00-00") {
        // print("Skipping punchTime assignment. Invalid logout_time detected.");
        logINTimeString = data['login_time'];
      } else if (data.containsKey('login_time') && data['login_time'] != null) {
        punchTime = DateTime.parse(data['login_time']);
        // print("PunchIn Time : $punchTime");
        enablePunching("logged in");
      } else {
        // print("Skipping punchTime assignment. 'login_time' not found in response.");
      }

      DateTime today = DateTime.now();
      String todayDate = DateFormat('yyyy-MM-dd').format(today);

      // print("TodayDate:$todayDate");
      // print("logoutTimeString in case of Zero: $logoutTimeString");
      // print("logINTimeString in case of Zero: $logINTimeString");
      //
      // print("punchTime:$punchTime");
      String punchINDate = DateFormat('yyyy-MM-dd').format(punchTime!);
      // print("punchINDate:$punchINDate");

      if (logINTimeString == "0000-00-00" && userType != 'S') {
        // print("Skipping trackadminresponse call because logINTimeString is 0000-00-00");
      } else if (punchINDate != todayDate && userType != 'S') {
        // print("punchINDate $punchINDate is not equal to todayDate $todayDate, calling fasfasf...");
        trackadminresponse();
      } else {
        // print("Skipping trackadminresponse call because punchINDate matches today’s date.");
      }

      // if (response.statusCode == 200) {
      //   setState(() {
      //     var data = jsonDecode(response.body);
      //
      //     logINTimeString = data['login_time'];
      //
      //     punchTime = DateTime.parse(data['login_time']);
      //
      //     print(logINTimeString);
      //     print("asfsa");
      //     print("PunchIn Time : $punchTime");
      //     enablePunching("logged in");
      //   });
      // } else {
      //   Fluttertoast.showToast(msg: 'Unable to fetch punch time');
      // }
    } catch (e) {
      print('Server Exception 258 : $e');
    } finally {}
  }

  void fetchLogoutPunchTimeFromDatabase() async {
    try {
      await checkLogin();
      final url = Uri.parse('${URL}fetch_attendance_Outime');
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid': uuid,
          'user_pass': password,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          var data = jsonDecode(response.body);

          if (data.containsKey('logout_time') &&
              data['logout_time'] == "0000-00-00") {
            print(
                "Skipping punchTime assignment. Invalid logout_time detected.");
            logoutTimeString =
                data['logout_time'] ?? ""; // Ensure it's not null
            print("logoutTimeString: $logoutTimeString");
          } else if (data.containsKey('logout_time') &&
              data['logout_time'] != "0000-00-00") {
            try {
              punchOutTime = DateTime.tryParse(
                  data['logout_time']); // Use tryParse to prevent crashes
              if (punchOutTime != null) {
                enablePunching("logged out");
              }
            } catch (e) {
              print("Error parsing logout_time: ${data['logout_time']}");
              punchOutTime = null; // Ensure it's handled safely
            }
          } else {
            print(
                "Skipping punchTime assignment. 'logout_time' not found in response.");
          }
        });
      } else {
        Fluttertoast.showToast(msg: 'Unable to fetch punch time');
      }
    } catch (e) {
      print('Server Exceptionasfasf : $e');
    } finally {}
  }

  Future<void> trackadminresponse() async {
    try {
      await checkLogin();
      final response = await http.post(
        Uri.parse('${URL}track_admin_response'),
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'user_pass': password,
          'id': personId,
          'uuid': uuid,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);

        if (responseData['status'] == '0' &&
            responseData['msg'] == "Failed To Track Admin Activity...") {
          print("Condition met: Do nothing");
          return;
        }

        if (responseData['status'] == '1') {
          final adminActivities = responseData['tracked_admin_activity'];

          if (adminActivities != null && adminActivities.isNotEmpty) {
            final adminActivity = adminActivities[
            0]; // Hamesha 0th position ka response le raha hai

            final adminremarkmsg = adminActivity['remark'] ?? 'No remark found';
            final adminstatus = adminActivity['status'] ?? 'P';

            print(adminstatus);
            print("adminstatus");

            setState(() {
              print("Admin remark message: $adminremarkmsg");

              if (adminremarkmsg == "No remark found") {
                print(
                    "Condition met without status: Showing Late Login Remark Dialog");
                _showLateLoginRemarkDialog();
              } else if (adminstatus == "P" || adminstatus == "R") {
                print(
                    "Condition met with status: Showing Late Login Admin Remark Dialog");
                _showLateLoginAdminRemarkDialog();
              } else {
                print("Login Approved.");
              }
            });
          } else {
            print("No tracked admin activity found.");
          }
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
          'user_id': username,
          'user_pass': password,
          'id': personId,
          'remark': remark,
          'uuid': uuid
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
      barrierDismissible: false,
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
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
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
    String currentformattedDate =
    DateFormat('yyyy-MM-dd').format(currentDateTime);
    if (status == 'logged in') {
      String punchFormattedDate = DateFormat('yyyy-MM-dd').format(punchTime!);
      if (currentformattedDate != punchFormattedDate) {
        setState(() {
          isPunchedIn = false;
        });
      } else {
        setState(() {
          isPunchedIn = true;
        });
      }
    }
    if (status == 'logged out') {
      String punchOutFormattedDate =
      DateFormat('yyyy-MM-dd').format(punchOutTime!);
      if (currentformattedDate != punchOutFormattedDate) {
        setState(() {
          isPunchedOut = false;
        });
      } else {
        setState(() {
          isPunchedOut = true;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      if (isPunchedIn) {
        _currentIndex = index; // Update current index
      } else {
        Fluttertoast.showToast(msg: 'Please mark attendance first.');
      }

      if (_currentIndex == 1) {
        if (punchTime != null && punchOutTime != null) {
          Navigator.push(
            context,
            SlidePageRoute(
              page: AttendanceMarkedPage(
                  punchTime: punchTime!, punchOutTime: punchOutTime!),
            ),
          ).then((value) {
            _currentIndex = 0;
            _onItemTapped(_currentIndex);
          });
        } else if (punchTime != null) {
          Navigator.push(
            context,
            SlidePageRoute(
              page: AttendanceMarkedPage(
                  punchTime: punchTime!, punchOutTime: null),
            ),
          ).then((value) {
            _currentIndex = 0;
            _onItemTapped(_currentIndex);
          });
        } else if (punchOutTime != null) {
          Navigator.push(
            context,
            SlidePageRoute(
              page: AttendanceMarkedPage(
                  punchTime: null, punchOutTime: punchOutTime!),
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

  String presentCount = '0';
  String absentCount = '0';
  String lateLoginCount = '0';
  List<Map<String, dynamic>> attendanceList = [];

  // Leave Summary Strings
  String takenLeaves = '0';
  String upcomingLeaves = '0';

// Leave Data List
  List<Map<String, dynamic>> leaveList = [];

  String location = '';

  Future<void> fetchAttendanceData() async {
    await checkLogin();
    final response = await http.post(
      Uri.parse('${URL}employee_details'),
      body: {
        'user_id': username,
        'user_pass': password,
        'uuid': uuid
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final data = decoded['attendance_data'] ?? [];
      final summary = decoded['attendance_summary'] ?? {};
      final leaveSummary = decoded['leave_summary'] ?? {};
      final leaveData = decoded['leave_data'] ?? [];
      final locationData = decoded['location_data'] ?? {};

      setState(() {
        presentCount = summary['present_count'].toString();
        absentCount = summary['absent_count'].toString();
        lateLoginCount = summary['late_login_count'].toString();
        attendanceList = List<Map<String, dynamic>>.from(data);
        takenLeaves = leaveSummary['taken_leaves'].toString();
        upcomingLeaves = leaveSummary['upcoming_leaves'].toString();
        // Leave data list
        leaveList = List<Map<String, dynamic>>.from(leaveData);
        location = locationData['location'] ?? '';

      });
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  Widget attendanceTile() {
    final bool isAttendanceEmpty = attendanceList.isEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.indigo.shade800),
          ),
          const SizedBox(height: 12),

          /// Summary inside ExpansionTile
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: Row(
              children: [
                Expanded(
                    child: Text('Present: $presentCount',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                Expanded(
                    child: Text('Absent: $absentCount',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                Expanded(
                    child: Text('Late: $lateLoginCount',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
              ],
            ),
            children: [
              if (isAttendanceEmpty)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                      child: Text('No attendance data available',
                          style: TextStyle(color: Colors.grey))),
                )
              else
                ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: attendanceList.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: 12), // Space between cards
                  itemBuilder: (context, index) {
                    final entry = attendanceList[index];
                    final punchIn = entry['punchintime'] ?? '-';
                    final punchOut = entry['punchout'] ?? '-';
                    final status = (entry['status'] ?? '').toLowerCase();

                    Color statusColor;
                    String statusLabel;

                    if (status == 'present') {
                      statusColor = Colors.green;
                      statusLabel = 'Present';
                    } else if (status == 'not logged out') {
                      statusColor = Colors.orange;
                      statusLabel = 'Not Logged Out';
                    } else {
                      statusColor = Colors.red;
                      statusLabel = 'Absent';
                    }

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 4,
                              offset: Offset(0, 2))
                        ],
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.login, color: Colors.blueAccent, size: 18),
                              SizedBox(width: 8),
                              Text('Punch In:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500, color: Colors.black87)),
                              SizedBox(width: 6),
                              Text(punchIn,
                                  style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.logout, color: Colors.deepPurple, size: 18),
                              SizedBox(width: 8),
                              Text('Punch Out:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500, color: Colors.black87)),
                              SizedBox(width: 6),
                              Text(punchOut,
                                  style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: statusColor,
                                ),
                              ),
                              Text(
                                statusLabel,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }


  Widget leaveTile() {
    final bool isLeaveEmpty = leaveList.isEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Leave', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,color: Colors.indigo.shade800)),
          const SizedBox(height: 12),

          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    'Taken Leaves: $takenLeaves',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Upcoming Leaves: $upcomingLeaves',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ],
            ),
            children: [
              if (isLeaveEmpty)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Text('No leave data available', style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: leaveList.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final entry = leaveList[index];
                    final fromDate = entry['from_date'] ?? '-';
                    final toDate = entry['to_date'] ?? '-';
                    final reason = entry['selected_reason'] ?? '-';
                    final comment = entry['reason'] ?? '-';

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ],
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.date_range, color: Colors.deepPurple, size: 18),
                              SizedBox(width: 8),
                              Text('From Date:',
                                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
                              SizedBox(width: 6),
                              Text(fromDate, style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.event, color: Colors.green, size: 18),
                              SizedBox(width: 8),
                              Text('To Date:',
                                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
                              SizedBox(width: 6),
                              Text(toDate, style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orangeAccent, size: 18),
                              SizedBox(width: 8),
                              Text('Reason:',
                                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
                              SizedBox(width: 6),
                              Flexible(child: Text(reason, style: TextStyle(color: Colors.black54))),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.comment, color: Colors.teal, size: 18),
                              SizedBox(width: 8),
                              Text('Comment:',
                                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(comment, style: TextStyle(color: Colors.black54)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
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
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Scaffold(
            // drawer: (attendonly == 'Y' || attendonly == '')
            //     ? null
            //     : userType != 'S'
            //         ? (isPunchedIn ? AppDrawer(currentPage: widget.currentPage) : null)
            //         : AppDrawer(currentPage: widget.currentPage),

            drawer: userType != 'S'
                ? (isPunchedIn
                ? AppDrawer(currentPage: widget.currentPage)
                : null)
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
                            borderRadius: BorderRadius.circular(21),
                            // Ensure the image also respects the border radius
                            child: Image.asset(
                              'assets/images/themeimg1.jpeg',
                              fit: BoxFit.cover,
                              // Use BoxFit.cover to ensure the image covers the entire area
                              width: double.infinity,
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
                                backgroundImage:
                                AssetImage('assets/images/hello.gif'),
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
                              Text(
                                "Deactivates in $remainingDaysString days!",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
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
                  // buildListTile('Email', email, 'assets/images/email2.jpeg'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Punch In Button
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                          child: ElevatedButton.icon(
                            onPressed: isPunchedIn || isLoading
                                ? null
                                : () {
                              set_user_attendances('logged in');
                            },
                            icon: Icon(Icons.login, size: 20),
                            label: isLoading
                                ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : Text(
                              'Punch In',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPunchedIn || isLoading
                                  ? Colors.grey[400]
                                  : Colors.green.shade600,
                              foregroundColor: Colors.white,
                              elevation: 6,
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              shadowColor: Colors.greenAccent,
                            ),
                          ),
                        ),
                      ),

                      // Punch Out Button
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                          child: ElevatedButton.icon(
                            onPressed: isPunchedOut || isPunchOutLoading
                                ? null
                                : () {
                              if (isPunchedIn) {
                                set_user_attendances('logged out');
                              } else {
                                Fluttertoast.showToast(msg: 'Please punch in first');
                              }
                            },
                            icon: Icon(Icons.logout, size: 20),
                            label: isPunchOutLoading
                                ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : Text(
                              'Punch Out',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPunchedOut || isPunchOutLoading
                                  ? Colors.grey[400]
                                  : Colors.red.shade600,
                              foregroundColor: Colors.white,
                              elevation: 6,
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              shadowColor: Colors.redAccent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  buildListTile('Address', address, 'assets/images/location.jpeg'),
                  buildListTile('Location', location , 'assets/images/location.jpeg'),
                  attendanceTile(),
                  leaveTile(),
                  // buildListTile('Late Login', 'Check late login details', 'assets/images/location.jpeg'),
                  // buildListTile('Leave', 'Apply or view your leave details', 'assets/images/location.jpeg'),





                  // Expanded(
                  //   child: Container(
                  //     margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  //     child: ElevatedButton.icon(
                  //       icon: Icon(Icons.login_rounded, color: Colors.white),
                  //       label: Text("Punch In", style: TextStyle(color: Colors.white)),
                  //       onPressed: isPunchedIn
                  //           ? () {
                  //         Fluttertoast.showToast(msg: 'Your attendance marked for today');
                  //       }
                  //           : () {
                  //         set_user_attendances('logged in');
                  //         // sendPunchTimeToDatabase("logged in");
                  //
                  //         print('isPunchedIn :$isPunchedIn');
                  //       },
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: isPunchedIn
                  //             ? Colors.grey[400]
                  //             : Colors.greenAccent[200],
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(30),
                  //         ),
                  //         elevation: 5,
                  //         padding: EdgeInsets.symmetric(vertical: 14.0),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // Expanded(
                  //   child: Container(
                  //     margin:
                  //         EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  //     child: ElevatedButton.icon(
                  //       icon: Icon(Icons.logout_rounded, color: Colors.white),
                  //       label: Text("Punch Out",
                  //           style: TextStyle(color: Colors.white)),
                  //       onPressed: isPunchedOut
                  //           ? () {
                  //               Fluttertoast.showToast(
                  //                   msg: 'Your attendance marked for today');
                  //             }
                  //           : () {
                  //               if (isPunchedIn) {
                  //                 set_user_attendances('logged out');
                  //                 // sendPunchTimeToDatabase("logged out");
                  //               } else {
                  //                 Fluttertoast.showToast(
                  //                     msg: 'Please punch in first');
                  //               }
                  //             },
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: isPunchedOut
                  //             ? Colors.grey[400]
                  //             : Colors.redAccent[200],
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(30),
                  //         ),
                  //         elevation: 5,
                  //         padding: EdgeInsets.symmetric(vertical: 14.0),
                  //       ),
                  //     ),
                  //   ),
                  // ),

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
                currentIndex: _currentIndex,
                // Set the index for the current tab
                selectedItemColor: Colors.blueGrey[900],
                onTap: _onItemTapped),
          );
        });
  }

  Widget buildListTile(String text, String value, String path) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 14),
          child: Row(
            children: [
              // Circular image with orange border
              Container(
                padding: EdgeInsets.all(2.5), // space between border and image
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.deepOrange, width: 2),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.asset(
                      path,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 14),

              // Text Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo.shade800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Subtle right status dot (optional)
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.tealAccent.shade400,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.tealAccent.shade100.withOpacity(0.6),
                      blurRadius: 6,
                      offset: Offset(0, 2),
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

      var tween =
      Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

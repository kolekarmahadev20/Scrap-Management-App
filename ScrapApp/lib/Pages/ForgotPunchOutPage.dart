import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';
import '../URL_CONSTANT.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'StartPage.dart';

class ForgotPunchOutPage extends StatefulWidget {
  final int currentPage;
  ForgotPunchOutPage({required this.currentPage});

  @override
  _ForgotPunchOutPageState createState() => _ForgotPunchOutPageState();
}

class _ForgotPunchOutPageState extends State<ForgotPunchOutPage> {
  List<Map<String, dynamic>> _users = []; // Original user list
  List<Map<String, dynamic>> _filteredUsers = []; // Filtered user list
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController(); // Search controller


  //Variables for user details
  String? username = '';
 String uuid = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';

  @override
  void initState() {
    super.initState();
    getCredentialDetails();
    checkLogin().then((_){
      setState(() {
      });
    });
    _fetchLateLoggedOutUsers();
    _searchController.addListener(_filterUsers); // Add search listener

  }

  //Fetching user details from sharedpreferences
  Future<void> checkLogin() async {
     final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    uuid = prefs.getString("uuid")!;
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
  }

  String name = '';
  String contact = '';
  String email = '';
  String address = '';
  String empCode = '';
  String personId = '';

  bool isLoggedIn = false;
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

      print("empCode:$personId");
    });
    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StartPage()),
      );
    }
  }

  // Function to filter users based on search query
  void _filterUsers() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      _filteredUsers = _users
          .where((user) =>
          user['name'].toLowerCase().contains(query)) // Filter by name
          .toList();
    });
  }

  // Function to fetch late-logged-out users from the API
  Future<void> _fetchLateLoggedOutUsers() async {
    try {
      await checkLogin();
      final url = '${URL}late_logged_out_user';
      final response = await http.post(
        Uri.parse(url),
        body: {
        'user_id': username,
        'uuid':uuid,
          'user_pass': password,
          'attendance_type':'logged out',
        },
      );

      print("bharat");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print(data);
        print("bharat");

        setState(() {
          _isLoading = false;
          // Check if the response contains users
          if (data['status'] == '1') {
            _users = List<Map<String, dynamic>>.from(data['late_logged_out_users'].map((user) {
              return {
                'id': user['admin_id'],
                'name': user['person_name'],
                'punchInTime':  user['login_time'], // Modify if you have punch-in time info
                'status': user['status'],
                'remark': user['remark'],
                'attendance_id': user['attendance_id']

              };
            }));
            _users.sort((a, b) => (b['attendance_id']).compareTo(a['attendance_id']));
            _filteredUsers = _users; // Initialize the filtered list with all users

          }
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        // Handle API error
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch data from the API')));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    }
  }

  void check_first_login(String? admin_status, String? attendanceID,String? adminID) async{
    print("attendanceID");

    print(username);
    print(password);
    print(uuid);
    print(userType);
    print(adminID);
    print(admin_status);
    print(attendanceID);

    try {
      await checkLogin();
      final url = Uri.parse('${URL}login_accept_reject_remark');
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id':username,
          'user_pass':password,
          'uuid':uuid,
          'id_to_permit':adminID,
          'status':admin_status,
          'user_type':userType,
          'attendance_id':attendanceID

          // 'user_id':'Bantu',
          // 'user_pass':'Bantu#123',
          // 'uuid':'UKQ1.231108.001',
          // 'id_to_permit':'141',
          // 'status':'R',
          // 'user_type':'S',
          // 'attendance_id':'6841'
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          var data = jsonDecode(response.body);

          print(data);
          print("Asgasg");
          setState(() {
            _fetchLateLoggedOutUsers();
          });

        });
      } else {
        Fluttertoast.showToast(msg: 'Unable to fetch punch time');
      }
    }catch(e){
      print('Server Exception : $e');
    }finally{

    }
  }

  void _updateUserStatus(int userId, String status, [String? remark]) {
    setState(() {
      final user = _users.firstWhere((user) => user['id'] == userId);
      user['status'] = status;
      if (remark != null) user['remark'] = remark;
    });
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user['name'],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Chip(
                label: Text(
                  user['status'] == 'P'
                      ? 'Pending'
                      : (user['status'] == 'A'
                      ? 'Accepted'
                      : 'Rejected'),
                  style: TextStyle(
                    color: user['status'] == 'P'
                        ? Colors.orange
                        : (user['status'] == 'A'
                        ? Colors.green
                        : Colors.red),
                  ),
                ),
                backgroundColor: user['status'] == 'P'
                    ? Colors.orange.shade100
                    : (user['status'] == 'A'
                    ? Colors.green.shade100
                    : Colors.red.shade100),
              ),
            ),

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       user['name'],
            //       style: TextStyle(
            //         fontSize: 18,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //     Chip(
            //       label: Text(
            //         user['status'] == 'P'
            //             ? 'Pending'
            //             : (user['status'] == 'A'
            //             ? 'Accepted'
            //             : 'Rejected'),
            //         style: TextStyle(
            //           color: user['status'] == 'P'
            //               ? Colors.orange
            //               : (user['status'] == 'A'
            //               ? Colors.green
            //               : Colors.red),
            //         ),
            //       ),
            //       backgroundColor: user['status'] == 'P'
            //           ? Colors.orange.shade100
            //           : (user['status'] == 'A'
            //           ? Colors.green.shade100
            //           : Colors.red.shade100),
            //     ),
            //
            //   ],
            // ),
            SizedBox(height: 8),
            // Text(
            //   'Email: ${user['email']}',
            //   style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            // ),
            // Text(
            //   'Role: ${user['role']}',
            //   style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            // ),
            Text(
              'Punch In Time: ${user['punchInTime']}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            // if (user['remark'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'User Remark: ${user['remark']}',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            Divider(height: 20),
            if (user['status'] == 'P')
            Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      //_showRemarkDialog(user['id']);
                      check_first_login("A",user['attendance_id'],user['id']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Allow Login'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // _updateUserStatus(user['id'], 'Denied');
                      check_first_login("R",user['attendance_id'],user['admin_id']);

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Deny'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // void _showRemarkDialog(int userId) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       final TextEditingController remarkController = TextEditingController();
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16.0),
  //         ),
  //         title: Text('Enter Remark'),
  //         content: TextField(
  //           controller: remarkController,
  //           maxLines: 3,
  //           decoration: InputDecoration(
  //             hintText: 'Write your remark here...',
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: Text('Cancel'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               if (remarkController.text.isNotEmpty) {
  //                 _updateUserStatus(userId, 'Allowed', remarkController.text);
  //                 Navigator.pop(context);
  //               } else {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(content: Text('Remark cannot be empty')),
  //                 );
  //               }
  //             },
  //             child: Text('Submit'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentPage: widget.currentPage),
      appBar: CustomAppBar(),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  _filterUsers();
                },
                decoration: InputDecoration(
                  hintText: "Search by Name...",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.redAccent),
                    onPressed: () {
                      _searchController.clear();
                      _filterUsers();
                    },
                  )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          // List of Users
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                ? Center(child: Text("No users found"))
                : ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                return _buildUserCard(_filteredUsers[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
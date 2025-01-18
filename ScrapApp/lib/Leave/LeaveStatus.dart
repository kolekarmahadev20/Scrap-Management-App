import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:scrapapp/URL_CONSTANT.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';

class LeaveStatus extends StatefulWidget {
  const LeaveStatus({Key? key}) : super(key: key);

  @override
  _LeaveStatusState createState() => _LeaveStatusState();
}

class _LeaveStatusState extends State<LeaveStatus> {
  List<dynamic> leaveData = [];

  // Add a boolean variable to track if data is being loaded
  bool isLoading = true;

  getStatusLabel(String status) {
    if (status != '-1') {
      if (status == '0') {
        return 'Pending';
      } else if (status == '1') {
        return 'Approved';
      } else if (status == '2') {
        return 'Rejected';
      } else {
        return 'null';
      }
    }
  }

  //Variables for user details
  bool _isloggedin = true;
  String _id = '';
  String _username = '';
  String _full_name = '';
  String _email = '';
  String userImageUrl = '';
  String _user_type = '';
  String _password = '';
  String _uuid = '';

  String? a = '';

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    fetchLeaveData().then((data) {
      if (data != null) {
        setState(() {
          leaveData = data;
          isLoading = false; // Data loading is complete
        });
      }
    });

  }

  // Fetching user details from shared preferences
  _getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isloggedin = prefs.getBool("loggedin")!;
      _id = prefs.getString('id')!;
      _username = prefs.getString('username')!;
      _full_name = prefs.getString('full_name')!;
      _email = prefs.getString('email')!;
      _user_type = prefs.getString('user_type') ?? '';
      _password = prefs.getString('password')??'';
      _uuid= prefs.getString('uuid')??'';

    });

    if (kDebugMode) {
      //print("is logged in$_isloggedin");
    }
    if (_isloggedin == false) {
      // ignore: use_build_context_synchronously

    }
  }

  Future<void> changeLeaveStatus(String leaveId, String status) async {
    try {
      await _getUserDetails();

      final response = await http.post(
        Uri.parse('$URL/Mobile_flutter_api/change_leave_status'),
        headers: {"Accept": "application/json"},
        body: {
          'uuid': _uuid,
          'user_id': _username,
          'password': _password,
          'status': status,
          'leave_id': leaveId,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);

        // Update leaveData based on the changed status
        setState(() {
          leaveData = leaveData.map((leave) {
            if (leave['id'].toString() == leaveId) {
              // Update the status for the specific leave
              leave['status'] = status;
            }
            return leave;
          }).toList();
        });

        // Handle the response data as needed
      } else {
        print('Failed to change leave status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  Future<List<dynamic>> fetchLeaveData() async {
    await _getUserDetails(); // Ensure you have user details
    try {
      final response = await http.post(
        Uri.parse('$URL/Mobile_flutter_api/get_leaves'),
        headers: {"Accept": "application/json"},
        body: {
          'uuid': _uuid,
          'user_id': _username,
          'password': _password,
          // Other necessary parameters
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);

        if (data["status"] == "1") {
          if (data.containsKey("user_data") && data["user_data"] is List) {
            List<dynamic> leaveData = data["user_data"];

            // Accessing the 'id' of the first user_data entry
            // Accessing all the 'id' values in user_data
            List<String> userIds = leaveData.map((userData) => userData["id"].toString()).toList();
            // print("asjkfgbaijsbfas");
            // print("User IDs: $userIds");

            setState(() {
              leaveData = data["user_data"] as List;
            });

            return leaveData;
          } else {
            print('No valid "user_data" found in the response');
          }
        } else {
          print('Status is not 1 in the response');
        }
      } else {
        print('Failed to fetch leave data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return [];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentPage: 0),
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        scrollDirection: Axis.horizontal, // Set horizontal scroll
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.menu_book,
                  color: Colors.blue.shade900,
                  size: 32,
                ),
                SizedBox(width: 10),
                Text(
                  'Leave Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            // Indicator
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green, // Adjust color as needed
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  'Approved',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 10),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red, // Adjust color as needed
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  'Rejected',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            if (leaveData.isNotEmpty)
              Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Set horizontal scroll
                  child: DataTable(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                    ),
                    columnSpacing: 20,
                    columns: [
                      DataColumn(
                        label: Text(
                          'Sr No.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Emp Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Apply Date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Change Status',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'From Date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'To Date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Reason',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Status',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                    rows: List<DataRow>.generate(
                      leaveData.length,
                          (index) => DataRow(
                        color: MaterialStateColor.resolveWith(
                              (Set<MaterialState> states) {
                            return index % 2 == 0
                                ? Colors.white
                                : Colors.transparent;
                          },
                        ),
                        cells: [
                          DataCell(Text((index + 1).toString())),
                          DataCell(Text(leaveData[index]['full_name'] ?? '')),
                          DataCell(Text(leaveData[index]['submitted_on'] ?? '')),
                          DataCell(
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    changeLeaveStatus(
                                      leaveData[index]['id'].toString(),
                                      '1',
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: Text('Approve'),
                                ),
                                SizedBox(width: 8.0),
                                ElevatedButton(
                                  onPressed: () {
                                    changeLeaveStatus(
                                      leaveData[index]['id'].toString(),
                                      '2',
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: Text('Reject'),
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text(leaveData[index]['from_date'] ?? '')),
                          DataCell(Text(leaveData[index]['to_date'] ?? '')),
                          DataCell(Text(leaveData[index]['reason'] ?? '')),
                          DataCell(
                            Text(
                              getStatusLabel(leaveData[index]['status'] ?? '0'),
                              style: TextStyle(
                                color: leaveData[index]['status'] == '0'
                                    ? Colors.grey
                                    : leaveData[index]['status'] == '1'
                                    ? Colors.green
                                    : leaveData[index]['status'] == '2'
                                    ? Colors.red
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (leaveData.isEmpty && !isLoading)
              Center(
                child: Text(
                  'No Data Found',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

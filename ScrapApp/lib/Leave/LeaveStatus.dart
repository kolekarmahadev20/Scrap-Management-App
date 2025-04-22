import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';
import '../URL_CONSTANT.dart';

class LeaveStatus extends StatefulWidget {
  final int currentPage;
  LeaveStatus({required this.currentPage});

  @override
  _LeaveStatusState createState() => _LeaveStatusState();
}

class _LeaveStatusState extends State<LeaveStatus> {
  List<dynamic> leaveData = [];
  List<dynamic> filteredLeaveData = [];
  bool isLoading = true;

  String searchQuery = '';

  // Variables for user details
  String? username = '';
  String uuid = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';


  @override
  void initState() {
    super.initState();
    checkLogin();
    fetchLeaveData().then((data) {
      if (data != null) {
        setState(() {
          leaveData = data;
          filteredLeaveData = data;
          isLoading = false;
        });
      }
    });
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    uuid = prefs.getString("uuid")!;
    username = prefs.getString("username");
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
    uuid = prefs.getString("uuid")!;
  }

  void filterLeaveData(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      searchQuery = query;
      filteredLeaveData = leaveData.where((leave) {
        final name = (leave['person_name'] ?? '').toLowerCase();
        return name.contains(lowerQuery);
      }).toList();
    });
  }

  loginApproval(String leaveId) async {
    try {
      await checkLogin();
      final response = await http.post(
        Uri.parse('${URL}final_approval'),
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid': uuid,
          'user_pass': password,
          'leave_id': leaveId,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);

        if (responseData['status'] == true) {

          // ✅ Fetch new data
          await fetchLeaveData().then((data) {
            setState(() {
              leaveData = data;
              filteredLeaveData = searchQuery.isEmpty
                  ? data
                  : data.where((leave) => (leave['person_name'] ?? '')
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase())).toList();
            });
          });

        }
      } else {
        print('Failed to change leave status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  Future<void> changeLeaveStatus(String leaveId, String status) async {
    try {
      await checkLogin();
      final response = await http.post(
        Uri.parse('${URL}change_leave_status'),
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid': uuid,
          'user_pass': password,
          'id': leaveId,
          'status': status,
          'rejection_note': 'Rejected',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
        print('bharat');
        setState(() {
          fetchLeaveData();
          leaveData = leaveData.map((leave) {
            if (leave['id'].toString() == leaveId) {
              leave['status'] = status;
            }
            return leave;
          }).toList();
        });
      } else {
        print(
            'Failed to change leave status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<dynamic>> fetchLeaveData() async {
    await checkLogin();
    try {
      final response = await http.post(
        Uri.parse('${URL}get_leaves'),
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid': uuid,
          'user_pass': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == "1") {
          return data["user_data"] as List;
        }
      }
    } catch (e) {
      print('Error: $e');
    }
    return [];
  }

  String getStatusLabel(String status) {
    switch (status) {
      case '0':
        return 'PENDING';
      case '1':
        return 'APPROVED';
      case '2':
        return 'REJECTED';
      default:
        return 'UNKNOWN';
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case '0':
        return Colors.orangeAccent;
      case '1':
        return Colors.green;
      case '2':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  String getMonthAbbreviation(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    return months[month - 1];
  }

  String formatDate(String dateStr) {
    try {
      DateTime parsedDate = DateTime.parse(dateStr);
      return "${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}";
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    return Scaffold(
      drawer: AppDrawer(currentPage: widget.currentPage),
      appBar: CustomAppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by name...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: filterLeaveData,
                  ),
                ),
                Expanded(
                  child: filteredLeaveData.isEmpty
                      ? Center(
                          child: Text(
                            'No leave data found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredLeaveData.length,
                          itemBuilder: (context, index) {
                            final leave = filteredLeaveData[index];
                            DateTime fromDate =
                                DateTime.tryParse(leave['from_date'] ?? '') ??
                                    DateTime.now();
                            DateTime toDate =
                                DateTime.tryParse(leave['to_date'] ?? '') ??
                                    fromDate;

                            String fromMonth =
                                getMonthAbbreviation(fromDate.month);
                            String toMonth = getMonthAbbreviation(toDate.month);
                            String monthLabel = (fromMonth == toMonth)
                                ? fromMonth
                                : "$fromMonth-$toMonth";
                            String dayRange =
                                "${fromDate.day.toString().padLeft(2, '0')} - ${toDate.day.toString().padLeft(2, '0')}";

                            return Card(
                              elevation: 4,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 70,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 6, horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFE3E7ED),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            monthLabel,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueGrey,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            dayRange,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: getStatusColor(
                                                    leave['status']),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                getStatusLabel(leave['status']),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            "User: ${leave['person_name']}",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                              "Location: ${leave['location']}"),
                                          Text(
                                              "From Date: ${formatDate(leave['from_date'])}"),
                                          Text(
                                              "To Date: ${formatDate(leave['to_date'])}"),
                                          Text(
                                              "Reason: ${leave['selected_reason']}"),
                                          Text("Comment: ${leave['reason']}"),
                                          if(toDate.isBefore(today))
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Login Status: ',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: leave['final_approval'] == '1'
                                                      ? 'Extended Leave Approved'
                                                      : 'Extended Leave Approval Pending',
                                                  style: TextStyle(
                                                    color: leave['final_approval'] == '1' ? Colors.green : Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),


                                          SizedBox(height: 8),
                                          if (leave['status'] == '0')
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    changeLeaveStatus(
                                                        leave['id'].toString(),
                                                        '1');
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.green.shade600,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 20,
                                                            vertical: 10),
                                                    elevation: 3,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    textStyle: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  child: Text('Accept'),
                                                ),
                                                SizedBox(width: 12),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    changeLeaveStatus(
                                                        leave['id'].toString(),
                                                        '2');
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.red.shade600,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 20,
                                                            vertical: 10),
                                                    elevation: 3,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    textStyle: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  child: Text('Reject'),
                                                ),
                                              ],
                                            ),
                                          if (toDate.isBefore(today) && leave['status'] == '1') ...[
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  loginApproval(leave['id'].toString());
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blue.shade600,
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                                  elevation: 3,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  textStyle: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                child: Text('Login Approval'),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

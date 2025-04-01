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
  final int currentPage;
  LeaveStatus({required this.currentPage});

  @override
  _LeaveStatusState createState() => _LeaveStatusState();
}

class _LeaveStatusState extends State<LeaveStatus> {

  List<dynamic> leaveData = [];

  // List<dynamic> leaveData = [
  //   {
  //     'id': 1,
  //     'full_name': 'John Doe',
  //     'submitted_on': '2025-01-01',
  //     'from_date': '2025-01-10',
  //     'to_date': '2025-01-15',
  //     'reason': 'Vacation',
  //     'status': '0',
  //   },
  //   {
  //     'id': 2,
  //     'full_name': 'Jane Smith',
  //     'submitted_on': '2025-01-05',
  //     'from_date': '2025-01-20',
  //     'to_date': '2025-01-25',
  //     'reason': 'Conference',
  //     'status': '1',
  //   },
  //   {
  //     'id': 3,
  //     'full_name': 'Jane Smith',
  //     'submitted_on': '2025-01-05',
  //     'from_date': '2025-01-20',
  //     'to_date': '2025-01-25',
  //     'reason': 'Conference',
  //     'status': '2',
  //   },
  // ];

  bool isLoading = true;

  // Variables for user details
  String? username = '';
  String uuid = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';

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



  @override
  void initState() {
    super.initState();
    checkLogin();
    fetchLeaveData().then((data) {
      if (data != null) {
        setState(() {
          leaveData = data;
          isLoading = false; // Data loading is complete
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

  Future<void> changeLeaveStatus(String leaveId, String status) async {
    try {
      await checkLogin();
      final response = await http.post(
        Uri.parse('${URL}change_leave_status'),
        headers: {"Accept": "application/json"},
        body: {
          // 'uuid': _uuid,
        'user_id': username,
'uuid':uuid,
          'user_pass': password,
          'id': leaveId,
          'status': status,
          'rejection_note':'Rejected',
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
        print('Failed to change leave status. Status code: ${response.statusCode}');
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
        'uuid':uuid,
        'user_pass': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        print('pooja');
        if (data["status"] == "1" && data.containsKey("user_data") && data["user_data"] is List) {
          setState(() {
            leaveData = data["user_data"] as List;
            leaveData.sort((a, b) => int.parse(b["id"]).compareTo(int.parse(a["id"])));
          });
          return leaveData;
        }
      }
    } catch (e) {
      print('Error: $e');
    }
    return [];
  }

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentPage: widget.currentPage),
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(),
            SizedBox(height: 6.0),
            _buildStatusIndicators(),
            SizedBox(height: 16.0),
            // Leave Data
            if (isLoading)
              Center(
                child: CircularProgressIndicator(),
              )
            else if (leaveData.isNotEmpty)
              _buildScrollableLeaveList(),
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

  Widget _buildScrollableLeaveList() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7, // Set desired height
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: leaveData.length,
        itemBuilder: (context, index) {
          final leave = leaveData[index];
          return _buildLeaveCard(leave, index);
        },
      ),
    );
  }

  Widget _buildHeader() {
    return
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              "Leave Status",
              style: TextStyle(
                fontSize:
                24, // Slightly larger font size for prominence
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      );
  }

  Widget _buildStatusIndicators() {
    return Row(
      children: [
        _buildStatusIndicator(Colors.green, 'Approved'),
        SizedBox(width: 10),
        _buildStatusIndicator(Colors.red, 'Rejected'),
      ],
    );
  }

  Widget _buildStatusIndicator(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return 'No data';
    }
    try {
      DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Widget _buildLeaveCard(dynamic leave, int index) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leave Applicant Info
            _buildLeaveInfoRowName('Leave Applicant:', leave['person_name'], index),
            SizedBox(height: 8.0),
            // Leave Dates and Reason
            _buildLeaveInfoRow('From Date :', formatDate(leave['from_date']), index),
            _buildLeaveInfoRow('To Date :',formatDate(leave['to_date']), index),
            _buildLeaveInfoRow('Selected Reason :', leave['selected_reason'], index),
            _buildLeaveInfoRow('User Comment :', leave['reason'], index),
            SizedBox(height: 12.0),
            // Leave Status and Actions
            _buildStatusRow(leave),
          ],
        ),
      ),
    );
  }




  Widget _buildLeaveInfoRow(String label, String? value, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label',
          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),
        ),
        Text(value ?? 'N/A',style: TextStyle(fontSize: 15),),
      ],
    );
  }
  Widget _buildLeaveInfoRowName(String label, String? value, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            '$label',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        SizedBox(height: 5), // Adds spacing between label and value
        Center(
          child: Text(
            value ?? 'N/A',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(dynamic leave) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status: ${getStatusLabel(leave['status'] ?? '0')}',
          style: TextStyle(
            color: leave['status'] == '0'
                ? Colors.grey
                : leave['status'] == '1'
                ? Colors.green
                : Colors.red,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8.0),
        if (leave['status'] == '0')
          Wrap(
            spacing: 8.0, // Space between buttons
            runSpacing: 8.0, // Space between rows when buttons wrap
            children: [
              ElevatedButton(
                onPressed: () {
                changeLeaveStatus(leave['id'].toString(), '1');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Approve'),
              ),
              ElevatedButton(
                onPressed: () => {
                changeLeaveStatus(leave['id'].toString(), '2')
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reject'),
              ),
            ],
          ),
      ],
    );
  }
}

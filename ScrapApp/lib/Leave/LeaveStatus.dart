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
  List<dynamic> leaveData = [
    {
      'id': 1,
      'full_name': 'John Doe',
      'submitted_on': '2025-01-01',
      'from_date': '2025-01-10',
      'to_date': '2025-01-15',
      'reason': 'Vacation',
      'status': '0',
    },
    {
      'id': 2,
      'full_name': 'Jane Smith',
      'submitted_on': '2025-01-05',
      'from_date': '2025-01-20',
      'to_date': '2025-01-25',
      'reason': 'Conference',
      'status': '1',
    },
    {
      'id': 3,
      'full_name': 'Jane Smith',
      'submitted_on': '2025-01-05',
      'from_date': '2025-01-20',
      'to_date': '2025-01-25',
      'reason': 'Conference',
      'status': '2',
    },
  ];

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

  bool _isloggedin = true;
  String _id = '';
  String _username = '';
  String _full_name = '';
  String _email = '';
  String userImageUrl = '';
  String _user_type = '';
  String _password = '';
  String _uuid = '';

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

  _getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isloggedin = prefs.getBool("loggedin")!;
      _id = prefs.getString('id')!;
      _username = prefs.getString('username')!;
      _full_name = prefs.getString('full_name')!;
      _email = prefs.getString('email')!;
      _user_type = prefs.getString('user_type') ?? '';
      _password = prefs.getString('password') ?? '';
      _uuid = prefs.getString('uuid') ?? '';
    });
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
        setState(() {
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
    await _getUserDetails();
    try {
      final response = await http.post(
        Uri.parse('$URL/Mobile_flutter_api/get_leaves'),
        headers: {"Accept": "application/json"},
        body: {
          'uuid': _uuid,
          'user_id': _username,
          'password': _password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == "1" && data.containsKey("user_data") && data["user_data"] is List) {
          setState(() {
            leaveData = data["user_data"] as List;
          });
          return leaveData;
        }
      }
    } catch (e) {
      print('Error: $e');
    }
    return [];
  }

  @override
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
            SizedBox(height: 16.0),
            // Leave Status Indicators
            _buildStatusIndicators(),
            SizedBox(height: 16.0),
            // Leave Data
            if (leaveData.isNotEmpty) _buildLeaveList(),
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

  Widget _buildHeader() {
    return
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
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

  Widget _buildLeaveList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: leaveData.length,
      itemBuilder: (context, index) {
        final leave = leaveData[index];
        return _buildLeaveCard(leave, index);
      },
    );
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
            _buildLeaveInfoRow('Leave Applicant:', leave['full_name'], index),
            SizedBox(height: 8.0),
            // Leave Dates and Reason
            _buildLeaveInfoRow('From Date:', leave['from_date'], index),
            _buildLeaveInfoRow('To Date:', leave['to_date'], index),
            _buildLeaveInfoRow('Reason:', leave['reason'], index),
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

  Widget _buildStatusRow(dynamic leave) {
    return Row(
      children: [
        Text(
          'Status: ${getStatusLabel(leave['status'] ?? '0')}',
          style: TextStyle(
            color: leave['status'] == '0'
                ? Colors.grey
                : leave['status'] == '1'
                ? Colors.green
                : Colors.red,
              fontSize: 15

          ),
        ),
        Spacer(),
        if (leave['status'] == '0') ...[
          ElevatedButton(
            onPressed: () => changeLeaveStatus(leave['id'].toString(), '1'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green,foregroundColor: Colors.white),
            child: Text('Approve',),
          ),
          SizedBox(width: 8.0),
          ElevatedButton(
            onPressed: () => changeLeaveStatus(leave['id'].toString(), '2'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red,foregroundColor: Colors.white),
            child: Text('Reject'),
          ),
        ],
      ],
    );
  }
}

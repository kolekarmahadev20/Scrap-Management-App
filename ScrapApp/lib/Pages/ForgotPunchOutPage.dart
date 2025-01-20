import 'package:flutter/material.dart';

import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';

class ForgotPunchOutPage extends StatefulWidget {
  final int currentPage;
  ForgotPunchOutPage({required this.currentPage});

  @override
  _ForgotPunchOutPageState createState() => _ForgotPunchOutPageState();
}

class _ForgotPunchOutPageState extends State<ForgotPunchOutPage> {
  final List<Map<String, dynamic>> _users = [
    {
      'id': 1,
      'name': 'John Doe',
      'email': 'johndoe@example.com',
      'role': 'Manager',
      'punchInTime': '2025-01-20 09:30 AM',
      'status': 'Pending',
      'remark': ''
    },
    {
      'id': 2,
      'name': 'Jane Smith',
      'email': 'janesmith@example.com',
      'role': 'Employee',
      'punchInTime': '2025-01-20 10:00 AM',
      'status': 'Pending',
      'remark': ''
    },
    {
      'id': 3,
      'name': 'Alice Johnson',
      'email': 'alicej@example.com',
      'role': 'Team Lead',
      'punchInTime': '2025-01-20 08:45 AM',
      'status': 'Pending',
      'remark': ''
    },
  ];

  final TextEditingController _remarkController = TextEditingController();

  void _updateUserStatus(int userId, String status, [String? remark]) {
    setState(() {
      final user = _users.firstWhere((user) => user['id'] == userId);
      user['status'] = status;
      if (remark != null) user['remark'] = remark;
    });
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${user['name']} (ID: ${user['id']})',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Email: ${user['email']}'),
            Text('Role: ${user['role']}'),
            Text('Punch In Time: ${user['punchInTime']}'),
            SizedBox(height: 8),
            Text('Status: ${user['status']}'),
            if (user['status'] == 'Pending') ...[
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _updateUserStatus(user['id'], 'Allowed');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Allow Login'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _updateUserStatus(user['id'], 'Denied');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Deny'),
                  ),
                ],
              ),
            ],
            if (user['status'] == 'Allowed') ...[
              SizedBox(height: 8),
              TextField(
                controller: _remarkController,
                onChanged: (value) {
                  // Optionally update remark as text changes
                },
                decoration: InputDecoration(
                  labelText: 'Enter Remark',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _updateUserStatus(user['id'], 'Allowed', _remarkController.text);
                  // Optionally clear the remark input
                  _remarkController.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text('Submit Remark'),
              ),
            ],
            if (user['remark'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Remark: ${user['remark']}'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentPage: 0),
      appBar: CustomAppBar(),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          return _buildUserCard(_users[index]);
        },
      ),
    );
  }
}



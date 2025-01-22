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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  user['name'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    user['status'],
                    style: TextStyle(
                      color: user['status'] == 'Pending'
                          ? Colors.orange
                          : (user['status'] == 'Allowed'
                          ? Colors.green
                          : Colors.red),
                    ),
                  ),
                  backgroundColor: user['status'] == 'Pending'
                      ? Colors.orange.shade100
                      : (user['status'] == 'Allowed'
                      ? Colors.green.shade100
                      : Colors.red.shade100),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Email: ${user['email']}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            Text(
              'Role: ${user['role']}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            Text(
              'Punch In Time: ${user['punchInTime']}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            if (user['remark'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Remark: ${user['remark']}',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            Divider(height: 20),
            if (user['status'] == 'Pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _showRemarkDialog(user['id']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                      foregroundColor : Colors.white,
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

  void _showRemarkDialog(int userId) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController remarkController = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text('Enter Remark'),
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
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (remarkController.text.isNotEmpty) {
                  _updateUserStatus(userId, 'Allowed', remarkController.text);
                  Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentPage: widget.currentPage),
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

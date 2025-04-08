import 'dart:convert';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';
import '../URL_CONSTANT.dart';

class EmployeeAttendanceReport extends StatefulWidget {
  final int currentPage;
  const EmployeeAttendanceReport({required this.currentPage});

  @override
  State<EmployeeAttendanceReport> createState() => _EmployeeAttendanceReportState();
}

class _EmployeeAttendanceReportState extends State<EmployeeAttendanceReport> {
  String selectedEmployeeId = '';
  DateTime selectedDate = DateTime.now();
  List<Map<String, String>> employees = [];

  String? username = '';
  String uuid = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';

  List<dynamic> employeeList = [];
  Map<String, dynamic>? loginRecord;
  Map<String, dynamic>? logoutRecord;

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
    checkLogin();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    uuid = prefs.getString("uuid") ?? '';
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
  }

  Future<void> _fetchDropdownData() async {
    await checkLogin();
    final url = '${URL}get_dropdown';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'user_id': username,
        'uuid': uuid,
        'user_pass': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        employees = List<Map<String, String>>.from(data['users'].map((x) => {
          'id': x['person_id']?.toString() ?? '',
          'full_name': x['person_name']?.toString() ?? '',
          'username': x['uname']?.toString() ?? '',
        }));
      });
    } else {
      throw Exception('Failed to load dropdown data');
    }
  }

  List<Map<String, dynamic>> attendanceData = [];

  Future<void> _fetchUserData() async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    await checkLogin();

    final url = '${URL}get_user_attendance_report';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'user_id': username,
        'uuid': uuid,
        'user_pass': password,
        'date': formattedDate,
        // if (selectedEmployeeId.isNotEmpty)
          'admin_id': selectedEmployeeId,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == "1") {
        setState(() {
          attendanceData = List<Map<String, dynamic>>.from(data['data']);
          print(attendanceData);
          print("attendanceData");

        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data.')),
      );
    }
  }

  Widget buildFieldWithDatePicker(String label, DateTime selectedDate, Function(DateTime) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label),
        SizedBox(width: 8.0),
        TextButton(
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (picked != null && picked != selectedDate) {
              onChanged(picked);
            }
          },
          child: Text(
            "${selectedDate.toLocal()}".split(' ')[0],
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget buildSearchableDropdown(
      String label,
      String? value,
      Function(String) onChanged,
      List<Map<String, String>> employees,
      TextEditingController controller,
      ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8.0),
          TypeAheadFormField<Map<String, String>>(
            textFieldConfiguration: TextFieldConfiguration(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Select an employee',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                suffixIcon: IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
              ),
            ),
            suggestionsCallback: (pattern) {
              final suggestions = employees.where((employee) {
                return employee['full_name']!
                    .toLowerCase()
                    .contains(pattern.toLowerCase()) ||
                    employee['username']!
                        .toLowerCase()
                        .contains(pattern.toLowerCase());
              }).toList();

              return suggestions;
            },
            itemBuilder: (context, Map<String, String> suggestion) {
              return ListTile(
                title: Text('${suggestion['full_name']} - (${suggestion['username']})'),
              );
            },
            onSuggestionSelected: (Map<String, String> suggestion) {
              controller.text = '${suggestion['full_name']} - (${suggestion['username']})';
              onChanged(suggestion['id']!);
            },
          ),
        ],
      ),
    );
  }

  final TextEditingController _employeeController = TextEditingController();

  String formatStatus(String status) {
    return status
        .split(' ')
        .map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '')
        .join(' ');
  }
  String formatDateTime(String dateTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString);
      final String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
      final String formattedTime = DateFormat('hh:mm a').format(dateTime);
      return '$formattedDate $formattedTime';
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _formatAttendanceData(List<Map<String, dynamic>> data) {
    final buffer = StringBuffer();

    buffer.writeln('📝 Attendance Report');
    buffer.writeln('Date: ${DateTime.now().toLocal().toString().split(' ').first}');
    buffer.writeln('============================================');

    for (var entry in data) {
      final login = entry['login_record'];
      final logout = entry['logout_record'];

      final name = login['username'] ?? '-';
      final date = login['attendance_datetime']?.split(' ')?.first ?? '-';
      final timeIn = login['login_time'] ?? '-';
      final timeOut = logout?['logout_time'] ?? '-';
      final status = logout != null ? 'Logged In & Out' : 'Logged In Only';

      // Padding each line for consistent alignment
      buffer.writeln('${'Name :'.padRight(10)}${name.padRight(25)}');
      buffer.writeln('${'Date :'.padRight(12)}${date.padRight(25)}');
      buffer.writeln('${'In :'.padRight(15)}${timeIn.padRight(28)}');
      buffer.writeln('${'Out :'.padRight(12)}${timeOut.padRight(28)}');
      buffer.writeln('${'Status :'.padRight(10)}${status.padRight(17)}');


      buffer.writeln('--------------------------------------------');
    }

    return buffer.toString();
  }


  Widget buildUserAttendanceReport({
    required List<Map<String, dynamic>> attendanceData,
  }) {
    return SingleChildScrollView(
      // padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "📋 Attendance Report",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              IconButton(
                icon: Icon(Icons.copy, color: Colors.blue),
                tooltip: 'Copy All Attendance',
                onPressed: () {
                  String formattedData = _formatAttendanceData(attendanceData);
                  FlutterClipboard.copy(formattedData).then((value) =>
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Copied all attendance to clipboard!')),
                      ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          for (final record in attendanceData) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.indigo.withOpacity(0.3)),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// User Header
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.indigo),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          record['login_record']?['username'] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20, thickness: 1),

                  /// Login Card
                  if (record['login_record'] != null)
                    _customReportCard(
                      title: "Login Details",
                      dateTime: formatDateTime(record['login_record']['login_time'] ?? 'NA'),
                      project: "Location: ${record['login_record']['address'] ?? 'NA'}",
                      status: formatStatus(record['login_record']['attendance_type'] ?? 'InProgress'),
                      borderColor: Colors.green,
                    ),

                  /// Logout Card
                  if (record['logout_record'] != null)
                    _customReportCard(
                      title: "Logout Details",
                      dateTime: formatDateTime(record['login_record']['login_time'] ?? 'NA'),
                      project: "Address: ${record['logout_record']['address'] ?? 'NA'}",
                      status: formatStatus(record['logout_record']['attendance_type'] ?? 'InProgress'),
                      borderColor: Colors.red,
                    )
                  else
                    _customReportCard(
                      title: "Logout Details",
                      dateTime: "-",
                      project: "Address: Not yet logged out",
                      status: "Pending",
                      borderColor: Colors.orange,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }




  Widget _customReportCard({
    required String title,
    required String dateTime,
    required String project,
    required String status,
    required Color borderColor,
  }) {
    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'logged in':
          return Colors.green;
        case 'logged out':
          return Colors.red;
        default:
          return Colors.orange;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: borderColor, width: 6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: getStatusColor(status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: getStatusColor(status),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    dateTime,
                    style: const TextStyle(color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(project, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentPage: widget.currentPage),
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildSearchableDropdown(
                "Employee Name:",
                selectedEmployeeId,
                    (value) {
                  setState(() {
                    selectedEmployeeId = value;
                  });
                },
                employees,
                _employeeController,
              ),
              SizedBox(height: 8.0),
              buildFieldWithDatePicker(
                'Date:',
                selectedDate,
                    (DateTime selectedDate) {
                  setState(() {
                    this.selectedDate = selectedDate;
                  });
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _fetchUserData,
                child: Text('Get Data'),
              ),
              SizedBox(height: 5),
              attendanceData.isNotEmpty
                  ? buildUserAttendanceReport(attendanceData: attendanceData)
                  : const Text("No attendance data found."),
            ],
          ),
        ),
      ),
    );
  }
}

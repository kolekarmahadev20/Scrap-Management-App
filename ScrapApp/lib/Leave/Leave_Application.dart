import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:scrapapp/Pages/StartPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';
import '../URL_CONSTANT.dart';
import 'package:flutter/services.dart';

class LeaveApplication extends StatefulWidget {
  final int currentPage;
  LeaveApplication({required this.currentPage});

  @override
  _LeaveApplicationState createState() => _LeaveApplicationState();
}

class _LeaveApplicationState extends State<LeaveApplication> {
  List<dynamic> leaveData = [];
  List<dynamic> leaveDatas = [];


  // Controller Declarations
  TextEditingController locationController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController authController = TextEditingController();

  // Variables for user details
  String? username = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';

  DateTime? fromDate;
  DateTime? toDate;

  // State variables
  String? selectedAuthorizationby = '0'; // Default value for "All Location"
  Map<String, String> AuthorizationByType = {'Select': '0'};

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
    fetchLeaveData();
    fetchUserLeave();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
  }

  Future<void> _submitLeave() async {
    // Validate fields
    if (locationController.text.isEmpty ||
        fromDate == null ||
        toDate == null ||
        reasonController.text.isEmpty ||
        selectedAuthorizationby == '0' ||
        contactController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please fill in all fields and ensure dates are selected",
      );
      return;
    }

    // Ensure fromDate is before toDate
    if (fromDate!.isAfter(toDate!)) {
      Fluttertoast.showToast(
        msg: "From Date cannot be after To Date",
      );
      return;
    }

    await checkLogin();
    final url = '${URL}submit_leave';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'user_id': username,
        'user_pass': password,
        'location_id': locationController.text,
        'from_date': fromDate != null ? fromDate?.toLocal().toString() : '',
        'to_date': toDate != null ? toDate?.toLocal().toString() : '',
        'reason': reasonController.text,
        'contact_no': contactController.text,
        'authorised_by': selectedAuthorizationby.toString(),
      },
    );

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      final data = json.decode(response.body);
      if (data['status'] == "1") {
        fetchUserLeave();

        // Display success message
        Fluttertoast.showToast(
          msg: data['msg'] ?? "Leave submitted successfully!",
        );

        // Clear fields and notify the UI
        setState(() {
          locationController.clear();
          reasonController.clear();
          contactController.clear();
          fromDate = null;
          toDate = null;
        });
      } else {
        // Display error message if status is not "1"
        Fluttertoast.showToast(
          msg: data['msg'] ?? "Failed to submit leave",
        );
      }
    } else {
      throw Exception('Failed to load dropdown data');
    }
  }

  Future<List<dynamic>> fetchUserLeave() async {
    await checkLogin();
    try {
      final response = await http.post(
        Uri.parse('${URL}user_leaves'),
        headers: {"Accept": "application/json"},
        body: {
          // 'uuid': _uuid,
          'user_id': username,
          'user_pass': password,
          // 'person_id':'92'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        print('pooja');
        if (data["status"] == "1" && data.containsKey("user_data") && data["user_data"] is List) {
          setState(() {
            leaveDatas = data["user_data"] as List;
          });
          return leaveDatas;
        }
      }
    } catch (e) {
      print('Error: $e');
    }
    return [];
  }


  Future<List<dynamic>> fetchLeaveData() async {
    await checkLogin();
    try {
      final response = await http.post(
        Uri.parse('${URL}authorized_by'),
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'user_pass': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);

        setState(() {
          // Keep "All Location" as the first option
          AuthorizationByType = {'Select': '0'};
          for (var location in data['user_data']) {
            AuthorizationByType[location['person_name']] = location['emp_person_id'];
          }
        });

        if (data["status"] == "1") {
          if (data.containsKey("user_data") && data["user_data"] is List) {
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
        print(
            'Failed to fetch leave data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return [];
  }

  Widget buildFieldWithDatePicker(
    String label,
    DateTime? selectedDate,
    void Function(DateTime?) onDateChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final newSelectedDate = await showDatePicker(
                        context:
                            context, // Make sure you have access to the context
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (newSelectedDate != null) {
                        onDateChanged(newSelectedDate);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDate != null
                                ? '${selectedDate.toLocal()}'.split(' ')[0]
                                : 'Select Date',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            size: 19.0, // Adjust the size as needed
                          ), // Calendar icon
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3, // Fixed width for the label, adjust as needed
            child: Text(
              labelText,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDropdown(String label, Map<String, String> options,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: selectedAuthorizationby, // Set the default value
              items: options.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.value, // Return ID
                  child: Text(entry.key), // Display name
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: AppDrawer(currentPage: widget.currentPage),
        appBar: CustomAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Leave Application",
                        style: TextStyle(
                          fontSize:
                              26, // Slightly larger font size for prominence
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                _buildTextField("Location From", locationController),
                buildFieldWithDatePicker(
                  'From Date',
                  fromDate,
                  (selectedDate) {
                    setState(() {
                      fromDate = selectedDate;
                    });
                  },
                ),
                buildFieldWithDatePicker(
                  'To Date',
                  toDate,
                  (selectedEndDate) {
                    setState(() {
                      toDate = selectedEndDate;
                    });
                  },
                ),
                _buildTextField("Reason", reasonController),
                _buildTextField("Contact Number", contactController),
                buildDropdown(
                  "Approved by",
                  AuthorizationByType,
                  (value) {
                    setState(() {
                      selectedAuthorizationby = value;
                      print("Selected Location ID: $selectedAuthorizationby");
                    });
                  },
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _submitLeave();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueGrey[400], // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Rounded corners
                      ),
                      elevation: 5,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8), // Consistent padding
                    ),
                    child: Text('Submit'),
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Leave Application",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                if (leaveDatas.isNotEmpty)
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                        ),
                        columnSpacing: 20,
                        columns: [
                          DataColumn(
                              label: Text('Sr No.',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Emp Name',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Apply Date',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Status',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('From Date',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16))),
                          DataColumn(
                              label: Text('To Date',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16))),
                          DataColumn(
                              label: Text('Reason',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16))),
                        ],
                        rows: List<DataRow>.generate(
                          leaveDatas.length,
                          (index) => DataRow(
                            color: MaterialStateColor.resolveWith(
                                (Set<MaterialState> states) {
                              return index % 2 == 0
                                  ? Colors.white
                                  : Colors.transparent;
                            }),
                            cells: [
                              DataCell(Text((index + 1).toString())),
                              DataCell(
                                  Text(leaveDatas[index]['person_name'] ?? '')),
                              DataCell(
                                  Text(leaveDatas[index]['submitted_on'] ?? '')),
                              DataCell(
                                Text(
                                  getStatusLabel(
                                      leaveDatas[index]['status'] ?? '0'),
                                  style: TextStyle(
                                    color: leaveDatas[index]['status'] == '0'
                                        ? Colors.grey
                                        : leaveDatas[index]['status'] == '1'
                                            ? Colors.green
                                            : leaveDatas[index]['status'] == '2'
                                                ? Colors.red
                                                : Colors.black,
                                  ),
                                ),
                              ),
                              DataCell(
                                  Text(leaveDatas[index]['from_date'] ?? '')),
                              DataCell(Text(leaveDatas[index]['to_date'] ?? '')),
                              DataCell(Text(leaveDatas[index]['reason'] ?? '')),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (leaveDatas.isEmpty)
                  Center(
                      child: Text(
                    'No Data Found',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              ],
            ),
          ),
        ));
  }
}

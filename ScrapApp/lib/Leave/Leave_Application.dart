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

  String? selectedAuthorizationby;

  // Data for dropdowns
  Map<String, String> AuthorizationByType = {
    'Select': 'Select',
    'Received Payment': 'P',
    'Received EMD': 'E',
    'Received CMD': 'C',
  };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    checkLogin();
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
        'from_date':fromDate != null ? fromDate?.toLocal().toString() : '',
        'to_date': toDate != null ? toDate?.toLocal().toString() : '',
        'reason': reasonController.text,
        'contact_no': contactController.text,
        'authorised_by': '10',
      },
    );

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      final data = json.decode(response.body);
      if (data['status'] == "1") {
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


  Widget buildFieldWithDatePicker(String label, DateTime? selectedDate,
      void Function(DateTime?) onDateChanged,) {
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
                        context: context, // Make sure you have access to the context
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
            flex: 3,// Fixed width for the label, adjust as needed
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

  Widget buildDropdown(String label, Map<String, String> options, ValueChanged<String?> onChanged) {
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
              value: options.keys.first,
              items: options.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.value,
                  child: Text(entry.key),
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
                          fontSize: 26, // Slightly larger font size for prominence
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                _buildTextField("Location From", locationController),
                buildFieldWithDatePicker('From Date',
                  fromDate,
                      (selectedDate) {
                    setState(() {
                      fromDate = selectedDate;
                    });
                  },
                ),
                buildFieldWithDatePicker('To Date',
                  toDate,
                      (selectedEndDate) {
                    setState(() {
                      toDate = selectedEndDate;
                    });
                  },
                ),
                _buildTextField("Reason", reasonController),
                _buildTextField("Contact Number", contactController),
                buildDropdown("Approved by", AuthorizationByType, (value) {
                  setState(() {
                    selectedAuthorizationby = value;
                  });
                }),
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
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                      ),
                      elevation: 5,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Consistent padding
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

                
              ],
            ),
          ),
        )
    );

  }

}

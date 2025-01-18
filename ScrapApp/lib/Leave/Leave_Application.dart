import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:scrapapp/Pages/StartPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class AuthorizedName {
  final int id;
  final String fullName;

  AuthorizedName({required this.id, required this.fullName});
}

class _LeaveApplicationState extends State<LeaveApplication> {
  // Controller Declarations
  TextEditingController locationController = TextEditingController();
  TextEditingController fromdateController = TextEditingController();
  TextEditingController todateController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController authController = TextEditingController();
  TextEditingController otherempController = TextEditingController();
  List<dynamic> leaveData = [];

  // Add a boolean variable to track if data is being loaded
  bool isLoading = true;

  getStatusLabel(String status) {
    if (status != '-1'){

      if(status == '0'){
        return 'Pending';

      }else if(status == '1'){
        return 'Approved';

      }else if (status == '2'){
        return 'Rejected';
      }
      else{
        return'null' ;

      }

    }
  }
  final RegExp phoneRegex = RegExp(r'^[0-9]{10}$');

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

  bool _isSubmitButtonEnabled = false;
  String? a='';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<AuthorizedName> authorizedNames = [];
  int? selectedAuthorizedName; // Updated to accept an integer ID

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
    fetchAuthorizedNames().then((names) {
      if (names!= null) {
        setState(() {
          authorizedNames = names;
        });
      }

    });
  }

  @override
  void dispose() {
    locationController.dispose();
    fromdateController.dispose();
    todateController.dispose();
    reasonController.dispose();
    contactController.dispose();
    authController.dispose();
    otherempController.dispose();
    super.dispose();
  }

  // Function to check if all required fields are filled
  bool _isFormValid() {
    return locationController.text.isNotEmpty &&
        fromdateController.text.isNotEmpty &&
        todateController.text.isNotEmpty &&
        reasonController.text.isNotEmpty &&
        contactController.text.isNotEmpty;
  }

  // Function to enable or disable the Submit button
  void _updateSubmitButtonState() {
    setState(() {
      _isSubmitButtonEnabled = _isFormValid();
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
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => StartPage()));
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
          // Other necessary parameters
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);

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
        print('Failed to fetch leave data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return [];
  }


  Future<List<AuthorizedName>> fetchAuthorizedNames() async {
    await _getUserDetails(); // Ensure you have user details
    try {
      final response = await http.post(
        Uri.parse('$URL/Mobile_flutter_api/authorized_by'),
        headers: {"Accept": "application/json"},
        body: {
          'uuid': _uuid,
          'user_id': _username,
          'password': _password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["status"] == "1") {
          if (data.containsKey("user_data") && data["user_data"] is List) {
            final usersData = data["user_data"] as List;
            return usersData.map((userData) {
              return AuthorizedName(
                id: int.parse(userData['id']),
                fullName: userData['full_name'] as String,
              );
            }).toList();
          } else {
            print('No valid "users" data found in the response');
            return [];
          }
        } else {
          print('Status is not 1 in the response');
          return [];
        }
      } else {
        print('Failed to fetch Dropdown API. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<bool> _onWillPop() async {
    bool exit = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    );

    if (exit != null && exit) {
      SystemNavigator.pop(); // Exit the app
    }

    return exit ?? false;
  }

  @override
  Widget build(BuildContext context) {

    // Filter leaveData based on the currently logged-in user's ID
    // List<dynamic> userLeaveData = leaveData.where((leave) => leave['user_id'] == _id).toList();

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

                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.menu_book,
                      color: Colors.blue.shade900,
                      size: 35,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Leave Application',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRichText('Location From'),
                    SizedBox(width: 5.0),
                    Expanded(
                      child: _buildBorderedInput(
                        controller: locationController,
                        hintText: 'Your Location',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRichText('From Date'),
                    SizedBox(width: 35.0),
                    Expanded(
                      child: _buildBorderedInputWithDatePicker(
                        controller: fromdateController,
                        hintText: 'From Date',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRichText('To Date'),
                    SizedBox(width: 59.0),
                    Expanded(
                      child: _buildBorderedInputWithDatePicker(
                        controller: todateController,
                        hintText: 'To Date',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRichText('Reason'),
                    SizedBox(width: 60.0),
                    Expanded(
                      child: _buildBorderedInput(
                        controller: reasonController,
                        hintText: 'Reason',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRichText('Contact No'),
                    SizedBox(width: 32.0),
                    Expanded(
                      child: Container(
                        width: 200,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        child: TextFormField(
                          controller: contactController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                            hintText: 'Your Personal Contact Number',
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a contact number';
                            }
                            if (!phoneRegex.hasMatch(value)) {
                              return 'Please enter a valid 10-digit contact number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRichText('Authorized By'),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: Container(
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1.0,
                          ),
                        ),
                        child: Center(
                          child: DropdownButton<int>(
                            value: selectedAuthorizedName, // Set this to a valid default value
                            onChanged: (int? newValue) {
                              setState(() {
                                selectedAuthorizedName = newValue;
                                _updateSubmitButtonState();
                              });
                            },
                            items: authorizedNames.map((AuthorizedName authorizedName) {
                              return DropdownMenuItem<int>(
                                value: authorizedName.id,
                                child: Text(authorizedName.fullName),
                              );
                            }).toList(),
                            isExpanded: true,
                            hint: Center(child: Text('Select')),
                            underline: Container(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Other Emp',style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    )),
                    SizedBox(width: 54.0),
                    Expanded(
                      child: _buildBorderedInput(
                        controller: otherempController,
                        hintText: 'Other Emp',
                      ),
                    ),
                  ],
                ),
                Text(
                  'Enter Value Only When Apply Leave For Other',
                  style: TextStyle(color: Colors.red, fontSize: 11),
                ),
                SizedBox(height: 16.0),
                Center(
                  child: Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitButtonEnabled
                          ? () {
                        if (_formKey.currentState!.validate()) {
                          // Assuming `selectedAuthorizedName` is defined somewhere
                          submitLeaveApplication(selectedAuthorizedName);
                          showDialog(
                            context: context,
                            barrierDismissible: false, // Prevent user from dismissing the dialog
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16.0),
                                    Text("Submitting..."),
                                  ],
                                ),
                              );
                            },
                          );
                          // Simulate a 2-second delay (replace this with your actual logic)
                          Future.delayed(Duration(seconds: 2), () async {
                            // Remove the loading indicator
                            Navigator.pop(context);
                            // Navigate to the next screen
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => LeaveApplication()),
                            // );
                          });
                        }
                      }
                          : null,
                      child: Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50.0), // Increase the height
                        padding: EdgeInsets.symmetric(vertical: 16.0), // Adjust vertical padding
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16.0),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.menu_book,
                        color: Colors.blue.shade900,
                        size: 32, // Adjust the icon size as needed
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Leave Application',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
                if (leaveData.isNotEmpty)
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                        ),
                        columnSpacing: 20,
                        columns: [
                          DataColumn(label: Text('Sr No.', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Emp Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Apply Date', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('From Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                          DataColumn(label: Text('To Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                          DataColumn(label: Text('Reason', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                        ],
                        rows: List<DataRow>.generate(
                          leaveData.length,
                              (index) => DataRow(
                            color: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                              return index % 2 == 0 ? Colors.white : Colors.transparent;
                            }),
                            cells: [
                              DataCell(Text((index + 1).toString())),
                              DataCell(Text(leaveData[index]['full_name'] ?? '')),
                              DataCell(Text(leaveData[index]['submitted_on'] ?? '')),
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
                              DataCell(Text(leaveData[index]['from_date'] ?? '')),
                              DataCell(Text(leaveData[index]['to_date'] ?? '')),
                              DataCell(Text(leaveData[index]['reason'] ?? '')),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 16.0),

                if (leaveData.isEmpty && !isLoading)
                  Center(child: Text('No Data Found',style: TextStyle(fontWeight: FontWeight.bold),)),
              ],
            ),
          ),
        )
    );

  }

  Future<void> submitLeaveApplication(int? selectedAuthorizedName) async {
    try {
      await _getUserDetails();

      final response = await http.post(
        Uri.parse('$URL/Mobile_flutter_api/submit_leave'),
        headers: {"Accept": "application/json"},
        body: {
          'uuid': _uuid,
          'user_id': _username,
          'password': _password,
          'location_id': locationController.text,
          'from_date': fromdateController.text,
          'to_date': todateController.text,
          'reason': reasonController.text,
          'contact_no': contactController.text,
          'authorised_by': selectedAuthorizedName.toString(),
          'other_emp': otherempController.text,
        },
      );

      if (response.statusCode == 200) {
        // Clear form fields
        locationController.clear();
        fromdateController.clear();
        todateController.clear();
        reasonController.clear();
        contactController.clear();
        authController.clear();
        otherempController.clear();

        // Fetch updated leave data after submission
        await fetchLeaveData();

        // Print response data if needed
        final responseData = json.decode(response.body);
        print(responseData);
      } else {
        print('Failed to submit the form. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> changeLeaveStatus(String leaveId, String status) async {
    try {
      await _getUserDetails();

      print("bharat");
      print(_id);

      final response = await http.post(
        Uri.parse('$URL/Mobile_flutter_api/change_leave_status'),
        headers: {"Accept": "application/json"},
        body: {
          'uuid': _uuid,
          'user_id': _username,
          'password': _password,
          'status': status,
          'leave_id': '',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
        // Handle the response data as needed
      } else {
        print('Failed to change leave status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }



  Widget _buildBorderedInput({
    required TextEditingController controller,
    required String hintText,
    double width = 100.0,
    double height = 40.0,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(0.0),
      ),
      child: TextFormField(
        controller: controller,
        onChanged: (value) {
          _updateSubmitButtonState();
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildBorderedInputWithDatePicker({
    required TextEditingController controller,
    required String hintText,
    double width = 200.0,
    double height = 40.0,
  }) {
    return GestureDetector(
      onTap: () {
        _selectDate(controller);
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(0.0),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                controller: controller,
                enabled: false, // Disable text field to prevent keyboard from showing
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                  hintText: hintText,
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () {
                _selectDate(controller);
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildRichText(String labelText) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: labelText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: '*  ',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // Function to show a date picker
  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
}

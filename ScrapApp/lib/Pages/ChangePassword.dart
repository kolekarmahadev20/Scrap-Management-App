import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scrapapp/URL_CONSTANT.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  FocusNode _oldPasswordFocus = FocusNode();
  FocusNode _newPasswordFocus = FocusNode();
  FocusNode _confirmPasswordFocus = FocusNode();

  bool isLoading = false;
  String _errorText = '';
  String correctOldPassword = ''; // Replace with the actual old password


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


  @override
  void initState() {
    super.initState();
    _getUserDetails();
    // correctOldPassword = _password;

  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _oldPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  //Fetching user details from sharedpreferences
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

    }else {
      // If the user is logged in, proceed to load the correct old password
      correctOldPassword = _password;
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {

      var data = {
        'uuid': _uuid,
        'user_id': _username,
        'password': _password,
        'new_password' :_newPasswordController.text
      };

      final response = await http.post(Uri.parse('${URL}/Mobile_flutter_api/change_password'),
          headers: {"Accept": "application/json"},
          body: data);

      if (kDebugMode)
      {
        print(response.body);
      }

      var resStr = json.decode(response.body);

      if (resStr['status'] == '1') {
        setState(() {
          isLoading = false;
          _oldPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          _errorText = ''; // Clear the error message
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password changed successfully!'),
            duration: Duration(seconds: 2), // Adjust the duration as needed
          ),
        );
      }
      else
      {
        setState(() {
          final error = resStr['error'];
          isLoading = false;
          _errorText = 'Password update failed. Error: $error';
        });
      }

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
    return Scaffold(
      drawer: AppDrawer(currentPage: 0),
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock,
                      color: Colors.blue.shade900,
                      size: 40, // Adjust the icon size as needed
                    ),
                    SizedBox(width: 25),
                    Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
                Card(
                  elevation: 5,
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        TextFormFieldCard(
                          label: 'Old Password',
                          controller: _oldPasswordController,
                          focusNode: _oldPasswordFocus,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your old password.';
                            }
                            if (value != correctOldPassword) {
                              return 'Incorrect old password.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormFieldCard(
                          label: 'New Password',
                          controller: _newPasswordController,
                          focusNode: _newPasswordFocus,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your new password.';
                            }
                            // Add additional validation logic here if needed.
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormFieldCard(
                          label: 'Confirm Password',
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocus,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please confirm your new password.';
                            }
                            if (value != _newPasswordController.text) {
                              return 'Passwords do not match.';

                            }
                            return null;
                          },
                        ),
                        Text(
                          _errorText,
                          style: TextStyle(color: Colors.red),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: ElevatedButton(
                            onPressed: () {
                              _submitForm();
                            },
                            child: isLoading? Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              ),
                            )
                                : Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TextFormFieldCard extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? Function(String?)? validator;

  TextFormFieldCard({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.validator,
  });

  @override
  _TextFormFieldCardState createState() => _TextFormFieldCardState();
}

class _TextFormFieldCardState extends State<TextFormFieldCard> {
  Color borderColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(updateBorderColor);
  }

  void updateBorderColor() {
    setState(() {
      borderColor = widget.focusNode.hasFocus
          ? Colors.blue
          : widget.validator != null
          ? Colors.grey
          : Colors.red;
    });
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(updateBorderColor);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              obscureText: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '',
              ),
              validator: widget.validator,
            ),
          ),
        ),
      ],
    );
  }
}

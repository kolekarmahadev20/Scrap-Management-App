import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';
import '../URL_CONSTANT.dart';

class ChangePassword extends StatefulWidget {
  final int currentPage;
  const ChangePassword({required this.currentPage});

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  // final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isOldPasswordObscure = true;
  bool _isNewPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;

  bool isLoading = false;
  String correctOldPassword = '';

  // Variables for user details
  String? username = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    // _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    password = prefs.getString("password");
    print(password);

    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
  }

  Future<void> changePass() async {

    print(username);
    print(password);
    print(_newPasswordController.text);

    try {
      await checkLogin();
      final response = await http.post(
        Uri.parse('${URL}change_password'),
        headers: {"Accept": "application/json"},
        body: {
          // 'uuid': _uuid,
          'user_id': username,
          'user_pass': password,
          'new_password':_newPasswordController.text,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
        print('bharat');
        setState(() {

        });
      } else {
        print('Failed to change leave status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      // Mock API call simulation
      await changePass();
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password changed successfully!'),
          duration: Duration(seconds: 2),
        ),
      );

      _oldPasswordController.clear();
      _newPasswordController.clear();
      // _confirmPasswordController.clear();
    }
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Icon(
                Icons.lock_outline,
                color: Colors.blueGrey[400],
                size: 60,
              ),
              SizedBox(height: 10),
              Text(
                'Update Your Password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey[400],
                ),
              ),
              SizedBox(height: 30),
              _buildPasswordField(
                controller: _oldPasswordController,
                label: "Old Password",
                isObscure: _isOldPasswordObscure,
                onToggle: () {
                  setState(() {
                    _isOldPasswordObscure = !_isOldPasswordObscure;
                  });
                },
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your old password.';
                  }
                  if (value != password) {
                    return 'Incorrect old password.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _buildPasswordField(
                controller: _newPasswordController,
                label: "New Password",
                isObscure: _isNewPasswordObscure,
                onToggle: () {
                  setState(() {
                    _isNewPasswordObscure = !_isNewPasswordObscure;
                  });
                },
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a new password.';
                  }
                  if (value!.length < 6) {
                    return 'Password must be at least 6 characters.';
                  }
                  return null;
                },
              ),
              // SizedBox(height: 20),
              // _buildPasswordField(
              //   controller: _confirmPasswordController,
              //   label: "Confirm Password",
              //   isObscure: _isConfirmPasswordObscure,
              //   onToggle: () {
              //     setState(() {
              //       _isConfirmPasswordObscure = !_isConfirmPasswordObscure;
              //     });
              //   },
              //   validator: (value) {
              //     if (value?.isEmpty ?? true) {
              //       return 'Please confirm your password.';
              //     }
              //     if (value != _newPasswordController.text) {
              //       return 'Passwords do not match.';
              //     }
              //     return null;
              //   },
              // ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.blueGrey[400],
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : const Text(
                  'Change Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isObscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: IconButton(
          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
      ),
      validator: validator,
    );
  }
}

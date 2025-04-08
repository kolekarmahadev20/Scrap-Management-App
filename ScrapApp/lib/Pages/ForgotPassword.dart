import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> _submit() async {
    final email = emailController.text.trim();
    final userId = userIdController.text.trim();
    final password = passwordController.text.trim();

    // if (email.isEmpty || userId.isEmpty || password.isEmpty) {
    //   _showMessage("Please enter either Email or User ID, and Password.");
    //   return;
    // }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse("http://scrap.systementerprises.in/api/Comp_login/forgot_password");

    Map<String, String> requestBody = {

    };

    // Add only non-empty values
    if (userId.isNotEmpty) {
      requestBody['user_id'] = userId;
    }

    if (password.isNotEmpty) {
      requestBody['user_pass'] = password;
    }

    if (email.isNotEmpty) {
      requestBody['email'] = email;
    }

    final response = await http.post(
      url,
      body: requestBody,
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['status'] == "1") {
        final name = responseData['data']['person_name'];
        final uname = responseData['data']['uname'];
        final c_pass = responseData['data']['c_pass'];
        final empEmail = responseData['data']['emp_email'];

        _showMessage("Success!\nName: $name\nUser ID: $uname\nPassoed: $uname\nEmail: $empEmail");
      } else {
        _showMessage("Failed: ${responseData['message'] ?? 'Unknown error'}");
      }
    } else {
      _showMessage("Server Error: ${response.statusCode}");
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Your Login Credentials"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/images/login.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Icon(
                      Icons.lock_outline,
                      size: 80,
                      color: Colors.pinkAccent,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Please enter either your registered Email or User ID or password to get your login details.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 30),

                    // Email Field
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined),
                        hintText: 'Enter email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),

                    // User ID Field
                    TextField(
                      controller: userIdController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                        hintText: 'Enter User ID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),

                    // Password Field
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline),
                        hintText: 'Enter Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        child: isLoading
                            ? CircularProgressIndicator(color: Colors.black)
                            : Text(
                          'SUBMIT',
                          style: TextStyle(fontSize: 16,color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

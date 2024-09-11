import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ProfilePage.dart';

class StartPage extends StatefulWidget {
  @override
  State<StartPage> createState() => _StartDashBoardPageState();
}

class _StartDashBoardPageState extends State<StartPage>
    with SingleTickerProviderStateMixin {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Color (Mint Cream)
          Container(
            color: Color(0xFFF5FFFA), // Mint Cream
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // App Logo or Icon
                    Icon(
                      Icons.person_pin,
                      size: 100,
                      color: Color(0xFF2F4F4F), // Dark Slate Gray
                    ),
                    SizedBox(height: 40),
                    // Username TextField
                    TextField(
                      controller: usernameController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: Color(0xFF2F4F4F)), // Dark Slate Gray
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email, color: Color(0xFF2F4F4F)), // Dark Slate Gray
                        hintText: 'Username',
                        hintStyle: TextStyle(color: Color(0xFF2F4F4F)), // Dark Slate Gray
                        filled: true,
                        fillColor: Color(0xFFEFEFEF), // Slightly lighter background for inputs
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Password TextField
                    TextField(
                      controller: passwordController,
                      obscureText: _obscureText,
                      style: TextStyle(color: Color(0xFF2F4F4F)), // Dark Slate Gray
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF2F4F4F)), // Dark Slate Gray
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility_off : Icons.visibility,
                            color: Color(0xFF2F4F4F), // Dark Slate Gray
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Color(0xFF2F4F4F)), // Dark Slate Gray
                        filled: true,
                        fillColor: Color(0xFFEFEFEF), // Slightly lighter background for inputs
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      ),
                    ),
                    SizedBox(height: 30),
                    // Log In Button with Sky Blue color scheme
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfilePage()),
                          );
                          },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Color(0xFF2F4F4F), // Dark Slate Gray text
                          backgroundColor: Color(0xFF87CEEB), // Sky Blue background
                          padding: EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Log In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Forgot Password
                    TextButton(
                      onPressed: () {
                        // Handle Forgot Password Logic
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Color(0xFF2F4F4F)), // Dark Slate Gray
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

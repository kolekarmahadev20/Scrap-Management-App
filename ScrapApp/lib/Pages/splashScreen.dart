import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scrapapp/DashBoard/DashBoard.dart';
import 'package:scrapapp/Pages/StartPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ProfilePage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Timer _timer; // Added Timer variable

  @override
  void initState() {
    super.initState();

    // Fade Animation Setup
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 2));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    // Store the Timer instance
    _timer = Timer(Duration(seconds: 3), () {
      _checkLogin();
    });
  }

  Future<void> _checkLogin() async {
    SharedPreferences login = await SharedPreferences.getInstance();
    String? username = login.getString('username');
    String? password = login.getString('password');
    String? userType = login.getString('userType');

    if (username != null && password != null) {
      if (userType == "S") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashBoard(currentPage: 1)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage(currentPage: 2)),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StartPage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel(); // Dispose of the Timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3C72), // Dark Blue
              Color(0xFF2A5298), // Light Blue
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with Fade Animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: Image.asset(
                  'assets/images/logo.jpg',
                  width: 150,
                  height: 150,
                ),
              ),
              SizedBox(height: 20),

              // App Name
              Text(
                "Scrap Management App",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),

              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
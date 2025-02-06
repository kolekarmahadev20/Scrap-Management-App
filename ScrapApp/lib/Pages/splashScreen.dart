import 'package:flutter/material.dart';
import 'package:scrapapp/DashBoard/DashBoard.dart';
import 'package:scrapapp/Pages/StartPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ProfilePage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    SharedPreferences login = await SharedPreferences.getInstance();
    String? username = login.getString('username');
    String? password = login.getString('password');
    String? userType = login.getString('userType');



    if (username != null && password !=null) {
      if (username != null && password != null) {
        // Check userType and navigate accordingly
        if (userType == "S") {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashBoard(currentPage: 1))
          );
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(currentPage: 2))
          );
        }
      }


      // Token exists, auto-login
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>ProfilePage(currentPage: 2,)));
    } else {
      // No token found, navigate to login screen
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>StartPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

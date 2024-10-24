import 'package:flutter/material.dart';
import 'package:scrapapp/DashBoard/DashBoard.dart';
import 'package:scrapapp/Pages/StartPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    if (username != null && password !=null) {
      // Token exists, auto-login
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>DashBoard(currentPage: 2,)));
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

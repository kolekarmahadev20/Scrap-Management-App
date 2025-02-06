import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AttendanceMarkedPage extends StatefulWidget {
  final DateTime? punchTime;
  final DateTime? punchOutTime;

  AttendanceMarkedPage({required this.punchTime,required this.punchOutTime,});

  @override
  State<AttendanceMarkedPage> createState() => _AttendanceMarkedPageState();
}

class _AttendanceMarkedPageState extends State<AttendanceMarkedPage> {
  String? username = '';
 String uuid = '';

  String? password = '';

  String? loginType = '';

  String? userType = '';


  @override
  initState(){
    super.initState();
    checkLogin().then((_){
      setState(() {});
    });
  }

  Future<void> checkLogin() async {
     final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    uuid = prefs.getString("uuid")!;
    uuid = prefs.getString("uuid")!;
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        children: [
          widget.punchTime != null  && DateFormat('yyyy-MM-dd').format(widget.punchTime!) == DateFormat('yyyy-MM-dd').format(DateTime.now())
          ?buildPunchInCard()
          :Container(),
          widget.punchOutTime != null  && DateFormat('yyyy-MM-dd').format(widget.punchOutTime!) == DateFormat('yyyy-MM-dd').format(DateTime.now())
          ?buildPunchOutCard()
          :Container(),
        ],
      )
    );
  }

  Widget buildPunchInCard(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade300, Colors.blue.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 60,
                ),
                SizedBox(height: 10),
                Text(
                  'Punch In Time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.punchTime != null  && DateFormat('yyyy-MM-dd').format(widget.punchTime!) == DateFormat('yyyy-MM-dd').format(DateTime.now())?  DateFormat('hh:mm a').format(widget.punchTime!) : 'You have not logged in for today.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.punchTime != null  && DateFormat('yyyy-MM-dd').format(widget.punchTime!) == DateFormat('yyyy-MM-dd').format(DateTime.now())? DateFormat('EEEE, MMMM d, yyyy').format(widget.punchTime!) : '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPunchOutCard(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade300, Colors.red.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 60,
                ),
                SizedBox(height: 10),
                Text(
                  'Punch Out Time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.punchOutTime != null  && DateFormat('yyyy-MM-dd').format(widget.punchOutTime!) == DateFormat('yyyy-MM-dd').format(DateTime.now())?  DateFormat('hh:mm a').format(widget.punchOutTime!) : 'You have not logged out for today.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.punchOutTime != null  && DateFormat('yyyy-MM-dd').format(widget.punchOutTime!) == DateFormat('yyyy-MM-dd').format(DateTime.now())? DateFormat('EEEE, MMMM d, yyyy').format(widget.punchOutTime!) : '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

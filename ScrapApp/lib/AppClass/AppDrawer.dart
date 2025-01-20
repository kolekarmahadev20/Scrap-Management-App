import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scrapapp/DashBoard/DashBoard.dart';
import 'package:scrapapp/DashBoard/saleOrderList.dart';
import 'package:scrapapp/Dispatch/DispatchList.dart';
import 'package:scrapapp/Pages/ProfilePage.dart';
import 'package:scrapapp/Pages/StartPage.dart';
import 'package:scrapapp/Payment/PaymentList.dart';
import 'package:scrapapp/Refund/RefundList.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Buyer/Buyer_list.dart';
import '../Pages/ChangePassword.dart';
import '../Pages/EmployeeTracker.dart';
import '../Pages/Search.dart';
import '../Pages/SummaryReport.dart';
import '../Users/User_list.dart';
import '../Vendor/Vendor_list.dart';


class AppDrawer extends StatefulWidget {

  final int currentPage ;
  AppDrawer({super.key, required this.currentPage});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? username = '';

  String? password = '';

  String? loginType = '';

  String? userType = '';

  String? person_email = '';

  String? person_name = '';

  @override
  initState(){
    super.initState();
    checkLogin().then((_) {
      setState(() {});  // Rebuilds the widget after `userType` is updated.
    });
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
    person_email = prefs.getString("person_email");
    person_name = prefs.getString("person_name");
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences login = await SharedPreferences.getInstance();
    await login.clear(); // Clear all saved data
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => StartPage()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 5,
      child: Container(
        color: Colors.white, // Background color for the drawer
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blueGrey[700],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 35,
                    child: Icon(
                      Icons.account_circle,
                      size: 70,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          "$person_name",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          "$person_email",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(top: 16),
                children: [
                  _buildDrawerItem(
                    context,
                    1,
                    icon: Icons.dashboard_rounded,
                    text: "Dashboard",
                    onTap: () {
                      Timer(Duration(milliseconds: 300), () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DashBoard(currentPage: 1,)));
                      });

                    },
                  ),
                  _buildDrawerItem(
                    context,
                    2,
                    icon: Icons.person_rounded,
                    text: "Profile",
                    onTap: () {
                      Timer(Duration(milliseconds: 300), () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(currentPage: 2,)));
                      });

                    },
                  ),
                  if(userType == 'S' || userType == 'A')
                  _buildDrawerItem(
                    context,
                    3,
                    icon: Icons.border_outer,
                    text: "Sale Order",
                    onTap: () {
                      Timer(Duration(milliseconds: 300), () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(context, MaterialPageRoute(builder: (context) => saleOrderList(currentPage: 3,)));
                      });

                    },
                  ),
                  _buildDrawerItem(
                    context,
                    4,
                    icon: Icons.payment_rounded,
                    text: "Payment",
                    onTap: () {
                      Timer(Duration(milliseconds: 300), () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentList(currentPage: 4,)));
                      });

                    },
                  ),

                  _buildDrawerItem(
                    context,
                    5,
                    icon: Icons.local_shipping_rounded,
                    text: "Dispatch",
                    onTap: () {
                      Timer(Duration(milliseconds: 300), () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DispatchList(currentPage: 5,)));
                      });
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    6,
                    icon: Icons.money_off_sharp,
                    text: "Refund",
                    onTap: () {
                      Timer(Duration(milliseconds: 300), () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RefundList(currentPage: 6,)));
                      });
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    7,
                    icon: Icons.location_on_outlined,
                    text: "Employee Tracker",
                    onTap: () {
                      Timer(Duration(milliseconds: 300), () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeTrackers(currentPage: 7,)));
                      });
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    8,
                    icon: Icons.business,
                    text: "Vendor",
                    onTap: () {
                      Timer(Duration(milliseconds: 300), () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Vendor_list(currentPage: 8,)));
                      });

                    },
                  ),
                  _buildDrawerItem(
                    context,
                    9,
                    icon: Icons.people_alt,
                    text: "Buyer",
                    onTap: () {
                      Timer(Duration(milliseconds: 300), () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Buyer_list(currentPage: 9,)));
                      });

                    },
                  ),
                  _buildDrawerItem(
                    context,
                    10,
                    icon: Icons.people_alt,
                    text: "Change Password",
                    onTap: () {
                      Timer(Duration(milliseconds: 300), () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePassword(currentPage: 10,)));
                      });

                    },
                  ),
                  _buildDrawerItem(
                    context,
                    11,
                    icon: Icons.people_alt,
                    text: "Summary Report",
                    onTap: () {
                      Timer(Duration(milliseconds: 300), () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SummaryReport(currentPage: 11,)));
                      });

                    },
                  ),
                  _buildDrawerItem(
                    context,
                    12,
                    icon: Icons.people_alt,
                    text: "Users",
                    onTap: () {
                      Timer(Duration(milliseconds: 300), () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(context, MaterialPageRoute(builder: (context) => view_user(currentPage: 12,)));
                      });

                    },
                  ),
                  _buildDrawerItem(
                    context,
                    13,
                    icon: Icons.people_alt,
                    text: "Search",
                    onTap: () {
                      Timer(Duration(milliseconds: 300), () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Search(currentPage: 13,)));
                      });

                    },
                  ),
                  InkWell(
                    onTap:() {
                      Timer(Duration(milliseconds: 300), () {
                        _logout(context);
                      });
                    },
                    splashColor: Colors.indigo[100],
                    highlightColor: Colors.indigo[50],
                    child: ListTile(
                      leading: Icon(Icons.logout_outlined, color: Colors.redAccent, size: 30),
                      title: Text("Logout"),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, int index,{required IconData icon, required String text, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,
        splashColor: Colors.indigo[100],
        highlightColor: Colors.indigo[50],
        child: ListTile(
          leading: Icon(icon, color: widget.currentPage == index ?Colors.blue : Colors.blueGrey[700], size: 30),
          title: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500 , color: widget.currentPage == index ?Colors.blue : Colors.black )),

        ),
      ),
    );
  }
}

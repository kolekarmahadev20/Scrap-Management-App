import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scrapapp/DashBoard/DashBoard.dart';
import 'package:scrapapp/Dispatch/DispatchList.dart';
import 'package:scrapapp/Pages/ProfilePage.dart';
import 'package:scrapapp/Pages/StartPage.dart';
import 'package:scrapapp/Payment/PaymentList.dart';
import 'package:scrapapp/Refund/RefundList.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AppDrawer extends StatelessWidget {



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
      backgroundColor: Color(0xFF6482AD),
      child: Container(
        color: Colors.white, // Background color for the drawer
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Color(0xFF6482AD),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
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
                          "Bunty Jain",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          "bunty.jain@salasarauction.com",
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
                    icon: Icons.person_rounded,
                    text: "Profile",
                    onTap: () {
                      Timer(Duration(milliseconds: 300), () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                      });

                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.dashboard_rounded,
                    text: "Dashboard",
                    onTap: () {
                      Timer(Duration(milliseconds: 300), () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DashBoard()));
                      });

                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.payment_rounded,
                    text: "Payment",
                    onTap: () {
                      Timer(Duration(milliseconds: 300), () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentList()));
                      });

                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.local_shipping_rounded,
                    text: "Dispatch",
                    onTap: () {
                      Timer(Duration(milliseconds: 300), () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DispatchList()));
                      });
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.money_off_sharp,
                    text: "Refund",
                    onTap: () {
                      Timer(Duration(milliseconds: 300), () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RefundList()));
                      });
                    },
                  ),
                ],
              ),
            ),
            Divider(thickness: 1, color: Colors.indigo[900]),
            _buildDrawerItem(
              context,
              icon: Icons.settings,
              text: "Setting",
              onTap: () {
                Timer(Duration(milliseconds: 300), () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => RefundList()));
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
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String text, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.indigo[100],
        highlightColor: Colors.indigo[50],
        child: ListTile(
          leading: Icon(icon, color: Color(0xFF6482AD), size: 30),
          title: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}

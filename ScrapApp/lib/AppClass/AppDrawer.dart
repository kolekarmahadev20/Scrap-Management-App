import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scrapapp/DashBoard/DashBoard.dart';
import 'package:scrapapp/Dispatch/DispatchList.dart';
import 'package:scrapapp/Pages/ProfilePage.dart';
import 'package:scrapapp/Pages/StartPage.dart';
import 'package:scrapapp/Payment/PaymentList.dart';
import 'package:scrapapp/Refund/RefundList.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xFFF5FFFA), // Mint Cream Background Color
      child: Container(
        color: Colors.white, // Background color for the drawer
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF87CEEB), Color(0xFFfadced)], // Primary Blue and Accent Color
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 35,
                    backgroundImage: AssetImage("assets/images/hello_image.webp"),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          "Scrap Management",
                          style: TextStyle(
                            color: Color(0xFF2F4F4F), // Dark Slate Gray Text Color
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          "scrap@gmail.com",
                          style: TextStyle(
                            color: Color(0xFF2F4F4F),
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
            Divider(thickness: 1, color: Color(0xFF2F4F4F)), // Dark Slate Gray Divider
            InkWell(
              onTap: () {
                Timer(Duration(milliseconds: 300), () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => StartPage()),
                        (Route<dynamic> route) => false,
                  );
                });
              },
              splashColor: Colors.indigo[100],
              highlightColor: Colors.indigo[50],
              child: ListTile(
                leading: Icon(Icons.logout_outlined, color: Color(0xFF2F4F4F), size: 23), // Dark Slate Gray Icon
                title: Text("Logout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)), // Dark Slate Gray Text
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
          leading: Icon(icon, color: Color(0xFF87CEEB), size: 23), // Primary Blue Icon
          title: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)), // Dark Slate Gray Text
        ),
      ),
    );
  }
}

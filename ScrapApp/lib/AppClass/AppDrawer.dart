import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:scrapapp/DashBoard/DashBoard.dart';
import 'package:scrapapp/DashBoard/saleOrderList.dart';
import 'package:scrapapp/Pages/ProfilePage.dart';
import 'package:scrapapp/Pages/StartPage.dart';
import 'package:scrapapp/Payment/PaymentList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Leave/LeaveStatus.dart';
import '../Leave/Leave_Application.dart';
import '../Pages/ChangePassword.dart';
import '../Pages/EmployeeAttendanceReport.dart';
import '../Pages/EmployeeTracker.dart';
import '../Pages/ForgotPunchOutPage.dart';
import '../Pages/Search.dart';
import '../Pages/SummaryReport.dart';
import '../URL_CONSTANT.dart';
import '../Users/User_list.dart';
import '../Vendor/Vendor_list.dart';
import 'package:http/http.dart' as http;
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class AppDrawer extends StatefulWidget {

  final int currentPage ;
  AppDrawer({super.key, required this.currentPage});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? username = '';
  String uuid = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';
  String? person_email = '';
  String? person_name = '';
  String? is_active = '';
  String? mob_login = '';
  String? acces_sale_order = '';
  String? acces_dispatch = '';
  String? acces_refund = '';
  String? acces_payment = '';
  String? readonly = '';
  String? attendonly = '';

  String? appVersionID;
  String? personId;
  String? apkURL;

  String? versionID;
  bool _isUpdateAvailable = false;

  @override
  initState(){
    super.initState();
    checkLogin();
    getAppVersion();
    checkLogin().then((_) {
      setState(() {});  // Rebuilds the widget after `userType` is updated.
    });
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    uuid = prefs.getString("uuid")!;
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
    person_email = prefs.getString("person_email");
    person_name = prefs.getString("person_name");
    is_active = prefs.getString("is_active")!;
    mob_login = prefs.getString("mob_login");
    acces_sale_order = prefs.getString("acces_sale_order");
    acces_dispatch = prefs.getString("acces_dispatch");
    acces_refund = prefs.getString("acces_refund");
    acces_payment = prefs.getString("acces_payment");
    readonly = prefs.getString("readonly");
    attendonly = prefs.getString("attendonly");
    appVersionID = prefs.getString("appVersion");
    personId = prefs.getString("personId");
    apkURL = prefs.getString("apkURL");

    print(username);
    print(uuid);
    print(password);
    print(personId);
    print(versionID);
    print(apkURL);

  }

  Future<void> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    versionID = packageInfo.version;

    print('App Name: $appName');
    print('Package Name: $packageName');
    print('Version: $versionID');

    // 🔍 Compare current with latest version
    setState(() {
      _isUpdateAvailable = appVersionID != versionID;
    });
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
                  if(userType == 'S')
                    _buildDrawerItem(
                      context,
                      1,
                      icon: Icons.dashboard_outlined,
                      text: "Dashboard",
                      onTap: () {
                        Timer(Duration(milliseconds: 300), () {
                          Navigator.pop(context); // Close the drawer
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DashBoard(currentPage: 1,)));
                        });

                      },
                    ),
                  // _buildDrawerItem(
                  //   context,
                  //   1,
                  //   icon: Icons.dashboard_outlined,
                  //   text: "Organization",
                  //   onTap: () {
                  //     Timer(Duration(milliseconds: 300), () {
                  //       Navigator.pop(context); // Close the drawer
                  //       Navigator.push(context, MaterialPageRoute(builder: (context) => OrganizationList()));
                  //     });
                  //
                  //   },
                  // ),
                  _buildDrawerItem(
                    context,
                    2,
                    icon: Icons.person_outline,
                    text: "Profile",
                    onTap: () {
                      Timer(Duration(milliseconds: 300), () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(currentPage: 2,)));
                      });

                    },
                  ),
                  // if(userType == 'S' || userType == 'A'|| acces_sale_order == 'Y')
                  if ((userType == 'S' || userType == 'A' || acces_sale_order == 'Y') && attendonly == 'N')
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
                  if(acces_payment == 'Y' && attendonly == 'N')
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
                  // if(acces_dispatch == 'Y')
                  //     _buildDrawerItem(
                  //     context,
                  //     5,
                  //     icon: Icons.local_shipping_outlined,
                  //     text: "Dispatch",
                  //     onTap: () {
                  //       Timer(Duration(milliseconds: 300), () {
                  //         Navigator.pop(context); // Close the drawer
                  //         Navigator.push(context, MaterialPageRoute(builder: (context) => DispatchList(currentPage: 5,)));
                  //       });
                  //     },
                  //   ),
                  // if(acces_refund == 'Y')
                  //   _buildDrawerItem(
                  //   context,
                  //   6,
                  //   icon: Icons.money_off_sharp,
                  //   text: "Refund",
                  //   onTap: () {
                  //     Timer(Duration(milliseconds: 300), () {
                  //       Navigator.pop(context); // Close the drawer
                  //       Navigator.push(context, MaterialPageRoute(builder: (context) => RefundList(currentPage: 6,)));
                  //     });
                  //   },
                  // ),
                  if(userType == 'S')
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
                  if((userType == 'S' || userType == 'A')&& attendonly == 'N')
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
                  // _buildDrawerItem(
                  //   context,
                  //   9,
                  //   icon: Icons.people_alt,
                  //   text: "Buyer",
                  //   onTap: () {
                  //     Timer(Duration(milliseconds: 300), () {
                  //       Navigator.pop(context); // Close the drawer
                  //       Navigator.push(context, MaterialPageRoute(builder: (context) => Buyer_list(currentPage: 9,)));
                  //     });
                  //
                  //   },
                  // ),
                  _buildDrawerItem(
                    context,
                    10,
                    icon: Icons.lock_open,
                    text: "Change Password",
                    onTap: () {
                      Timer(Duration(milliseconds: 300), () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePassword(currentPage: 10,)));
                      });

                    },
                  ),
                  if((userType == 'S' || userType == 'A')&& attendonly == 'N')
                    _buildDrawerItem(
                      context,
                      11,
                      icon: Icons.search,
                      text: "Search",
                      onTap: () {
                        Timer(Duration(milliseconds: 300), () {
                          Navigator.pop(context); // Close the drawer
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Search(currentPage: 11,)));
                        });

                      },
                    ),
                  if(userType == 'S')
                    _buildDrawerItem(
                      context,
                      12,
                      icon: Icons.people_alt_outlined,
                      text: "Users",
                      onTap: () {
                        Timer(Duration(milliseconds: 300), () {
                          Navigator.pop(context); // Close the drawer
                          Navigator.push(context, MaterialPageRoute(builder: (context) => view_user(currentPage: 12,)));
                        });

                      },
                    ),
                  if((userType == 'S' || userType == 'A')&& attendonly == 'N')
                    _buildDrawerItem(
                      context,
                      13,
                      icon: Icons.file_open_outlined,
                      text: "Summary Report",
                      onTap: () {
                        Timer(Duration(milliseconds: 300), () {
                          Navigator.pop(context); // Close the drawer
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Summary_Report(currentPage: 13,)));
                        });

                      },
                    ),
                  if(userType == 'S')
                    _buildDrawerItem(
                      context,
                      17,
                      icon: Icons.assignment_outlined,
                      text: "Attendance Report",
                      onTap: () {
                        Timer(Duration(milliseconds: 300), () {
                          Navigator.pop(context); // Close the drawer
                          Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeAttendanceReport(currentPage: 17)));
                        });

                      },
                    ),
                  _buildDrawerItem(
                    context,
                    14,
                    icon: Icons.free_cancellation_outlined,
                    text: "Leave Application",
                    onTap: () {
                      Timer(Duration(milliseconds: 300), () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LeaveApplication(currentPage: 14,)));
                      });

                    },
                  ),
                  if((userType == 'S' || userType == 'A')&& attendonly == 'N')
                    _buildDrawerItem(
                      context,
                      15,
                      icon: Icons.pending_actions_outlined,
                      text: "Leave Status",
                      onTap: () {
                        Timer(Duration(milliseconds: 300), () {
                          Navigator.pop(context); // Close the drawer
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LeaveStatus(currentPage: 15,)));
                        });

                      },
                    ),
                  if((userType == 'S' || userType == 'A') && attendonly == 'N')
                    _buildDrawerItem(
                      context,
                      16,
                      icon: Icons.access_time,
                      text: "Late Login Remark",
                      onTap: () {
                        Timer(Duration(milliseconds: 300), () {
                          Navigator.pop(context); // Close the drawer
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPunchOutPage(currentPage: 16,)));
                        });

                      },
                    ),

                  _buildDrawerItem(
                    context,
                    17,
                    icon: Icons.system_update,
                    text: "Update App",
                    trailing: _isUpdateAvailable
                        ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'New',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    )
                        : null,
                    onTap: () async {
                      // Ensure the version is updated before launching the APK
                      await updateVersion();  // Make sure the version update is successful

                      print("ASFSAF:$apkURL");
                      final String updateUrl = apkURL!;

                      final intent = AndroidIntent(
                        action: 'action_view',
                        data: updateUrl,
                        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
                      );
                      await intent.launch();
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

  Widget _buildDrawerItem(
      BuildContext context,
      int index, {
        required IconData icon,
        required String text,
        Widget? trailing, // 👈 Add this line
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.indigo[100],
        highlightColor: Colors.indigo[50],
        child: ListTile(
          leading: Icon(
            icon,
            color: widget.currentPage == index ? Colors.blue : Colors.blueGrey[700],
            size: 30,
          ),
          title: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: widget.currentPage == index ? Colors.blue : Colors.black,
            ),
          ),
          trailing: trailing, // 👈 Use it here
        ),
      ),
    );
  }

  updateVersion() async {
    try {
      await checkLogin();
      final response = await http.post(
        Uri.parse('${URL}version_update'),
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid': uuid,
          'user_pass': password,
          "person_id": personId,
          "version": versionID
        },
      );

      print(username);
      print(uuid);
      print(password);
      print(personId);
      print(versionID);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("📊 Decoded Response: $data");

        if (data['status'].toString().toLowerCase() == 'true') {
          print("✅ ${data['message']}");
          setState(() async {
            SharedPreferences login = await SharedPreferences.getInstance();
            await login.clear();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => StartPage()),
                  (Route<dynamic> route) => false,
            );
          });
        } else {
          print("❌ ${data['message']}");
        }
      } else {
        print("⚠️ Failed with status code: ${response.statusCode}");
      }
    } catch (e) {
      print('Error: $e');
    }
  }





}

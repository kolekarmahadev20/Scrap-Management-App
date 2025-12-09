import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Payment/View_Payment_Amount.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Dispatch/View_dispatch_details.dart';
import '../Payment/addPaymentToSaleOrder.dart';
import '../URL_CONSTANT.dart';

class View_payment_detailSale extends StatefulWidget {
  final String sale_order_id;
  final String bidder_id;
  final String branch_id_from_ids;
  final String vendor_id_from_ids;
  final String materialId;

  View_payment_detailSale({
    required this.sale_order_id,
    required this.bidder_id,
    required this.branch_id_from_ids,
    required this.vendor_id_from_ids,
    required this.materialId,
  });

  @override
  State<View_payment_detailSale> createState() =>
      _View_payment_detailSaleState();
}

class _View_payment_detailSaleState extends State<View_payment_detailSale> {
  String? username = '';
  String uuid = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';
  String? readonly = '';
  String? attendonly = '';
  String? acces_payment = '';
  String? acces_dispatch = '';

  var checkLiftedQty;
  bool isLoading = false;

  Map<String, dynamic> taxAmount = {};
  Map<String, dynamic> ViewPaymentData = {};
  List<dynamic> paymentId = [];
  List<dynamic> paymentStatus = [];
  List<dynamic> emdStatus = [];
  List<dynamic> cmdStatus = [];
  List<dynamic> taxes = [];

  final TextEditingController totalPaymentController = TextEditingController();

  List<Map<String, dynamic>> userData = [];
  List<Map<String, dynamic>> selectedUsers = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin().then((_) {
      setState(() {});
    });
    fetchUsers();
    fetchPreSelectedUsers();
    fetchPaymentDetails();
    fetchRefundPaymentDetails();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    uuid = prefs.getString("uuid")!;
    uuid = prefs.getString("uuid")!;
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
    readonly = prefs.getString("readonly");
    attendonly = prefs.getString("attendonly");
    acces_payment = prefs.getString("acces_payment");
    acces_dispatch = prefs.getString("acces_dispatch");
  }

  Future<void> fetchPaymentDetails() async {
    try {
      setState(() {
        isLoading = true;
      });
      await checkLogin();
      final url = Uri.parse("${URL}payment_details");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid': uuid,
          'user_pass': password,
          'sale_order_id': widget.sale_order_id,
          'bidder_id': widget.bidder_id,
          'vendor_id': widget.vendor_id_from_ids,
          'branch_id': widget.branch_id_from_ids,
          'mat_id': widget.materialId,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          var jsonData = json.decode(response.body);
          ViewPaymentData = jsonData;
          paymentId = ViewPaymentData['sale_order_payments'] ?? [];
          emdStatus = ViewPaymentData['emd_status'] ?? [];
          cmdStatus = ViewPaymentData['cmd_status'] ?? [];
          paymentStatus = ViewPaymentData['recieved_payment'] ?? [];
          checkLiftedQty = ViewPaymentData['lifted_quantity'];
          taxes = ViewPaymentData['tax_and_rate']['taxes'] ?? [];
          taxAmount = ViewPaymentData['tax_and_rate'] ?? {};
        });
      } else {
        print("Unable to fetch data.");
      }
    } catch (e) {
      print("Server Exception: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchRefundPaymentDetails() async {
    try {
      await checkLogin();
      final url = Uri.parse("${URL}EMD_CMD_details");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid': uuid,
          'user_pass': password,
          'sale_order_id': widget.sale_order_id,
          'branch_id': widget.branch_id_from_ids,
          'vendor_id': widget.vendor_id_from_ids,
          'mat_id': widget.materialId,
        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          totalPaymentController.text = jsonData['Advance_payment'] != null
              ? double.tryParse(jsonData['Advance_payment'].toString()) != null
                  ? (double.parse(jsonData['Advance_payment'].toString())
                          .toStringAsFixed(3)) // Round to 3 decimals first
                      .substring(
                          0,
                          (double.parse(jsonData['Advance_payment'].toString())
                                      .toStringAsFixed(3))
                                  .length -
                              1) // Convert back to 2 decimals
                  : "0.00"
              : "N/A";
        });
      } else {
        print("unable to load order ids.");
      }
    } catch (e) {
      print("Server Exception : $e");
    }
  }

  showLoading() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.transparent,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return 'No data';
    }
    try {
      DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return 'Invalid date';
    }
  }

  int _selectedIndex = 0;

  Widget buildBottomNavButtons(
      BuildContext context, int selectedIndex, Function(int) onItemTapped) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          spacing: 8, // Space between buttons
          alignment: WrapAlignment.center,// Center buttons
          children: [
            if (acces_payment == 'Y')
              buildNavButton(Icons.payment, "Payment Details", 0, selectedIndex,
                  onItemTapped),
            if (acces_dispatch == 'Y')
              buildNavButton(Icons.local_shipping, "Dispatch Details", 1,
                  selectedIndex, onItemTapped),
            if (userType == 'S' || userType == 'A'|| userType == 'SA')
              buildNavButton(Icons.share, "Refer   ", 2,
                  selectedIndex, onItemTapped),
          ],
        ),
      ),
    );
  }

  List<Color> buttonColors = [
    Colors.green, // Payment Details
    Colors.blue, // EMD Details
    Colors.orange, // Dispatch Details
  ];

  Widget buildNavButton(IconData icon, String label, int index,
      int selectedIndex, Function(int) onItemTapped) {
    return ElevatedButton.icon(
      onPressed: () => onItemTapped(index),
      icon: Icon(icon,
          size: 18, color: selectedIndex == index ? Colors.white : buttonColors[index]),
      label: Text(label,
          style: TextStyle(
              fontSize: 12,
              color: selectedIndex == index ? Colors.white : buttonColors[index])),
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedIndex == index ? buttonColors[index] : Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: buttonColors[index]),
        ),
      ),
    );
  }

  Future<void> fetchUsers() async {
    final url = Uri.parse("${URL}plantWiseUser");
    try {
      final response = await http.post(url, body: {
        'user_id': username,
        'user_pass': password,
        'uuid': uuid,

      });

      final data = json.decode(response.body);
      if (data['status'] == "1" && data['user_data'] != null) {
        userData = List<Map<String, dynamic>>.from(data['user_data']);
      } else {
        print("Error in response: ${data['status']}");
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  Future<void> fetchPreSelectedUsers() async {
    final url = Uri.parse("${URL}FetchSaleOrderReferName");
    try {
      final response = await http.post(url, body: {
        'user_id': username,
        'user_pass': password,
        'uuid': uuid,
        'sale_order_id': widget.sale_order_id,
      });

      final data = json.decode(response.body);

      if (data['status'] == "1" && data['user_data'] != null) {
        selectedUsers.clear();

        final preSelected = List<Map<String, dynamic>>.from(data['user_data']);

        for (var preUser in preSelected) {
          final match = userData.firstWhere(
                (user) => user['person_id'].toString() == preUser['person_id'].toString(),
            orElse: () => {},
          );

          if (match.isNotEmpty) {
            // ✅ Check for duplicates before adding
            bool alreadyExists = selectedUsers.any((u) =>
            u['person_id'].toString() == match['person_id'].toString());

            if (!alreadyExists) {
              selectedUsers.add(match);
            } else {
              print(" Skipped duplicate user: ${match['person_name']}");
            }
          } else {
            print(" No match found for person_id: ${preUser['person_id']}");
          }
        }
      } else {
        print(" No prefilled users or error: ${data['status']}");
      }
    } catch (e) {
      print(" Error fetching users: $e");
    }
  }

  Future<void> dispatchReferedUser(List selectedIds) async {
    // final selectedIds = selectedUsers.map((u) => u['person_id']).toList();
    print("Dispatching with IDs: ${selectedIds.join(',')}"); // ✅ Check this output

    final url = Uri.parse("${URL}dispatchReferedUser");
    try {
      final response = await http.post(url, body: {
        'user_id': username,
        'user_pass': password,
        'uuid': uuid,
        'sale_order_id': widget.sale_order_id,
        'branch_id': widget.branch_id_from_ids,
        'vendor_id': widget.vendor_id_from_ids,
        'mat_id': widget.materialId,
        'bidder_id': widget.bidder_id,
        'refered_user_id': selectedIds.join(','),
        'mat_name': ViewPaymentData['sale_order_details']?[0]['material_name'] ?? 'N/A',
      });

      final data = json.decode(response.body);

      if (data['status'] == "1" && data['msg'] != null) {
        userData = List<Map<String, dynamic>>.from(data['user_data'] ?? []);

        // Show the message using SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['msg']),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      } else {
        print("Error in response: ${data['status']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Something went wrong."),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  Future<void> removeReferedUser(String selectedIds) async {
    // final selectedIds = selectedUsers.map((u) => u['person_id']).toList();

    print("Removing with IDs API: ${selectedIds.toString()}"); // ✅ Check this output


    final url = Uri.parse("${URL}remove_ReferSaleOrder");
    try {
      final response = await http.post(url, body: {
        'user_id': username,
        'user_pass': password,
        'uuid': uuid,
        'sale_order_id': widget.sale_order_id,
        'refered_user_id': selectedIds.toString(),
      });

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'].toString() == '1') {
        setState(() {
          fetchUsers();
          fetchPreSelectedUsers();
          // Navigator.of(context).pop();

        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("User removed successfully"),
            duration: Duration(seconds: 2),
          ),

        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to remove user: ${responseData['msg'] ?? 'Unknown error'}"),
            duration: Duration(seconds: 2),
          ),
        );
      }

    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  void showReferDialog(BuildContext context) async {
    if (username == null || password == null || uuid == null) {
      print("Login info missing -> username: $username, password: $password, uuid: $uuid");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login info is missing. Please login again.")),
      );
      return;
    }

    final TextEditingController _typeAheadController = TextEditingController();

    // 1. Fetch all users
    await fetchUsers();

    // 2. Fetch preselected users after full list is loaded
    await fetchPreSelectedUsers();

    if (userData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No users found to refer.")),
      );
      return;
    }

    // Continue with showDialog...
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                "Select Users to Refer",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TypeAheadField<Map<String, dynamic>>(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _typeAheadController,
                        decoration: InputDecoration(
                          labelText: 'Search user',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      suggestionsCallback: (pattern) {
                        return userData.where((user) =>
                        user['person_name']
                            .toString()
                            .toLowerCase()
                            .contains(pattern.toLowerCase()) &&
                            !selectedUsers.any((sel) => sel['person_id'] == user['person_id']));
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(title: Text(suggestion['person_name']));
                      },
                      onSuggestionSelected: (suggestion) async {
                        setState(() {
                          selectedUsers.add(suggestion);
                        });
                        _typeAheadController.clear();
                      },
                      noItemsFoundBuilder: (context) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('No users found.'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (selectedUsers.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: selectedUsers.map((user) {
                            return Chip(
                              label: Text(user['person_name']),
                              deleteIcon: Icon(Icons.close),
                              onDeleted: () {
                                setState(() {
                                  selectedUsers.removeWhere((u) => u['person_id'] == user['person_id']);
                                  print("Removed user ID internal: ${user['person_id']}");
                                  // print("Updated selected IDs: ${selectedUsers.map((u) => u['person_id']).toList().join(', ')}");
                                });

                                removeReferedUser(user['person_id']);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    print("Selected Users: $selectedUsers");

                    final latestSelectedIds = selectedUsers.map((u) => u['person_id']).toList();
                    print("latestSelectedIds: $latestSelectedIds");

                    if (latestSelectedIds.isNotEmpty) {
                      dispatchReferedUser(latestSelectedIds);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("No users selected. Please select at least one user."),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text("Refer", style: TextStyle(color: Colors.white)),
                ),

                // ElevatedButton(
                //   onPressed: () {
                //     print("Selected Users: $selectedUsers");
                //     setState(() {
                //       final latestSelectedIds = selectedUsers.map((u) => u['person_id']).toList();
                //       print("latestSelectedIds:$latestSelectedIds");
                //
                //         if (latestSelectedIds.isNotEmpty || latestSelectedIds != 0) {
                //           dispatchReferedUser(latestSelectedIds);
                //         } else {
                //         print("No users selected. Skipping dispatch.");
                //         }
                //     });
                //   },
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.deepPurple,
                //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                //   ),
                //   child: Text("Refer", style: TextStyle(color: Colors.white)),
                // ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      // buildMaterialListTab(),
      if (acces_payment == 'Y')
       buildScrollableTabContent(context, buildPaymentDetailListView),
      // buildScrollableTabContent(context, buildEmdDetailListView),
      // buildScrollableTabContent(context, buildCMDDetailListView),
    ];

    return AbsorbPointer(
      absorbing: isLoading,
      child: Scaffold(
        drawer: AppDrawer(currentPage: 3),
        appBar: CustomAppBar(),
        body: isLoading
            ? showLoading()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Sale Order",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    buildRowWithIcon(context),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: buildVendorInfo(),
                    ),
                    buildExpansionTile(),
                    SizedBox(height: 10), // Spacer before content
                    IndexedStack(
                      index: _selectedIndex,
                      children: _pages,
                    ),
                  ],
                ),
              ),
        bottomNavigationBar:
            buildBottomNavButtons(context, _selectedIndex, (index) {
          setState(() {
            _selectedIndex = index;
            // Navigate to DispatchList when Dispatch is tapped
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => View_dispatch_details(
                          sale_order_id: widget.sale_order_id,
                          bidder_id: widget.bidder_id,
                          branch_id_from_ids:
                              widget.branch_id_from_ids, // Extracted from "Ids"
                          vendor_id_from_ids:
                              widget.vendor_id_from_ids, // Extracted from "Ids"
                          materialId: widget.materialId, // Extracted from "Ids"
                        )), // Navigate to DispatchList Page
              );
            }

            if (index == 2) {
            showReferDialog(context); // <- Only one argument now
            }

          });
        }),
        floatingActionButton: (readonly == 'Y')
            ? null
            : (acces_payment != 'Y')
                ? null
                : FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => addPaymentToSaleOrder(
                            sale_order_id: widget.sale_order_id,
                            material_name: ViewPaymentData['sale_order_details']
                                    ?[0]['material_name'] ??
                                'N/A',
                            vendor_id_from_ids: widget.vendor_id_from_ids,
                            branch_id_from_ids: widget.branch_id_from_ids,
                            materialID: widget.materialId,

                          ),
                        ),
                      ).then((value) => setState(() {
                            fetchPaymentDetails();
                          }));
                    },
                    child: Icon(Icons.add),
                    backgroundColor: Colors.blueGrey[200],
                  ),

        // floatingActionButton: (readonly == 'Y')
        //     ? null
        //     : FloatingActionButton(
        //         onPressed: () {
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //               builder: (context) => addPaymentToSaleOrder(
        //                 sale_order_id: widget.sale_order_id,
        //                 material_name: ViewPaymentData['sale_order_details']?[0]
        //                         ['material_name'] ??
        //                     'N/A',
        //                 vendor_id_from_ids: widget.vendor_id_from_ids,
        //                 branch_id_from_ids: widget.branch_id_from_ids,
        //               ),
        //             ),
        //           ).then((value) => setState(() {
        //                 fetchPaymentDetails();
        //               }));
        //         },
        //         child: Icon(Icons.add),
        //         backgroundColor: Colors.blueGrey[200],
        //       ),
      ),
    );
  }

  Widget buildScrollableTabContent(
      BuildContext context, Widget Function() listViewBuilder) {
    return listViewBuilder();
  }

  Widget buildRowWithIcon(BuildContext context) {
    return Material(
      elevation: 2,
      color: Colors.white,
      shape: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueGrey[400]!)),
      child: Container(
        child: Column(
          children: [
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  // Static Text
                  RichText(
                    text: TextSpan(
                      text: "Material Name : ",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 21,
                      ),
                    ),
                  ),
                  // Scrollable Text
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        "${ViewPaymentData['sale_order_details']?[0]['material_name'] ?? 'N/A'}",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.normal,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVendorInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildVendorInfoText(
            "Vendor Name : ",
            (ViewPaymentData['vendor_buyer_details']['vendor_name'] ?? 'N/A')
                .toString()
                .toUpperCase(),
            false),
        buildVendorInfoText(
            "Branch : ",
            (ViewPaymentData['vendor_buyer_details']['branch_name'] ?? 'N/A')
                .toString()
                .toUpperCase(),
            false),
        buildVendorInfoText(
            "Buyer Name : ",
            (ViewPaymentData['vendor_buyer_details']['bidder_name'] ?? 'N/A')
                .toString()
                .toUpperCase(),
            false),
      ],
    );
  }

  Widget buildVendorInfoText(String key, String value, bool isRed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Push key left & value right
        children: [
          Text(
            key,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black, // Bold key text
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isRed ? FontWeight.bold : FontWeight.normal,
                color: isRed
                    ? Colors.redAccent
                    : Colors.black54, // Color based on isRed
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildExpansionTile() {
    return Material(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Sale Order Details",
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            buildPaymentDetailsCard(ViewPaymentData),

            Divider(),
            buildTable(),
            SizedBox(height: 10), // Spacing between sections

            /// EMD Details ListView
            // Text(
            //   "EMD Details",
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            buildEmdDetailListView(), // ❌ `context` hata diya

            SizedBox(height: 10), // Spacing

            /// CMD Details ListView
            // Text(
            //   "CMD Details",
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            buildCMDDetailListView(), // ❌ `context` hata diya
          ],
        ),
      ),
    );
  }

  Widget buildDetailTile(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPaymentDetailsCard(Map<String, dynamic> ViewPaymentData) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDetailTile(
                "Material Name : ",
                ViewPaymentData['sale_order_details']?[0]['material_name'] ??
                    'N/A',
                Icons.category),
            buildDetailTile(
                "Total Qty : ",
                "${ViewPaymentData['sale_order_details'][0]['qty'] ?? 'No data'} ${ViewPaymentData['sale_order_details'][0]['totunit'] ?? ''}",
                Icons.inventory),
            // buildDetailTile(
            //     "Balance Qty : ",
            //     "${ViewPaymentData['sale_order_details'][0]['qty'] ?? 'No data'} ${ViewPaymentData['sale_order_details'][0]['totunit'] ?? ''}",
            //     Icons.inventory),
            if (ViewPaymentData['lifted_quantity'] != null &&
                ViewPaymentData['lifted_quantity'] is List &&
                ViewPaymentData['lifted_quantity'].isNotEmpty)
              buildDetailTile(
                  "Lifted Qty : ",
                  "${ViewPaymentData['lifted_quantity'][0]['quantity'] ?? 'No data'} ${ViewPaymentData['sale_order_details'][0]['totunit'] ?? ''}",
                  Icons.local_shipping),
            buildDetailTile(
                "Rate : ",
                ViewPaymentData['sale_order_details'][0]['rate']?.toString() ??
                    'No data',
                Icons.attach_money),
            buildDetailTile(
                "SO Date : ",
                formatDate(ViewPaymentData['sale_order_details'][0]['sod']),
                Icons.date_range),

            buildDetailTile(
                "SO Validity : ",
                formatDate(ViewPaymentData['sale_order_details'][0]['sovu']),
                Icons.event_available),

            buildDetailTile(
              "Balance\nAdvance Amount : ",
              totalPaymentController.text,
              Icons.account_balance_wallet,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTable() {
    // Use a Set to keep track of unique tax names
    Set<String> uniqueTaxNames = {};
    List<Map<String, dynamic>> uniqueTaxes = [];

    for (var tax in taxes) {
      if (!uniqueTaxNames.contains(tax['tax_name'])) {
        uniqueTaxNames.add(tax['tax_name']);
        uniqueTaxes.add(tax);
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: 400,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              spreadRadius: 2,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: DataTable(
          columnSpacing: 20,
          headingRowHeight: 48,
          dataRowHeight: 44,
          border: TableBorder.symmetric(
            inside: BorderSide(color: Colors.grey.shade300),
          ),
          columns: [
            DataColumn(
              label: Text(
                'Tax',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),
            DataColumn(
              label: Text(
                'Amount',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),
          ],
          rows: [
            DataRow(
              color: MaterialStateProperty.all(Colors.grey.shade200),
              cells: [
                DataCell(Text('Basic Amount',
                    style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text('₹${taxAmount['basicTaxAmount']}',
                    style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            if (uniqueTaxes.isNotEmpty)
              ...uniqueTaxes.map((tax) {
                return DataRow(
                  cells: [
                    DataCell(Text(tax['tax_name'] ?? 'No data')),
                    DataCell(Text('₹${tax['tax_amount'] ?? 'No data'}')),
                  ],
                );
              }).toList(),
            DataRow(
              color: MaterialStateProperty.all(Colors.grey.shade200),
              cells: [
                DataCell(Text('Final SO Amount',
                    style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text('₹${taxAmount['finalTaxAmount']}',
                    style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMaterialListTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildExpansionTile(),
        ],
      ),
    );
  }

  Widget buildPaymentDetailListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment Details Heading
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            "Payment Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Payment Details List or No Data Message
        if (paymentStatus.isNotEmpty)
          ListView.builder(
            shrinkWrap: true, // Prevents infinite scroll issue
            physics:
                NeverScrollableScrollPhysics(), // Disables separate scrolling
            itemCount: paymentStatus.length,
            itemBuilder: (context, index) {
              final paymentIdIndex = paymentStatus[index];
              return buildPaymentDetailListTile(context, paymentIdIndex);
            },
          )
        else
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "No Payment Details Found",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildEmdDetailListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // EMD Details Heading
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            "EMD Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // EMD Details List or No Data Message
        if (emdStatus.isNotEmpty)
          ListView.builder(
            shrinkWrap: true, // Prevents infinite scroll issue
            physics:
                NeverScrollableScrollPhysics(), // Disables separate scrolling
            itemCount: emdStatus.length,
            itemBuilder: (context, index) {
              final emdStatusIndex = emdStatus[index];
              return buildEmdDetailListTile(context, emdStatusIndex);
            },
          )
        else
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "No EMD Details Found",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildCMDDetailListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CMD Details Heading
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            "CMD Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // CMD Details List or No Data Message
        if (cmdStatus.isNotEmpty)
          ListView.builder(
            shrinkWrap: true, // Prevents infinite scroll issue
            physics:
                NeverScrollableScrollPhysics(), // Disables separate scrolling
            itemCount: cmdStatus.length,
            itemBuilder: (context, index) {
              final cmdStatusIndex = cmdStatus[index];
              return buildCMDDetailListTile(context, cmdStatusIndex);
            },
          )
        else
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "No CMD Details Found",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildPaymentDetailListTile(BuildContext context, index) {
    // if (index['payment_type'] == "Received Payment") {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12.0),
            leading: CircleAvatar(
              backgroundColor: Colors.indigo[800],
              child: Icon(Icons.border_outer, size: 24, color: Colors.white),
            ),
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Amount : ",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold, // Bold key
                      fontSize: 20,
                    ),
                  ),
                  TextSpan(
                    text: "${index['amt'] ?? 'N/A'}",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.normal, // Normal value
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Ref No : ",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold, // Bold key
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: "${index['pay_ref_no'] ?? 'N/A'}",
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.normal, // Normal value
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Date : ",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold, // Bold key
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: formatDate(index['date'] ?? 'N/A'),
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.normal, // Normal value
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.arrow_forward_ios, size: 16),
              color: Colors.grey[600],
              onPressed: () {
                // Action on tapping the arrow
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => View_Payment_Amount(
                        branch_id_from_ids: widget.branch_id_from_ids,
                        vendor_id_from_ids: widget.vendor_id_from_ids,
                        sale_order_id: widget.sale_order_id,
                        bidder_id: widget.bidder_id,
                        materialID: widget.materialId,
                        paymentId: index['payment_id'] ?? 'N/A',
                        paymentType: index['payment_type'] ?? 'N/A',
                        date1: index['date'] ?? 'N/A',
                        amount: index['amt'] ?? 'N/A',
                        referenceNo: index['pay_ref_no'] ?? 'N/A',
                        typeOfTransfer: index['typeoftransfer'] ?? 'N/A',
                        remark: index['narration'] ?? 'N/A',
                        freezed: index['freezed'] ?? 'N/A'),
                  ),
                ).then((value) => setState(() {
                      fetchPaymentDetails();
                    }));
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => View_Payment_Amount(
                      sale_order_id: widget.sale_order_id,
                      bidder_id: widget.bidder_id,
                      branch_id_from_ids: widget.branch_id_from_ids,
                      vendor_id_from_ids: widget.vendor_id_from_ids,
                      materialID: widget.materialId,

                      paymentId: index['payment_id'] ?? 'N/A',
                      paymentType: index['payment_type'] ?? 'N/A',
                      date1: index['date'] ?? 'N/A',
                      amount: index['amt'] ?? 'N/A',
                      referenceNo: index['pay_ref_no'] ?? 'N/A',
                      typeOfTransfer: index['typeoftransfer'] ?? 'N/A',
                      remark: index['narration'] ?? 'N/A',
                      freezed: index['freezed'] ?? 'N/A'),
                ),
              ).then((value) => setState(() {
                    fetchPaymentDetails();
                  }));
            },
          ),
        ),
      ),
    );
    // } else {
    //   return Container();
    // }
  }

  Widget buildEmdDetailListTile(BuildContext context, index) {
    if (index['payment_type'] == "Received EMD") {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(1),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12.0),
              leading: CircleAvatar(
                backgroundColor: Colors.indigo[800],
                child: Icon(Icons.account_balance_wallet_rounded,
                    size: 24, color: Colors.white),
              ),
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Amount : ",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold, // Bold key
                        fontSize: 20,
                      ),
                    ),
                    TextSpan(
                      text: "${index['amt'] ?? 'N/A'}",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.normal, // Normal value
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Ref No : ",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold, // Bold key
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: "${index['pay_ref_no'] ?? 'N/A'}",
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.normal, // Normal value
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Date : ",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold, // Bold key
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: formatDate(index['date'] ?? 'N/A'),
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.normal, // Normal value
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.arrow_forward_ios, size: 16),
                color: Colors.grey[600],
                onPressed: () {
                  // Action on tapping the arrow
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => View_Payment_Amount(
                          branch_id_from_ids: widget.branch_id_from_ids,
                          vendor_id_from_ids: widget.vendor_id_from_ids,
                          sale_order_id: widget.sale_order_id,
                          bidder_id: widget.bidder_id,
                          materialID: widget.materialId,

                          paymentId: index['payment_id'] ?? "N/A",
                          paymentType: index['payment_type'] ?? "N/A",
                          date1: index['date'] ?? "N/A",
                          amount: index['amt'] ?? "N/A",
                          referenceNo: index['pay_ref_no'] ?? "N/A",
                          typeOfTransfer: index['typeoftransfer'] ?? "N/A",
                          remark: index['narration'] ?? 'N/A',
                          freezed: index['freezed'] ?? 'N/A'),
                    ),
                  ).then((value) => setState(() {
                        fetchPaymentDetails();
                      }));
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => View_Payment_Amount(
                        branch_id_from_ids: widget.branch_id_from_ids,
                        vendor_id_from_ids: widget.vendor_id_from_ids,
                        sale_order_id: widget.sale_order_id,
                        bidder_id: widget.bidder_id,
                        materialID: widget.materialId,

                        paymentId: index['payment_id'] ?? "N/A",
                        paymentType: index['payment_type'] ?? "N/A",
                        date1: index['date'] ?? "N/A",
                        amount: index['amt'] ?? "N/A",
                        referenceNo: index['pay_ref_no'] ?? "N/A",
                        typeOfTransfer: index['typeoftransfer'] ?? "N/A",
                        remark: index['narration'] ?? 'N/A',
                        freezed: index['freezed'] ?? 'N/A'),
                  ),
                ).then((value) => setState(() {
                      fetchPaymentDetails();
                    }));
              },
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget buildCMDDetailListTile(BuildContext context, index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12.0),
            leading: CircleAvatar(
              backgroundColor: Colors.indigo[800],
              child: Icon(Icons.account_balance_wallet_rounded,
                  size: 24, color: Colors.white),
            ),
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Amount : ",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold, // Bold key
                      fontSize: 20,
                    ),
                  ),
                  TextSpan(
                    text: "${index['amt'] ?? 'N/A'}",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.normal, // Normal value
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Ref No : ",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold, // Bold key
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: "${index['pay_ref_no'] ?? 'N/A'}",
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.normal, // Normal value
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Date : ",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold, // Bold key
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: formatDate(index['date'] ?? 'N/A'),
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.normal, // Normal value
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.arrow_forward_ios, size: 16),
              color: Colors.grey[600],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => View_Payment_Amount(
                        branch_id_from_ids: widget.branch_id_from_ids,
                        vendor_id_from_ids: widget.vendor_id_from_ids,
                        sale_order_id: widget.sale_order_id,
                        bidder_id: widget.bidder_id,
                        materialID: widget.materialId,

                        paymentId: index['payment_id'] ?? "N/A",
                        paymentType: index['payment_type'] ?? "N/A",
                        date1: index['date'] ?? "N/A",
                        amount: index['amt'] ?? "N/A",
                        referenceNo: index['pay_ref_no'] ?? "N/A",
                        typeOfTransfer: index['typeoftransfer'] ?? "N/A",
                        remark: index['narration'] ?? 'N/A',
                        freezed: index['freezed'] ?? 'N/A'),
                  ),
                ).then((value) => setState(() {
                      fetchPaymentDetails();
                    }));
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => View_Payment_Amount(
                      branch_id_from_ids: widget.branch_id_from_ids,
                      vendor_id_from_ids: widget.vendor_id_from_ids,
                      sale_order_id: widget.sale_order_id,
                      bidder_id: widget.bidder_id,
                      materialID: widget.materialId,

                      paymentId: index['payment_id'] ?? "N/A",
                      paymentType: index['payment_type'] ?? "N/A",
                      date1: index['date'] ?? "N/A",
                      amount: index['amt'] ?? "N/A",
                      referenceNo: index['pay_ref_no'] ?? "N/A",
                      typeOfTransfer: index['typeoftransfer'] ?? "N/A",
                      remark: index['narration'] ?? 'N/A',
                      freezed: index['freezed'] ?? 'N/A'),
                ),
              ).then((value) => setState(() {
                    fetchPaymentDetails();
                  }));
            },
          ),
        ),
      ),
    );
  }
}

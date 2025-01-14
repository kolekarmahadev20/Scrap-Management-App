import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../URL_CONSTANT.dart';

class saleOrderList extends StatefulWidget {
  final int currentPage;
  saleOrderList({required this.currentPage});

  @override
  State<saleOrderList> createState() => saleOrderListState();
}

class saleOrderListState extends State<saleOrderList> {
  String? username = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';

  List<dynamic> saleOrderList = [];
  List<dynamic> filteredSaleOrderList = []; // For filtered search results
  bool isLoading = false; // Add a loading flag
  TextEditingController searchController =
      TextEditingController(); // Controller for search input

  @override
  void initState() {
    super.initState();
    checkLogin().then((_) {
      setState(() {}); // Rebuilds the widget after `userType` is updated.
    });
    fetchSaleOrderList();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
  }

  Future<void> fetchSaleOrderList() async {
    try {
      setState(() {
        isLoading = true;
      });
      await checkLogin();
      final url = Uri.parse("${URL}sale_order_list");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'user_pass': password,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          var jsonData = json.decode(response.body);
          saleOrderList = jsonData['aaData'];
          filteredSaleOrderList = saleOrderList; // Initialize filtered list
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

  // Function to filter the list based on search query
  void filterSearchResults(String query) {
    List<dynamic> searchResults = [];
    if (query.isNotEmpty) {
      saleOrderList.forEach((order) {
        if (order['description']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            order['vendor_name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            order['bidder_name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase())) {
          searchResults.add(order);
        }
      });
      setState(() {
        filteredSaleOrderList = searchResults;
      });
    } else {
      setState(() {
        filteredSaleOrderList =
            saleOrderList; // Reset to full list when search is cleared
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isLoading,
      child: Scaffold(
        drawer: AppDrawer(currentPage: widget.currentPage),
        appBar: CustomAppBar(),
        body: isLoading
            ? showLoading()
            : Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.grey[200], // Slightly lighter background color
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Active Sale Order",
                                style: TextStyle(
                                  fontSize:
                                      24, // Slightly larger font size for prominence
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Container(
                    //     width:double.infinity,
                    //     child: Column(
                    //       children: [
                    //         SizedBox(height: 8,),
                    //         Padding(
                    //           padding: const EdgeInsets.all(8.0),
                    //           child: Material(
                    //             elevation: 2,
                    //             color: Colors.white,
                    //             shape: OutlineInputBorder(
                    //                 borderSide: BorderSide(color: Colors.blueGrey[400]!)
                    //             ),
                    //             child: Container(
                    //               child: Column(
                    //                 children: [
                    //                   SizedBox(height: 8,),
                    //                   Row(
                    //                     mainAxisSize: MainAxisSize.min,
                    //                     children: [
                    //                       Spacer(),
                    //                       Text(
                    //                         "Vendor, Plant",
                    //                         style: TextStyle(
                    //                           fontSize: 18,
                    //                           color: Colors.black54,
                    //                           fontWeight: FontWeight.w500,
                    //                         ),
                    //                       ),
                    //                       Spacer(),
                    //                     ],
                    //                   ),
                    //                   SizedBox(height: 8,),
                    //                 ],
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //         SizedBox(height: 8,),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          filterSearchResults(
                              value); // Call function to filter results
                        },
                        decoration: InputDecoration(
                          labelText: "Search",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: (filteredSaleOrderList.isNotEmpty)
                          ? ListView.separated(
                              itemCount: filteredSaleOrderList
                                  .length, // Number of items in the filtered list
                              itemBuilder: (context, index) {
                                final paymentIndex =
                                    filteredSaleOrderList[index];
                                return buildCustomListTile(
                                    context, paymentIndex);
                              },
                              separatorBuilder: (context, index) => Divider(
                                color: Color(
                                    0xFF6482AD), // Custom color for the separator
                                thickness: 1, // Thickness of the divider
                                indent: 12, // Indentation before the divider
                                endIndent: 12, // Indentation after the divider
                              ),
                            )
                          : Center(
                              child: Text("No data",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20))),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget buildCustomListTile(BuildContext context, index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueGrey[700]!, Colors.blueGrey[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  // Static Text
                  RichText(
                    text: TextSpan(
                      text: "Material : ",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  // Scrollable Text
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        "${index['description'] ?? 'N/A'}",
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.normal,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Material(
              elevation: 0,
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo[800]!,
                  child:
                      Icon(Icons.border_outer, size: 22, color: Colors.white),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Vendor Name : ",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          TextSpan(
                            text: "${index['vendor_name'] ?? 'N/A'}",
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(thickness: 1, color: Colors.black87),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Buyer : ",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          TextSpan(
                            text: "${index['bidder_name'] ?? 'N/A'}",
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

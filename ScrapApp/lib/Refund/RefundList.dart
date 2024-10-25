import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Refund/Add_refund_details.dart';
import 'package:scrapapp/Refund/View_refund_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../URL_CONSTANT.dart';

class RefundList extends StatefulWidget {


  final int currentPage;
  RefundList({required this.currentPage});

  @override
  State<RefundList> createState() => _RefundListState();
}

class _RefundListState extends State<RefundList> {

  TextEditingController searchMaterialController = TextEditingController(); // Controller for search input
  TextEditingController searchVendorController = TextEditingController(); // Controller for search input
  TextEditingController searchBidderController = TextEditingController(); // Controller for search input
  String? username = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';

  bool isLoading = false; // Add a loading flag

  List<Map<String, dynamic>> refundList = [];
  List<dynamic> filteredRefundList = []; // For filtered search results


  @override
  void initState() {
    super.initState();
    checkLogin().then((_){
      setState(() {});
    });
    fetchRefundList();
  }


  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
  }

  Future<void> fetchRefundList() async {
    try {
      setState(() {
        isLoading = true;
      });
      await checkLogin();
      final url = Uri.parse("${URL}fetch_refund_data");
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
          refundList = List<Map<String, dynamic>>.from(jsonData['saleOrder_refundList']);
          filteredRefundList = refundList;
        });
      } else {
        print("Unable to fetch data.");
      }
    }catch (e) {
      print("Server Exception: $e");
    }finally{
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterResults() {
    List<dynamic> searchResults = refundList;

    // Apply Material filter
    if (searchMaterialController.text.isNotEmpty) {
      searchResults = searchResults.where((order) {
        return order['description']
            .toString()
            .toLowerCase()
            .contains(searchMaterialController.text.toLowerCase());
      }).toList();
    }

    // Apply Vendor filter
    if (searchVendorController.text.isNotEmpty) {
      searchResults = searchResults.where((order) {
        return order['vendor_name']
            .toString()
            .toLowerCase()
            .contains(searchVendorController.text.toLowerCase());
      }).toList();
    }

    // Apply Bidder filter
    if (searchBidderController.text.isNotEmpty) {
      searchResults = searchResults.where((order) {
        return order['bidder_name']
            .toString()
            .toLowerCase()
            .contains(searchBidderController.text.toLowerCase());
      }).toList();
    }

    setState(() {
      filteredRefundList = searchResults;
    });
  }

  Future showFilterDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Search Sale Orders",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.black54),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    _buildSearchField(
                      controller: searchMaterialController,
                      hintText: "Enter Material Name",
                    ),
                    SizedBox(height: 10),
                    _buildSearchField(
                      controller: searchVendorController,
                      hintText: "Enter Vendor Name",
                    ),
                    SizedBox(height: 10),
                    _buildSearchField(
                      controller: searchBidderController,
                      hintText: "Enter Bidder Name",
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  searchMaterialController.clear();
                                  searchVendorController.clear();
                                  searchBidderController.clear();
                                  fetchRefundList();
                                });
                                Navigator.pop(context); // Close dialog
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[400],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 15),
                                elevation: 5,
                              ),
                              child: Text(
                                "Reset",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  filterResults();
                                });
                                Navigator.pop(context); // Close dialog
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[400],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 15),
                                elevation: 5,
                              ),
                              child: Text(
                                "Apply",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: 18),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.indigo),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }


  showLoading(){
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.transparent,
      child: Center(child: CircularProgressIndicator(),),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isLoading,
      child: Scaffold(
        drawer: AppDrawer(currentPage: widget.currentPage),
        appBar: CustomAppBar(),
        body: Stack(
          children:[
            isLoading
            ?showLoading()
            :Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.grey[200], // Slightly lighter background color
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Refund",
                        style: TextStyle(
                          fontSize: 26, // Slightly larger font size for prominence
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            showFilterDialog();
                          });
                        },
                        icon: Icon(
                          Icons.filter_list_alt,
                          color: Colors.white,
                          size: 20, // Consistent icon size
                        ),
                        label: Text("Filter"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blueGrey[400], // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                          ),
                          elevation: 5,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Consistent padding
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    elevation: 2,
                    color: Colors.white,
                    shape: OutlineInputBorder(
                        borderSide: BorderSide(color:Colors.blueGrey[400]!)
                    ),
                    child: Container(
                      width:double.infinity,
                      child: Row(
                        children: [
                          Spacer(),
                          Text(
                            "Vendor, Plant",
                            style: TextStyle(
                              fontSize: 18, // Slightly larger font size
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                          Opacity(
                            opacity:0.0, // Change opacity based on userType
                            child: IconButton(
                              icon: Icon(
                                Icons.add_box_outlined,
                                size: 28, // Slightly smaller but prominent icon
                                color: Colors.indigo[800],
                              ),
                              onPressed: null, // Disable the button when userType doesn't match
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height:20),
                Expanded(
                  child:
                  (filteredRefundList.length !=0)
                  ?ListView.separated(
                    itemCount: filteredRefundList.length, // Number of items in the list
                    itemBuilder: (context, index) {
                      final paymentIndex = filteredRefundList[index];
                      if(filteredRefundList.length !=0) {
                        return buildCustomListTile(context, paymentIndex);
                      }else{
                        return Text("No data");
                      }
                    },
                    separatorBuilder: (context, index) => Divider(
                      color: Color(0xFF6482AD), // Custom color for the separator
                      thickness: 1, // Thickness of the divider
                      indent: 12, // Indentation before the divider
                      endIndent: 12, // Indentation after the divider
                    ),
                  )
                  :Center(child: Text("No data", style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20))),
                ),
              ],
            ),
          ),
        ]),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo[800]!,
                  child: Icon(Icons.border_outer, size: 22, color: Colors.white),
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
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Date : ",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          TextSpan(
                            text: "${index['date'] ?? 'N/A'}",
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
                trailing: IconButton(
                  icon: Icon(Icons.arrow_forward_ios, size: 18), // Adjusted trailing icon size
                  color: Colors.grey[600],
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => View_refund_details(
                        sale_order_id: index['sale_order_id'],
                        bidder_id: index['bidder_id'],
                      )),
                    ).then((value) => setState((){
                      fetchRefundList();
                    }));
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => View_refund_details(
                      sale_order_id: index['sale_order_id'],
                      bidder_id: index['bidder_id'],
                    )),
                  ).then((value) => setState((){
                    fetchRefundList();
                  }));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

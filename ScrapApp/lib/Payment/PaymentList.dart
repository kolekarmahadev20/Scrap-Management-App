import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Payment/View_payment_detail.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../URL_CONSTANT.dart';

class PaymentList extends StatefulWidget {

  final int currentPage;
  PaymentList({required this.currentPage});

  @override
  State<PaymentList> createState() => _PaymentListState();
}

class _PaymentListState extends State<PaymentList> {

  TextEditingController searchMaterialController = TextEditingController(); // Controller for search input
  TextEditingController searchVendorController = TextEditingController(); // Controller for search input
  TextEditingController searchBidderController = TextEditingController(); // Controller for search input

  String? username = '';
 String uuid = '';

  String? password = '';
  String? loginType = '';
  String? userType = '';

  List<Map<String, dynamic>> paymentList = [];
  List<dynamic> filteredPaymentList = []; // For filtered search results



  bool isLoading = false; // Add a loading flag

  @override
  void initState() {
    super.initState();
    checkLogin().then((_) {
      setState(() {});
    });
    fetchPaymentList();
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

  Future<void> fetchPaymentList() async {
    try {
      setState(() {
        isLoading = true;
      });
      await checkLogin();
      final url = Uri.parse("${URL}fetch_payment_data");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
        'user_id': username,
'uuid':uuid,
          'user_pass': password,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          var jsonData = json.decode(response.body);
          // Extract the relevant data
          paymentList = List<Map<String, dynamic>>.from(jsonData['saleOrder_paymentList']);

          // Ensure Ids fields are extracted properly
          for (var item in paymentList) {
            if (item.containsKey("Ids") && item["Ids"] != null) {
              item["vendor_id_from_ids"] = item["Ids"]["vendor_id"];
              item["branch_id_from_ids"] = item["Ids"]["branch_id"];
            }
          }

          filteredPaymentList = paymentList;

        });
      } else {
        print("Unable to fetch data.");
      }
    } catch (e) {
      print("Server Exception: $e");
    }finally{
      setState(() {
        isLoading = false;
      });
    }
  }


  void filterResults() {
    List<dynamic> searchResults = paymentList;

    // Apply Material filter
    if (searchMaterialController.text.isNotEmpty) {
      List<String> searchTerms = searchMaterialController.text.toLowerCase().trim().split(' '); // Split words
      searchResults = searchResults.where((order) {
        String description = order['description'].toString().toLowerCase();
        return searchTerms.every((term) => description.contains(term)); // Check if all words exist
      }).toList();
    }

    // Apply Vendor filter
    if (searchVendorController.text.isNotEmpty) {
      List<String> searchTerms = searchVendorController.text.toLowerCase().trim().split(' ');
      searchResults = searchResults.where((order) {
        String vendorName = order['vendor_name'].toString().toLowerCase();
        return searchTerms.every((term) => vendorName.contains(term));
      }).toList();
    }

    // Apply Bidder filter
    if (searchBidderController.text.isNotEmpty) {
      List<String> searchTerms = searchBidderController.text.toLowerCase().trim().split(' ');
      searchResults = searchResults.where((order) {
        String bidderName = order['branch_name'].toString().toLowerCase();
        return searchTerms.every((term) => bidderName.contains(term));
      }).toList();
    }

    setState(() {
      filteredPaymentList = searchResults;
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
                        Expanded(
                          child: Text(
                            "Search By",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
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
                      hintText: "Enter Plant Name",
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
                                  fetchPaymentList();
                                });
                                Navigator.pop(context); // Close dialog
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[400],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: EdgeInsets.all(8),
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
                                padding: EdgeInsets.all(8),
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
      style: TextStyle(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(Icons.search, color: Colors.blueGrey[400]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        body:
        isLoading
        ?showLoading()
        :Container(
          height: double.infinity,
          width: double.infinity,
           // Increased padding around the body
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
                      "Payment",
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
              SizedBox(height:20),
              Expanded(
                child:
                (filteredPaymentList.length !=0)
                ?ListView.separated(
                  itemCount: filteredPaymentList.length, // Number of items in the list
                  itemBuilder: (context, index) {
                    final paymentIndex = filteredPaymentList[index];
                    if(filteredPaymentList.length !=0) {
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
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Plant : ",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          TextSpan(
                            text: "${index['branch_name'] ?? 'N/A'}",
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
                  icon: Icon(Icons.arrow_forward_ios, size: 18),
                  color: Colors.grey[600],
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => View_payment_detail(
                          sale_order_id: index['sale_order_id'],
                          bidder_id: index['bidder_id'],
                          branch_id_from_ids: index['branch_id_from_ids'], // Extracted from "Ids"
                          vendor_id_from_ids: index['vendor_id_from_ids'], // Extracted from "Ids"

                        ),
                      ),
                    ).then((value) => setState(() {
                      fetchPaymentList();
                    }));
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => View_payment_detail(
                        sale_order_id: index['sale_order_id'],
                        bidder_id: index['bidder_id'],
                        branch_id_from_ids: index['branch_id_from_ids'], // Extracted from "Ids"
                        vendor_id_from_ids: index['vendor_id_from_ids'], // Extracted from "Ids"

                      ),
                    ),
                  ).then((value) => setState(() {
                    fetchPaymentList();
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

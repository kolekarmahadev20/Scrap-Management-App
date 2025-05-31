import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Payment/View_payment_detail.dart';
import '../URL_CONSTANT.dart';
import 'SaleOrderPayment.dart';

class ReferedSaleOrderList extends StatefulWidget {
  final int currentPage;
  ReferedSaleOrderList({required this.currentPage});

  @override
  State<ReferedSaleOrderList> createState() => ReferedSaleOrderListState();
}

class ReferedSaleOrderListState extends State<ReferedSaleOrderList> {
  String? username = '';
  String uuid = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';

  List<dynamic> saleOrderList = [];
  List<dynamic> filteredSaleOrderList = []; // For filtered search results
  bool isLoading = false; // Add a loading flag
  TextEditingController searchController =
      TextEditingController(); // Controller for search input

  TextEditingController searchMaterialController =
      TextEditingController(); // Controller for search input
  TextEditingController searchVendorController =
      TextEditingController(); // Controller for search input
  TextEditingController searchBidderController =
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
    uuid = prefs.getString("uuid")!;
    uuid = prefs.getString("uuid")!;
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
      final url = Uri.parse("${URL}Fetch_ReferSaleOrder");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid': uuid,
          'user_pass': password,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          var jsonData = json.decode(response.body);
          saleOrderList = jsonData['user_data'];
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

  void filterResults() {
    List<dynamic> searchResults = saleOrderList;

    // Apply Material filter
    if (searchMaterialController.text.isNotEmpty) {
      List<String> searchTerms = searchMaterialController.text
          .toLowerCase()
          .trim()
          .split(' '); // Split words
      searchResults = searchResults.where((order) {
        String description = order['description'].toString().toLowerCase();
        return searchTerms.every(
            (term) => description.contains(term)); // Check if all words exist
      }).toList();
    }

    // Apply Vendor filter
    if (searchVendorController.text.isNotEmpty) {
      List<String> searchTerms =
          searchVendorController.text.toLowerCase().trim().split(' ');
      searchResults = searchResults.where((order) {
        String vendorName = order['vendor_name'].toString().toLowerCase();
        return searchTerms.every((term) => vendorName.contains(term));
      }).toList();
    }

    // Apply Bidder filter
    if (searchBidderController.text.isNotEmpty) {
      List<String> searchTerms =
          searchBidderController.text.toLowerCase().trim().split(' ');
      searchResults = searchResults.where((order) {
        String bidderName = order['branch_name'].toString().toLowerCase();
        return searchTerms.every((term) => bidderName.contains(term));
      }).toList();
    }

    setState(() {
      filteredSaleOrderList = searchResults;
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
                                  fetchSaleOrderList();
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
                                  backgroundColor:
                                      Colors.blueGrey[400], // Text color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        12), // Rounded corners
                                  ),
                                  elevation: 5,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8), // Consistent padding
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget buildCustomListTile(BuildContext context, index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => View_payment_detail(
                sale_order_id: index['sale_order_id'],
                bidder_id: index['buyer_id'],
                branch_id_from_ids: index['branch_id'],
                vendor_id_from_ids: index['vendor_id'],
                materialId: index['branch_id'],
              ),
            ),
          );
        },
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
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
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
                              text: "Vendor Name : ", // Label remains unchanged
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "${(index['vendor_name'] ?? 'N/A').toString().toUpperCase()}", // ✅ Value converted to uppercase
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
                              text: "Buyer : ", // Label remains unchanged
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "${(index['bidder_name'] ?? 'N/A').toString().toUpperCase()}", // ✅ Value converted to uppercase
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
                              text: "Plant : ", // Label remains unchanged
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "${(index['branch_name'] ?? 'N/A').toString().toUpperCase()}", // ✅ Value converted to uppercase
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
                              text: "Valid Upto : ", // Label remains unchanged
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            TextSpan(
                              text: formatDate(index['valid_upto'])
                                      ?.toUpperCase() ??
                                  'N/A',
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
                  trailing: Icon(Icons.arrow_forward_ios,
                      color: Colors.black54, size: 20), // Arrow Icon
                  onTap: () {
                    // Navigate to ViewPaymentDetail page with required parameters
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => View_payment_detailSale(
                          sale_order_id: index['sale_order_id'],
                          bidder_id: index['buyer_id'],
                          branch_id_from_ids: index['branch_id'],
                          vendor_id_from_ids: index['vendor_id'],
                          materialId: index['branch_id'],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

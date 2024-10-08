import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../URL_CONSTANT.dart';

class saleOrderList extends StatefulWidget {
  @override
  State<saleOrderList> createState() => saleOrderListState();
}

class saleOrderListState extends State<saleOrderList> {
  String? username = '';
  String? password = '';

  List<dynamic> saleOrderList = [];
  List<dynamic> filteredSaleOrderList = []; // For filtered search results
  bool isLoading = false; // Add a loading flag
  TextEditingController searchController = TextEditingController(); // Controller for search input

  @override
  void initState() {
    super.initState();
    checkLogin();
    fetchSaleOrderList();
  }

  checkLogin() async {
    final login = await SharedPreferences.getInstance();
    username = await login.getString("username") ?? '';
    password = await login.getString("password") ?? '';
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
      child: Center(child: CircularProgressIndicator(),),
    );
  }

  // Function to filter the list based on search query
  void filterSearchResults(String query) {
    List<dynamic> searchResults = [];
    if (query.isNotEmpty) {
      saleOrderList.forEach((order) {
        if (order['sale_order_code'].toString().toLowerCase().contains(query.toLowerCase()) ||
            order['vendor_name'].toString().toLowerCase().contains(query.toLowerCase()) ||
            order['bidder_name'].toString().toLowerCase().contains(query.toLowerCase())) {
          searchResults.add(order);
        }
      });
      setState(() {
        filteredSaleOrderList = searchResults;
      });
    } else {
      setState(() {
        filteredSaleOrderList = saleOrderList; // Reset to full list when search is cleared
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isLoading,
      child: Scaffold(
        drawer: AppDrawer(),
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
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Active Sale Order",
                          style: TextStyle(
                            fontSize: 24, // Slightly larger font size for prominence
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),],
                ),
              ),
              Divider(
                thickness: 1,
                color: Colors.black54,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Spacer(),
                  Text(
                    "Vendor, Plant",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                ],
              ),
              Divider(
                thickness: 1,
                color: Colors.black54,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    filterSearchResults(value); // Call function to filter results
                  },
                  decoration: InputDecoration(
                    labelText: "Search Order ID ",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Expanded(
                child: ListView.separated(
                  itemCount: filteredSaleOrderList.length, // Number of items in the filtered list
                  itemBuilder: (context, index) {
                    final paymentIndex = filteredSaleOrderList[index];
                    return buildCustomListTile(context, paymentIndex);
                  },
                  separatorBuilder: (context, index) => Divider(
                    color: Color(0xFF6482AD), // Custom color for the separator
                    thickness: 1, // Thickness of the divider
                    indent: 12, // Indentation before the divider
                    endIndent: 12, // Indentation after the divider
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCustomListTile(BuildContext context, index) {
    return Card(
      color: Colors.white,
      elevation: 2, // Slightly higher elevation for a more pronounced shadow
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0), // Reduced margins
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // More rounded corners
        side: BorderSide(color: Color(0xFF6482AD), width: 1.5), // Accent border
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Reduced padding
        leading: CircleAvatar(
          backgroundColor: Colors.indigo[800]!,
          child: Icon(Icons.border_outer, size: 22, color: Colors.white), // Reduced icon size
        ),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Order ID :  ", // Key text (e.g., "Vendor Name: ")
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Bold key text
                ),
              ),
              TextSpan(
                text: index['sale_order_code'] ?? "N/A", // Value text (e.g., "XYZ Corp")
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: Colors.black54, // Normal value text
                ),
              ),
            ],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(thickness: 1, color: Colors.black87),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Vendor Name : ",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold, // Bold key
                      fontSize: 18,
                    ),
                  ),
                  TextSpan(
                    text: "${index['vendor_name'] ?? 'N/A'}",
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.normal, // Normal value
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
                    text: "Buyer : ",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold, // Bold key
                      fontSize: 18,
                    ),
                  ),
                  TextSpan(
                    text: "${index['bidder_name'] ?? 'N/A'}",
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.normal, // Normal value
                      fontSize: 18,
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
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Dispatch/Add_dispatch_details.dart';
import 'package:scrapapp/Dispatch/View_dispatch_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../URL_CONSTANT.dart';

class DispatchList extends StatefulWidget {
  @override
  State<DispatchList> createState() => _DispatchListState();
}

class _DispatchListState extends State<DispatchList> {

  TextEditingController searchController = TextEditingController(); // Controller for search input

  String? username = '';
  String? password = '';
  bool isLoading = false; // Add a loading flag
  List<Map<String, dynamic>> dispatchList = [];


  @override
  void initState() {
    super.initState();
    checkLogin();
    fetchDispatchList();
  }

  checkLogin()async{
    final login = await SharedPreferences.getInstance();
    username = await login.getString("username") ?? '';
    password = await login.getString("password") ?? '';
  }

  Future<void> fetchDispatchList() async {
    try {
      setState(() {
        isLoading = true;
      });
      await checkLogin();
      final url = Uri.parse("${URL}ajax_sale_order_dispatch_list");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'user_pass': password,
          'sale_order':searchController.text,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          var jsonData = json.decode(response.body);
          dispatchList = List<Map<String, dynamic>>.from(jsonData['saleOrder_dispatchList']);
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

  showLoading(){
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.transparent,
      child: Center(child: CircularProgressIndicator(),),
    );
  }

  showFilterDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.blueGrey[200],
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
                TextField(
                  controller: searchController,
                  onChanged: (value) {},
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: "Enter Order ID",
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color:Colors.indigo)// No border for cleaner look
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
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
                              searchController.clear();
                              fetchDispatchList();
                            });
                            Navigator.pop(context); // Close dialog
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400], // Primary color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                            elevation: 5,
                          ),
                          child: Text(
                            "Reset",
                            style: TextStyle(fontSize: 18, color: Colors.white),
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
                              fetchDispatchList();
                            });
                            Navigator.pop(context); // Close dialog
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[400], // Primary color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                            elevation: 5,
                          ),
                          child: Text(
                            "Apply",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],)
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isLoading,
      child: Scaffold(
        drawer: AppDrawer(),
        appBar: CustomAppBar(),
        body: Stack(
          children: [
            isLoading
            ?showLoading()
            :Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Colors.grey[200], // Slightly lighter background color
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(
                            12.0), // Increased padding for the header
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Dispatch",
                              style: TextStyle(
                                fontSize:
                                    26, // Slightly larger font size for prominence
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 1.2,
                              ),
                            ),
                            ElevatedButton.icon(
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
                                backgroundColor: Colors.blueGrey[400], // Button color
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12), // Rounded corners
                                ),
                                elevation: 5,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8), // Consistent padding
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          elevation: 2,
                          color: Colors.white,
                          shape: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueGrey[400]!)
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
                                IconButton(
                                  icon: Icon(
                                    Icons.add_box_outlined,
                                    size: 28, // Slightly smaller but prominent icon
                                    color: Colors.indigo[800],
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Add_dispatch_details())).then((value) => setState((){
                                      fetchDispatchList();
                                    }));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Expanded(
                        child:
                        (dispatchList.length != 0)
                        ?ListView.separated(
                          itemCount:dispatchList.length, // Number of items in the list
                          itemBuilder: (context, index) {
                            final dispatchListIndex = dispatchList[index];
                            return buildCustomListTile(context, dispatchListIndex);
                          },
                          separatorBuilder: (context, index) => Divider(
                            color: Color(0xFF6482AD), // Custom color for the separator
                            thickness: 1, // Thickness of the divider
                            indent: 12, // Indentation before the divider
                            endIndent: 12, // Indentation after the divider
                          ),
                        )
                        :Center(child: Text("No data", style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20))),
                      )
                    ],
                  ),
            ),
        ]),
      ),
    );
  }

  Widget buildCustomListTile(BuildContext context , index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        elevation: 2,
        shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5)
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12.0, vertical: 8.0), // Reduced padding inside the card
          leading: CircleAvatar(
            backgroundColor: Colors.indigo[800],
            child: Icon(Icons.border_outer,
                size: 22,
                color: Colors.white), // Reduced icon size for compactness
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
                  text:index['sale_order_code'] ?? "N/A", // Value text (e.g., "XYZ Corp")
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.indigo[800]!, // Normal value text
                  ),
                ),
              ],
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider( thickness: 1,color: Colors.black87),
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
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Material : ",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold, // Bold key
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text: "${index['description'] ?? 'N/A'}",
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
                      text: "Date : ",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold, // Bold key
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text: "${index['date'] ?? 'N/A'}",
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
          trailing: IconButton(
            icon: Icon(Icons.arrow_forward_ios,
                size: 18), // Adjusted trailing icon size
            color: Colors.grey[600],
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => View_dispatch_details(
                  sale_order_id: index['sale_order_id'],)),
              ).then((value) => setState((){
                fetchDispatchList();
              }));
            },
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => View_dispatch_details(
                sale_order_id: index['sale_order_id'],)),
            ).then((value) => setState((){
              fetchDispatchList();
            }));
          },
        ),
      ),
    );
  }
}

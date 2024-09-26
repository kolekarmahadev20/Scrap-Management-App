import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Payment/Add_payment_detail.dart';
import 'package:scrapapp/Refund/Add_refund_details.dart';
import 'package:scrapapp/Refund/View_refund_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../URL_CONSTANT.dart';

class RefundList extends StatefulWidget {
  @override
  State<RefundList> createState() => _RefundListState();
}

class _RefundListState extends State<RefundList> {

  String? username = '';
  String? password = '';
  bool isLoading = false; // Add a loading flag
  List<Map<String, dynamic>> refundList = [];

  @override
  void initState() {
    super.initState();
    checkLogin();
    fetchRefundList();
  }


  checkLogin()async{
    final login = await SharedPreferences.getInstance();
    username = await login.getString("username") ?? '';
    password = await login.getString("password") ?? '';
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


  showLoading(){
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.black.withOpacity(0.4),
      child: Center(child: CircularProgressIndicator(),),
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
                Padding(
                  padding: const EdgeInsets.all(12.0), // Increased padding for the header
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Refund",
                        style: TextStyle(
                          fontSize: 26, // Slightly larger font size for prominence
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 1.2,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.filter_list_alt,
                          color: Colors.white,
                          size: 20, // Consistent icon size
                        ),
                        label: Text("Filter"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.indigo[800], // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                          ),
                          elevation: 5,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Consistent padding
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  thickness: 1.5,
                  color: Colors.black54,
                ),
                Row(
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
                        Navigator.push(context,
                            MaterialPageRoute(
                                builder: (context) => Add_refund_details())).then((value) => setState((){
                          fetchRefundList();
                        }));
                      },
                    ),
                  ],
                ),
                Divider(
                  thickness: 1.5,
                  color: Colors.black54,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ListView.builder(
                      itemCount: refundList.length, // Number of items in the list
                      itemBuilder: (context, index) {
                        final refundListIndex = refundList[index];
                        return buildCustomListTile(context , refundListIndex);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget buildCustomListTile(BuildContext context , index) {
    return Card(
      color: Colors.white,
      elevation: 2, // Slightly higher elevation for a more pronounced shadow
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0), // Reduced margins for compact design
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // More rounded corners
        side: BorderSide(color: Colors.indigo[800]!, width: 1.5), // Accent border
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Reduced padding inside the card
        leading: CircleAvatar(
          backgroundColor: Colors.indigo[800],
          child: Icon(Icons.border_outer, size: 22, color: Colors.white), // Reduced icon size for compactness
        ),
        title: Center(
          child: Text(
            "#${index['sale_order_code']}",
            style: TextStyle(
              fontSize: 16, // Consistent title font size
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider( thickness: 1,color: Colors.black87),
            Text(
              "Buyer: ${index['bidder_name']}",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14, // Slightly smaller font size for subtitle

              ),
            ),
            Text(
              "Material :${index['description']}",
              style: TextStyle(
                fontSize: 14, // Consistent subtitle font size
                color: Colors.black54,
              ),
            ),
            Text(
              "Date : ${index['date']}",
              style: TextStyle(
                fontSize: 14, // Consistent subtitle font size
                color: Colors.black54,
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
            )),
          ).then((value) => setState((){
            fetchRefundList();
          }));
        },
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Payment/Add_payment_detail.dart';
import 'package:scrapapp/Refund/Add_refund_details.dart';
import 'package:scrapapp/Refund/View_refund_details.dart';
import 'package:http/http.dart' as http;
import '../URL_CONSTANT.dart';

class RefundList extends StatefulWidget {
  @override
  State<RefundList> createState() => _RefundListState();
}

class _RefundListState extends State<RefundList> {

  List<dynamic> dates = [];
  List<dynamic> orderIds = [];
  List<dynamic> buyerNames = [];
  List<dynamic> data = [];
  bool isLoading = true; // Add a loading flag

  @override
  void initState() {
    super.initState();
    fetchRefundList();
  }

  Future<void> fetchRefundList() async {
    try {
      final url = Uri.parse("${URL}fetch_refund_data");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': 'Bantu',
          'user_pass': 'Bantu#123',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          var jsonData = json.decode(response.body);
          data = jsonData['aaData'];

          // Extract the relevant data
          for (var entry in data) {
            dates.add(entry[0]); // Date
            orderIds.add(entry[1]); // Order ID
            buyerNames.add(entry[5]); // Buyer Name
          }
          print(dates);
          print(orderIds);
          print(buyerNames);

          isLoading = false; // Set loading to false when data is loaded
        });
      } else {
        print("Unable to fetch data.");
        setState(() {
          isLoading = false; // Set loading to false in case of error
        });
      }
    } catch (e) {
      print("Server Exception: $e");
      setState(() {
        isLoading = false; // Set loading to false in case of exception
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: CustomAppBar(),
      body: Container(
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
                      fontSize: 23, // Slightly larger font size for prominence
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
                      backgroundColor: Color(0xFF87CEEB), // Sky Blue
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
            Container(
              height: 1.5,
              color: Color(0xFF2F4F4F), // Dark Slate Gray
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
                    color: Color(0xFF87CEEB), // Sky Blue
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Add_refund_details()));
                  },
                ),
              ],
            ),
            Container(
              height: 1.5,
              color: Color(0xFF2F4F4F), // Dark Slate Gray
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    child: Column(
                      children: [
                        Container(
                          color: Color(0xFFE4B5), // Moccasin
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${orderIds[index]}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF2F4F4F), // Dark Slate Gray
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            leading: Icon(Icons.description, color: Color(0xFF2F4F4F)), // Dark Slate Gray
                            title: Text(
                              'Buyer : ${buyerNames[index]}',
                              style: TextStyle(color: Color(0xFF2F4F4F)), // Dark Slate Gray
                            ),
                            subtitle: Text('Material\nDate${dates[index]}', style: TextStyle(color: Color(0xFF2F4F4F))), // Dark Slate Gray
                            trailing: Icon(Icons.chevron_right, color: Color(0xFF87CEEB)), // Sky Blue
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => View_refund_details()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

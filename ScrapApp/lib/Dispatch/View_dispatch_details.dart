import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Dispatch/Add_dispatch_details.dart';
import 'package:scrapapp/Dispatch/View_dispatch_lifting_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../URL_CONSTANT.dart';
import 'addDispatchToSaleOrder.dart';

class View_dispatch_details extends StatefulWidget {
  final String sale_order_id;
  final String bidder_id;

  View_dispatch_details({
    required this.sale_order_id,
    required this.bidder_id,
  });

  @override
  State<View_dispatch_details> createState() => _View_dispatch_detailsState();
}

class _View_dispatch_detailsState extends State<View_dispatch_details> {
  String? username = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';
  bool isLoading = false;
  Map<String, dynamic> ViewDispatchData = {};
  List<dynamic> liftingDetails = [];

  @override
  void initState() {
    super.initState();
    checkLogin().then((_){
      setState(() {});
    });
    print(widget.sale_order_id);
    print(widget.sale_order_id);
    print(widget.sale_order_id);
    fetchDispatchDetails();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
  }

  Future<void> fetchDispatchDetails() async {
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
          'user_pass': password,
          'sale_order_id': widget.sale_order_id,
          'bidder_id':widget.bidder_id,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          var jsonData = json.decode(response.body);
          ViewDispatchData = jsonData;
          var materialLiftingDetails =
              ViewDispatchData['material_lifting_details'];
          if (materialLiftingDetails != null) {
            // Convert dynamic keys into a list and access the corresponding data
            liftingDetails = materialLiftingDetails.entries
                .map((entry) => entry.value)
                .toList();
          }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentPage: 5),
      appBar: CustomAppBar(),
      body: Stack(children: [
        isLoading
            ? showLoading()
            : Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 4.0), // Match previous padding
                color: Colors.grey[100],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Dispatch",
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
                      padding: const EdgeInsets.all(
                          8.0), // Match padding from previous code
                      child: buildVendorInfo(),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            buildScrollableContainerWithListView(
                                "Lifting Details", buildInvoiceListView),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action when FAB is pressed
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => addDispatchToSaleOrder(
                  sale_order_id: widget.sale_order_id,
                  material_name: ViewDispatchData['sale_order_details']?[0]['material_name']?? 'N/A'),
            ),
          ).then((value) => setState(() {
                fetchDispatchDetails();
              }));
        },
        child: Icon(Icons.add), // FAB icon
        backgroundColor: Colors.blueGrey[200], // FAB background color
      ),
    );
  }

  Widget buildRowWithIcon(BuildContext context) {
    return Material(
      elevation: 2,
      shape: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blueGrey[400]!),
      ),
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
                      text: "Material Name: ",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  // Scrollable Text
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        "${ViewDispatchData['sale_order_details']?[0]['material_name']?? 'N/A'}",
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
            "Vendor Name: ",
            ViewDispatchData['vendor_buyer_details']['vendor_name'] ?? 'N/A',
            false),
        buildVendorInfoText(
            "Branch: ",
            ViewDispatchData['vendor_buyer_details']['branch_name'] ?? 'N/A',
            false),
        buildVendorInfoText(
            "Buyer Name: ",
            ViewDispatchData['vendor_buyer_details']['bidder_name'] ?? 'N/A',
            false),
      ],
    );
  }

  Widget buildVendorInfoText(String key, String value, bool isRed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: key, // Key text (e.g., "Vendor Name: ")
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Bold key text
              ),
            ),
            (isRed)
                ? TextSpan(
                    text: value, // Value text (e.g., "XYZ Corp")
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent, // Normal value text
                    ),
                  )
                : TextSpan(
                    text: value, // Value text (e.g., "XYZ Corp")
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black54, // Normal value text
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildScrollableContainerWithListView(
      String title, Widget Function() listViewBuilder) {
    return Container(
      height: 580,
      margin: EdgeInsets.all(8.0), // Match margin from previous code
      padding: EdgeInsets.all(8.0), // Match padding from previous code
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            height: 500, // Match height from previous code
            child: listViewBuilder(),
          ),
        ],
      ),
    );
  }

  Widget buildInvoiceListView() {
    if (liftingDetails.length != 0) {
      return ListView.builder(
        itemCount: liftingDetails.length, // Example number of items
        itemBuilder: (context, index) {
          final liftingDetailsIndex = liftingDetails[index];
          return buildInvoiceListTile(context, liftingDetailsIndex);
        },
      );
    } else {
      return Center(
        child: Text(
          "No Lifting Details Found.",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      );
    }
  }

  Widget buildInvoiceListTile(BuildContext context, index) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12.0),
          leading: CircleAvatar(
            backgroundColor: Colors.indigo[800],
            child: Icon(Icons.receipt_long, size: 24, color: Colors.white),
          ),
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Invoice: ",
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold, // Bold key
                      fontSize: 20),
                ),
                TextSpan(
                  text: "${index['invoice_no']}",
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.normal, // Normal value
                      fontSize: 20),
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
                      text: "Material: ",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold, // Bold key
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: "${index['material_name']}",
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
                      text: "Date: ",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold, // Bold key
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: "${index['date_time']}",
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
                      builder: (context) => View_dispatch_lifting_details(
                            sale_order_id: widget.sale_order_id,
                            bidder_id: widget.bidder_id,
                            lift_id: index['lift_id'],
                            selectedOrderId: ViewDispatchData['sale_order']
                                ['sale_order_code'],
                            material: index['material_name'],
                            invoiceNo: index['invoice_no'],
                            firstWeight: index['truck_weight'],
                            fullWeight: index['full_weight'],
                            moistureWeight: index['mois_weight'],
                            netWeight: index['net_weight'],
                            date: index['date_time'],
                            truckNo: index['truck_no'],
                            quantity: index['qty'],
                            note: index['note'],
                          ))).then((value) => setState(() {
                    fetchDispatchDetails();
                  }));
            },
          ),
        ),
      ),
    );
  }
}

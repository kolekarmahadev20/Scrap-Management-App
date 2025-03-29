import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';
import '../ImageViewer.dart';
import '../URL_CONSTANT.dart';

class InvoicePage extends StatefulWidget {
  final String sale_order_id;
  final String bidder_id;
  final String? invoiceNo;

  InvoicePage({
    required this.sale_order_id,
    required this.bidder_id,
    required this.invoiceNo,
  });

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  Map<String, dynamic>? invoiceData;
  List<dynamic> materialLiftingDetails = [];
  List<Map<String, String>> imageList = []; // Change List<String> to List<Map<String, String>>

  String? username = '';
  String uuid = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';

  @override
  void initState() {
    super.initState();
    fetchInvoiceData();
    fetchImageList();
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

  Future<void> fetchImageList() async {
    await checkLogin();
    final url = Uri.parse("${URL}check_url");

    print(widget.sale_order_id);
    print(widget.invoiceNo);

    var response = await http.post(
      url,
      headers: {"Accept": "application/json"},
      body: {
        'user_id': username,
        'uuid': uuid,
        'user_pass': password,
        'sale_order_id': widget.sale_order_id,
        'invoice_no': widget.invoiceNo,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List<Map<String, String>> imageDetails = []; // Store image URLs with date

      // Define base URL
      String baseUrl = "${Image_URL}";

      // Check if 'ot' key exists and is a Map
      if (data.containsKey("ot") && data["ot"].containsKey("ot") && data["ot"]["ot"] is Map) {
        Map<String, dynamic> otData = data["ot"]["ot"];

        // Iterate through each entry in "ot"
        otData.forEach((key, value) {
          if (value.containsKey("images") && value["images"] is List && value.containsKey("created_date")) {
            String createdDate = value["created_date"];
            List<String> images = List<String>.from(value["images"]);

            images.forEach((path) {
              imageDetails.add({
                "url": baseUrl + path,
                "date": createdDate
              });
            });
          }
        });
      }

      setState(() {
        imageList = imageDetails;
        print("Updated Image List with Date: $imageList");
      });
    } else {
      print("Failed to load invoice data");
    }


  }

  List<String> taxNames = [];
  List<String> taxRates = [];
  List<String> taxValues = [];

  Future<void> fetchInvoiceData() async {

    print(widget.sale_order_id);
    print(widget.bidder_id);
    print("widget.bidder_id");

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
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        invoiceData = data;
        // totalBalanceController.text = double.parse(data["total_balance"].toString()).toStringAsFixed(2);

        if (invoiceData!["material_lifting_details"] is Map) {
          // Sirf us invoice ka data filter karna
          materialLiftingDetails = invoiceData!["material_lifting_details"]
              .values
              .where((item) => item["invoice_no"] == widget.invoiceNo)
              .toList();

          if (materialLiftingDetails.isNotEmpty) {
            var selectedInvoice = materialLiftingDetails.first;

            // Agar tax_details exist karta hai to fetch karein
            if (selectedInvoice["tax_details"] != null && selectedInvoice["tax_details"] is List) {
              List<Map<String, dynamic>> taxDetails = List<Map<String, dynamic>>.from(selectedInvoice["tax_details"]);

              // Tax details ko alag variables me store karna
              taxNames = taxDetails.map((tax) => tax["tax_name"].toString()).toList();
              taxRates = taxDetails.map((tax) => tax["tax_rate"].toString()).toList();
              taxValues = taxDetails.map((tax) => tax["tax_value"].toString()).toList();

              print("Tax Names: $taxNames");
              print("Tax Rates: $taxRates");
              print("Tax Values: $taxValues");
            } else {
              print("No tax details available for this invoice.");
            }
          } else {
            print("No matching invoice found.");
          }
        }
      });
    } else {
      print("Failed to load invoice data");
    }
  }


  Widget _buildInvoiceHeader() {
    if (invoiceData == null) {
      return Center(child: Text("Invoice data not available"));
    }

    var saleOrder = invoiceData!['sale_order'] ?? {};
    var liftingDetails = invoiceData!["material_lifting_details"]
        .values
        .firstWhere(
            (item) => item["invoice_no"] == widget.invoiceNo,
        orElse: () => {});

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Invoice No: ${liftingDetails['invoice_no'] ?? 'N/A'}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    onPressed: imageList.isNotEmpty
                        ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageViewer(imgData: imageList),
                        ),
                      );
                    }
                        : null, // Disable button if no images
                    icon: Icon(
                      imageList.isNotEmpty ? Icons.image : Icons.image_not_supported, // Change icon if empty
                      size: 24,
                      color: imageList.isNotEmpty ? Colors.blue : Colors.grey, // Change color if empty
                    ),
                  )
                ],
              ),
              Divider(),
              SizedBox(height: 18),
              // Text("Invoice No: ${liftingDetails['invoice_no'] ?? 'N/A'}"),
              // Text("Material: ${liftingDetails['material_name'] ?? 'N/A'}"),
              // Text("Truck No: ${liftingDetails['truck_no'] ?? 'N/A'}"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBillToSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.black, fontSize: 18), // Default style
            children: [
              TextSpan(text: "Vendor Name: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextSpan(
                text: "${invoiceData!['vendor_buyer_details']['vendor_name']}".toUpperCase(),
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        SizedBox(height: 5), // Add spacing
        RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.black, fontSize: 18),
            children: [
              TextSpan(text: "Buyer Name: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextSpan(
                text: "${invoiceData!['vendor_buyer_details']['bidder_name']}".toUpperCase(),
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        SizedBox(height: 5),
        RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.black, fontSize: 18),
            children: [
              TextSpan(text: "Branch: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextSpan(
                text: "${invoiceData!['vendor_buyer_details']['branch_name']}".toUpperCase(),
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }



  TableRow buildTableRow(String label, String? value) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey[200]),
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text((value ?? "").toUpperCase()),
          ),
        ),
      ],
    );
  }

  TextEditingController finalAmountController = TextEditingController();
  // TextEditingController totalBalanceController = TextEditingController();

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


  @override
  Widget build(BuildContext context) {

    print("POHH:$invoiceData");

    return Scaffold(
      // drawer: AppDrawer(currentPage: 5),
      appBar: CustomAppBar(),
      body: invoiceData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInvoiceHeader(),
                    SizedBox(height: 20),
                    _buildBillToSection(),
                    SizedBox(height: 20),
                    Table(
                      border: TableBorder.all(color: Colors.white),
                      columnWidths: {
                        0: FixedColumnWidth(150),
                      },
                      children: materialLiftingDetails.asMap().entries.expand((entry) {
                        int index = entry.key;
                        var item = entry.value;

                        finalAmountController.text = double.parse(item["total_amt"].toString()).toStringAsFixed(2);

                        return [
                          buildTableRows(
                            ['INVOICE NO', 'DATE'],
                            [item["invoice_no"],formatDate(item["date_time"])
                              ],
                            1,
                          ),
                          buildTableRows(
                            ['MATERIAL NAME', 'TRUCK NO'],
                            [item["material_name"], item["truck_no"]],
                            0,
                          ),
                          buildTableRows(
                            ['QTY', 'Basic Amount'],
                            [
                              item["qty"],
                              (double.parse(item["rate"]) * double.parse(item["qty"])).toStringAsFixed(2) // Ensure 2 decimal places
                            ],
                            1,
                          ),

                          // Extra row for spacing
                          TableRow(children: [
                            Container(height: 25), // Adjust height as needed
                            Container(height: 20),
                          ]),
                        ];
                      }).toList(),
                    ),
                    // SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Text("Sub Total: ${invoiceData!["sub_total"]}",
                          //     style: TextStyle(fontWeight: FontWeight.bold)),
                          // Text("Balance Due: ${totalBalanceController.text}", style: TextStyle(color: Colors.red, fontSize: 16)),
                          SizedBox(height: 5),
                          // Tax Details Show Karne Ke Liye
                          if (materialLiftingDetails.isNotEmpty && materialLiftingDetails.first["tax_details"] != null)
                            ...materialLiftingDetails.first["tax_details"].map<Widget>((tax) {
                              return Text(
                                "${tax["tax_name"]}@${tax["tax_rate"]} % : ${tax["tax_value"]}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              );
                            }).toList(),
                          SizedBox(height: 10),
                          Text("FINAL AMOUNT	: ${finalAmountController.text}",
                              style: TextStyle(
                                  color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  TableRow buildTableRows(List<String> labels, List<String?> values, int index) {
    assert(labels.length == values.length);

    return TableRow(
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : Colors.grey[200],
      ),
      children: List.generate(labels.length, (idx) {
        return TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labels[idx],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  values[idx] != null ? values[idx]!.toString().toUpperCase() : '',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

}


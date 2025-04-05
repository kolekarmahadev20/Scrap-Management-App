import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Dispatch/Add_dispatch_details.dart';
import 'package:scrapapp/Dispatch/View_dispatch_lifting_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../URL_CONSTANT.dart';
import 'Edit_dispatch_details.dart';
import 'View_Invoice_Details.dart';
import 'addDispatchToSaleOrder.dart';
import 'editDispatchDetails.dart';

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
  String uuid = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';
  String? readonly = '';
  String? attendonly = '';
  bool isLoading = false;
  Map<String, dynamic> ViewDispatchData = {};
  List<dynamic> liftingDetails = [];

  @override
  void initState() {
    super.initState();
    checkLogin().then((_) {
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
    uuid = prefs.getString("uuid")!;
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
    readonly = prefs.getString("readonly");
    attendonly = prefs.getString("attendonly");
  }

  List<dynamic> liftedQuantity = [];
  double balanceQty = 0.0;
  double totalBalance = 0.0;
  double totalMaterialLiftedAmount = 0.0;
  Map<String, dynamic> taxAmount = {};
  Map<String, dynamic> ViewPaymentData = {};
  List<Map<String, dynamic>> taxDetailsList = [];
  List<dynamic> paymentId = [];
  List<dynamic> paymentStatus = [];
  List<dynamic> emdStatus = [];
  List<dynamic> cmdStatus = [];
  List<dynamic> taxes = [];
  var checkLiftedQty;
  var netAmount;

  Future<void> fetchDispatchDetails() async {
    try {
      print(widget.sale_order_id);
      print(widget.bidder_id);
      print("55419844894");

      setState(() {
        isLoading = true;
      });

      print(widget.sale_order_id);
      print(widget.bidder_id);
      print("4651");


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
        setState(() {
          var jsonData = json.decode(response.body);
          if (jsonData == null) {
            print("Error: Received null response.");
            return;
          }

          ViewDispatchData = jsonData;
          var materialLiftingDetails =
              ViewDispatchData?['material_lifting_details'];
          if (materialLiftingDetails != null && materialLiftingDetails is Map) {
            liftingDetails = materialLiftingDetails.entries
                .map((entry) => entry.value)
                .toList();
          } else {
            liftingDetails = [];
          }

          ViewPaymentData = jsonData;
          paymentId = ViewPaymentData?['sale_order_payments'] ?? [];
          emdStatus = ViewPaymentData?['emd_status'] ?? [];
          cmdStatus = ViewPaymentData?['cmd_status'] ?? [];
          paymentStatus = ViewPaymentData?['recieved_payment'] ?? [];
          checkLiftedQty = ViewPaymentData?['lifted_quantity'];
          taxes = ViewPaymentData?['tax_and_rate']?['taxes'] ?? [];
          taxAmount = ViewPaymentData?['tax_and_rate'] ?? {};

          totalMaterialLiftedAmount =
              jsonData['total_material_lifted_amount'] ?? 0;
          liftedQuantity = jsonData['lifted_quantity'] != null
              ? List<Map<String, dynamic>>.from(jsonData['lifted_quantity'])
              : [];

          taxDetailsList = jsonData['taxDetails'] != null
              ? List<Map<String, dynamic>>.from(jsonData['taxDetails'])
              : [];

          balanceQty = (jsonData['balance_qty'] ?? 0).toDouble();
          totalBalance = (jsonData['total_balance'] ?? 0).toDouble();
        });
      } else {
        print("Unable to fetch data.");
      }
    } catch (e) {
      print("Server Exceptionasfasf: $e");
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

  Widget buildExpansionTile() {
    return Material(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Sale Order Details",
                style: TextStyle(
                  fontSize: 21, // Increase font size
                  fontWeight: FontWeight.bold, // Make it bold
                ),
              ),
            ),
            buildPaymentDetailsCard(ViewPaymentData),
            buildSummary(),

            // buildListTile(
            //     "Material Name : ${ViewPaymentData['sale_order_details']?[0]['material_name'] ?? 'N/A'}"),
            // buildListTile(
            //     "Total Qty : ${ViewPaymentData['sale_order_details'][0]['qty'] ?? 'No data'} ${ViewPaymentData['sale_order_details'][0]['totunit'] ?? ''}"),
            // if (ViewPaymentData['lifted_quantity'] != null &&
            //     ViewPaymentData['lifted_quantity'] is List &&
            //     ViewPaymentData['lifted_quantity'].isNotEmpty)
            //   buildListTile(
            //       "Lifted Qty : ${ViewPaymentData['lifted_quantity'][0]['quantity'] ?? 'No data'} ${ViewPaymentData['sale_order_details'][0]['totunit'] ?? ''}"),
            // buildListTile(
            //     "Rate : ${ViewPaymentData['sale_order_details'][0]['rate'] ?? 'No data'}"),
            // buildListTile(
            //     "SO Date : ${ViewPaymentData['sale_order_details'][0]['sod'] ?? 'No data'}"),
            // buildListTile(
            //     "SO Validity : ${ViewPaymentData['sale_order_details'][0]['sovu'] ?? 'No data'}
            Divider(),
            buildTable(),
            Divider(),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentDetailsCard(Map<String, dynamic> ViewPaymentData) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDetailTile(
                "Material Name : ",
                ViewPaymentData['sale_order_details']?[0]['material_name'] ??
                    'N/A',
                Icons.category),
            buildDetailTile(
                "Total Qty : ",
                "${ViewPaymentData['sale_order_details'][0]['qty'] ?? 'No data'} ${ViewPaymentData['sale_order_details'][0]['totunit'] ?? ''}",
                Icons.inventory),
            // buildDetailTile(
            //     "Balance Qty : ",
            //     "${ViewPaymentData['sale_order_details'][0]['qty'] ?? 'No data'} ${ViewPaymentData['sale_order_details'][0]['totunit'] ?? ''}",
            //     Icons.inventory),
            if (ViewPaymentData['lifted_quantity'] != null &&
                ViewPaymentData['lifted_quantity'] is List &&
                ViewPaymentData['lifted_quantity'].isNotEmpty)
              buildDetailTile(
                  "Lifted Qty : ",
                  "${ViewPaymentData['lifted_quantity'][0]['quantity'] ?? 'No data'} ${ViewPaymentData['sale_order_details'][0]['totunit'] ?? ''}",
                  Icons.local_shipping),
            buildDetailTile(
                "Rate : ",
                ViewPaymentData['sale_order_details'][0]['rate']?.toString() ??
                    'No data',
                Icons.attach_money),
            buildDetailTile(
                "SO Date : ",
                formatDate(ViewPaymentData['sale_order_details'][0]['sod']),
                Icons.date_range),
            buildDetailTile(
                "SO Validity : ",
                formatDate(ViewPaymentData['sale_order_details'][0]['sovu']),
                Icons.event_available),
          ],
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

  Widget buildTable() {
    // Use a Set to keep track of unique tax names
    Set<String> uniqueTaxNames = {};
    List<Map<String, dynamic>> uniqueTaxes = [];

    for (var tax in taxes) {
      if (!uniqueTaxNames.contains(tax['tax_name'])) {
        uniqueTaxNames.add(tax['tax_name']);
        uniqueTaxes.add(tax);
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: 400,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              spreadRadius: 2,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: DataTable(
          columnSpacing: 20,
          headingRowHeight: 48,
          dataRowHeight: 44,
          border: TableBorder.symmetric(
            inside: BorderSide(color: Colors.grey.shade300),
          ),
          columns: [
            DataColumn(
              label: Text(
                'Tax',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),
            DataColumn(
              label: Text(
                'Amount',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),
          ],
          rows: [
            DataRow(
              color: MaterialStateProperty.all(Colors.grey.shade200),
              cells: [
                DataCell(Text('Basic Amount',
                    style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text('₹${taxAmount['basicTaxAmount']}',
                    style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            if (uniqueTaxes.isNotEmpty)
              ...uniqueTaxes.map((tax) {
                return DataRow(
                  cells: [
                    DataCell(Text(tax['tax_name'] ?? 'No data')),
                    DataCell(Text('₹${tax['tax_amount'] ?? 'No data'}')),
                  ],
                );
              }).toList(),
            DataRow(
              color: MaterialStateProperty.all(Colors.grey.shade200),
              cells: [
                DataCell(Text('Final SO Amount',
                    style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text('₹${taxAmount['finalTaxAmount']}',
                    style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailTile(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSummary() {
    return Container(
      color: Colors.white, // Set background color to white
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSummaryRow(
              "Lifted Quantity:",
              liftedQuantity.isNotEmpty
                  ? "${liftedQuantity[0]['quantity']} ${ViewPaymentData['sale_order_details'][0]['totunit'] ?? ""}"
                  : "N/A",
              totalMaterialLiftedAmount != null
                  ? totalMaterialLiftedAmount.toStringAsFixed(2)
                  : "N/A"),
          buildSummaryRow(
              "SO Balance Qty:",
              balanceQty != null
                  ? "${balanceQty.toStringAsFixed(2)} ${ViewPaymentData['sale_order_details'][0]['totunit'] ?? ""}"
                  : "N/A",
              totalBalance != null ? totalBalance.toStringAsFixed(2) : "N/A"),
        ],
      ),
    );
  }

  Widget buildSummaryRow(String title, String qty, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 20),
          Text(qty),
          SizedBox(width: 20),
          Text(amount),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentPage: 5),
      appBar: CustomAppBar(),
      body: isLoading
          ? showLoading()
          : Container(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              color: Colors.grey[100],
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Dispatch",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: buildVendorInfo(),
                    ),
                    buildExpansionTile(),
                    SizedBox(height: 16),

                    /// Wrap `ListView.builder` inside `Expanded`

                    SizedBox(
                      height: 300, // Adjust the height as needed

                      child: liftingDetails.isNotEmpty
                          ? ListView.builder(
                              itemCount: liftingDetails.length,
                              itemBuilder: (context, index) {
                                final liftingDetailsIndex =
                                    liftingDetails[index];
                                return buildInvoiceListTile(
                                    context, liftingDetailsIndex);
                              },
                            )
                          : Center(
                              child: Text(
                                "No Lifting Details Found.",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
           floatingActionButton: readonly != 'Y'
          ? FloatingActionButton(
              onPressed: () {
                // Action when FAB is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => addDispatchToSaleOrder(
                     // balanceqty:balanceQty.toStringAsFixed(2),
                      balanceqty: balanceQty.toString(),

                      sale_order_id: widget.sale_order_id,
                      material_name: ViewDispatchData['sale_order_details']?[0]
                              ['material_name'] ??
                          'N/A',
                      bidder_id: widget.bidder_id,
                      totalQty:ViewDispatchData['sale_order_details']?[0]
                      ['qty'] ??
                          'N/A',
                    ),
                  ),
                ).then((value) => setState(() {
                      fetchDispatchDetails();
                    }));
              },
              child: Icon(Icons.add), // FAB icon
              backgroundColor: Colors.blueGrey[200], // FAB background color
            ): null,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Action when FAB is pressed
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => addDispatchToSaleOrder(
      //           sale_order_id: widget.sale_order_id,
      //           material_name: ViewDispatchData['sale_order_details']?[0]
      //                   ['material_name'] ??
      //               'N/A',
      //           bidder_id: widget.bidder_id,
      //           totalQty:ViewDispatchData['sale_order_details']?[0]
      //           ['qty'] ??
      //               'N/A',
      //
      //
      //           balanceqty:balanceQty.toStringAsFixed(2),
      //
      //         ),
      //       ),
      //     ).then((value) => setState(() {
      //           fetchDispatchDetails();
      //         }));
      //   },
      //   child: Icon(Icons.add), // FAB icon
      //   backgroundColor: Colors.blueGrey[200], // FAB background color
      // ),
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
                        fontSize: 21,
                      ),
                    ),
                  ),
                  // Scrollable Text
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        "${ViewDispatchData['sale_order_details']?[0]['material_name'] ?? 'N/A'}",
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
            "Vendor Name : ",
            (ViewPaymentData['vendor_buyer_details']['vendor_name'] ?? 'N/A')
                .toString()
                .toUpperCase(),
            false),
        buildVendorInfoText(
            "Branch : ",
            (ViewPaymentData['vendor_buyer_details']['branch_name'] ?? 'N/A')
                .toString()
                .toUpperCase(),
            false),
        buildVendorInfoText(
            "Buyer Name : ",
            (ViewPaymentData['vendor_buyer_details']['bidder_name'] ?? 'N/A')
                .toString()
                .toUpperCase(),
            false),
      ],
    );
  }

  Widget buildVendorInfoText(String key, String value, bool isRed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Push key left & value right
        children: [
          Text(
            key,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black, // Bold key text
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isRed ? FontWeight.bold : FontWeight.normal,
                color: isRed
                    ? Colors.redAccent
                    : Colors.black54, // Color based on isRed
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InvoicePage(
                sale_order_id: widget.sale_order_id,
                invoiceNo: index['invoice_no'],
                bidder_id: widget.bidder_id,
                lift_id: index['lift_id'],
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12), // Optional for ripple effect
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Invoice Details UI
                Row(
                  children: [
                    Icon(Icons.receipt_long, color: Colors.indigo[800], size: 28),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Invoice: ${index['invoice_no']}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    if (readonly != 'Y') ...[
                      if (index['status'] != 'c')
                        ElevatedButton(
                          onPressed: () {
                            dynamic imagesData = index['images'];
                            String? imagesUrl;

                            if (imagesData is List) {
                              imagesUrl = imagesData.cast<String>().join(", ");
                            } else if (imagesData is String && imagesData.isNotEmpty) {
                              imagesUrl = imagesData;
                            }


                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditDispatchDetails(
                                  // balanceqty:balanceQty.toStringAsFixed(2),

                                  balanceqty: balanceQty.toString(),
                                  sale_order_id: widget.sale_order_id,
                                  bidder_id: widget.bidder_id,
                                  status: index['status'] ?? '',
                                  lift_id: index['lift_id'] ?? '',
                                  material_name: index['material_name'] ?? '',
                                  invoiceNo: index['invoice_no'] ?? '',
                                  date: index['date_time'] ?? '',
                                  truckNo: index['truck_no'] ?? '',
                                  firstweight: index['truck_weight']?.toString() ?? '',
                                  full_weight: index['full_weight']?.toString() ?? '',
                                  netweight: index['net_weight']?.toString() ?? '',
                                  moisweight: index['mois_weight']?.toString() ?? '',
                                  qty: index['qty']?.toString() ?? '',
                                  note: index['note'] ?? '',
                                  totalQty: ViewDispatchData['sale_order_details']?[0]['qty'] ?? 'N/A',
                                  imagesUrl: imagesUrl,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18, color: Colors.white),
                              SizedBox(width: 6),
                              Text("Edit", style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                    ]

                    // if(index['status'] != 'c')
                    //  ElevatedButton(
                    //     onPressed:  () {
                    //
                    //       dynamic imagesData = index['images']; // It can be a List or String
                    //
                    //       // ✅ Convert it to a comma-separated string
                    //       String? imagesUrl;
                    //
                    //       if (imagesData is List) {
                    //         // Case 1: It's already a List<String>
                    //         imagesUrl = imagesData.cast<String>().join(", ");
                    //       } else if (imagesData is String && imagesData.isNotEmpty) {
                    //         // Case 2: It's already a comma-separated String
                    //         imagesUrl = imagesData;
                    //       }
                    //
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) =>
                    //               EditDispatchDetails(
                    //                 sale_order_id: widget.sale_order_id,
                    //                 bidder_id: widget.bidder_id,
                    //                 status: index['status'] ?? '',
                    //                 lift_id: index['lift_id'] ?? '',
                    //                 material_name: index['material_name'] ?? '',
                    //                 invoiceNo: index['invoice_no'] ?? '',
                    //                 date: index['date_time'] ?? '',
                    //                 truckNo: index['truck_no'] ?? '',
                    //                 firstweight: index['truck_weight']?.toString() ?? '',
                    //                 full_weight: index['full_weight']?.toString() ?? '',
                    //                 netweight: index['net_weight']?.toString() ?? '',
                    //                 moisweight: index['mois_weight']?.toString() ?? '',
                    //                 qty: index['qty']?.toString() ?? '',
                    //                 note: index['note'] ?? '',
                    //                 totalQty:ViewDispatchData['sale_order_details']?[0]
                    //                 ['qty'] ??
                    //                     'N/A',
                    //                 balanceqty:balanceQty.toStringAsFixed(2),
                    //                 imagesUrl: imagesUrl, // ✅ Now it's a String!
                    //
                    //
                    //
                    //               ),
                    //         ),
                    //       );
                    //     },
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.blue,
                    //     foregroundColor: Colors.white,
                    //     padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       Icon(Icons.edit, size: 18, color: Colors.white),
                    //       SizedBox(width: 6),
                    //       Text("Edit", style: TextStyle(fontSize: 16)),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),

                Row(
                  children: [
                    Icon(Icons.category, color: Colors.indigo[800], size: 25),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Material: ${index['material_name']}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Icon(Icons.date_range, color: Colors.indigo[800], size: 25),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Date: ${formatDate(index['date_time'])}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.indigo[800], size: 25),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Dispatch By: ${index['person_name']}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Status:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      index['status'] == 'p'
                          ? "Dispatch Pending"
                          : "Dispatch Completed",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: index['status'] == 'p'
                            ? Colors.red
                            : Colors.green.shade600,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey[600]),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Helper Widget for Details
  Widget buildDetailItem(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$label: ",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

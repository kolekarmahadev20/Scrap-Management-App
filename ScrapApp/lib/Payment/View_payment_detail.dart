import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Payment/View_Payment_Amount.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Dispatch/View_dispatch_details.dart';
import '../Refund/View_refund_details.dart';
import '../URL_CONSTANT.dart';
import 'addPaymentToSaleOrder.dart';

class View_payment_detail extends StatefulWidget {
  final String sale_order_id;
  final String bidder_id;
  final String branch_id_from_ids;
  final String vendor_id_from_ids;

  View_payment_detail({
    required this.sale_order_id,
    required this.bidder_id,
    required this.branch_id_from_ids,
    required this.vendor_id_from_ids,
  });

  @override
  State<View_payment_detail> createState() => _View_payment_detailState();
}

class _View_payment_detailState extends State<View_payment_detail> {
  String? username = '';
  String uuid = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';
  var checkLiftedQty;
  bool isLoading = false;

  Map<String, dynamic> taxAmount = {};
  Map<String, dynamic> ViewPaymentData = {};
  List<dynamic> paymentId = [];
  List<dynamic> paymentStatus = [];
  List<dynamic> emdStatus = [];
  List<dynamic> cmdStatus = [];
  List<dynamic> taxes = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.bidder_id);
    checkLogin().then((_) {
      setState(() {});
    });
    fetchPaymentDetails();
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

  Future<void> fetchPaymentDetails() async {
    print("asfasfasf");
    print("Sale Order ID: ${widget.sale_order_id}");
    print("Bidder ID: ${widget.bidder_id}");

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
          'uuid': uuid,
          'user_pass': password,
          'sale_order_id': widget.sale_order_id,
          'bidder_id': widget.bidder_id,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          var jsonData = json.decode(response.body);
          ViewPaymentData = jsonData;
          paymentId = ViewPaymentData['sale_order_payments'] ?? [];
          emdStatus = ViewPaymentData['emd_status'] ?? [];
          cmdStatus = ViewPaymentData['cmd_status'] ?? [];
          paymentStatus = ViewPaymentData['recieved_payment'] ?? [];
          checkLiftedQty = ViewPaymentData['lifted_quantity'];
          taxes = ViewPaymentData['tax_and_rate']['taxes'] ?? [];
          taxAmount = ViewPaymentData['tax_and_rate'] ?? {};
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

  int _selectedIndex = 0;

  Widget buildBottomNavButtons(
      BuildContext context, int selectedIndex, Function(int) onItemTapped) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center buttons
        children: [
          buildNavButton(Icons.payment, "Payment \nDetails", 0, selectedIndex, onItemTapped),
          SizedBox(width: 20), // Space between buttons
          buildNavButton(Icons.local_shipping, "Refund \nDetails", 3,
              selectedIndex, onItemTapped),        ],
      ),
    );
  }

  List<Color> buttonColors = [
    Colors.green,  // Payment Details
    Colors.orange, // EMD Details
    Colors.red,    // CMD Details
    Colors.blue,   // Dispatch Details
  ];

  Widget buildNavButton(IconData icon, String label, int index,
      int selectedIndex, Function(int) onItemTapped) {
    return SizedBox(
      width: 140, // Ensuring both buttons are equal width
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => onItemTapped(index),
        icon: Icon(
          icon,
          size: 18,
          color: selectedIndex == index ? Colors.white : buttonColors[index],
        ),
        label: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: selectedIndex == index ? Colors.white : buttonColors[index],
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedIndex == index ? buttonColors[index] : Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: buttonColors[index]),
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      // buildMaterialListTab(),
      buildScrollableTabContent(context, buildPaymentDetailListView),
      // buildScrollableTabContent(context, buildEmdDetailListView),
      // buildScrollableTabContent(context, buildCMDDetailListView),
    ];

    return AbsorbPointer(
      absorbing: isLoading,
      child: Scaffold(
        drawer: AppDrawer(currentPage: 4),
        appBar: CustomAppBar(),
        body: isLoading
            ? showLoading()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Payment",
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
                      padding: const EdgeInsets.all(8.0),
                      child: buildVendorInfo(),
                    ),
                    buildExpansionTile(),
                    SizedBox(height: 10), // Spacer before content
                    IndexedStack(
                      index: _selectedIndex,
                      children: _pages,
                    ),
                  ],
                ),
              ),
        bottomNavigationBar:
            buildBottomNavButtons(context, _selectedIndex, (index) {
          setState(() {
            _selectedIndex = index;
            // Navigate to DispatchList when Dispatch is tapped
            if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => View_refund_details(
                          sale_order_id: widget.sale_order_id,
                          bidder_id: widget.bidder_id,
                          branch_id_from_ids: widget.branch_id_from_ids,
                          vendor_id_from_ids: widget.vendor_id_from_ids,
                        )), // Navigate to DispatchList Page
              );
            }
          });
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => addPaymentToSaleOrder(
                  sale_order_id: widget.sale_order_id,
                  material_name: ViewPaymentData['sale_order_details']?[0]
                          ['material_name'] ??
                      'N/A',
                  vendor_id_from_ids: widget.vendor_id_from_ids,
                  branch_id_from_ids: widget.branch_id_from_ids,
                ),
              ),
            ).then((value) => setState(() {
                  fetchPaymentDetails();
                }));
          },
          child: Icon(Icons.add), // FAB icon
          backgroundColor: Colors.blueGrey[200],
        ),
      ),
    );
  }

  Widget buildScrollableTabContent(
      BuildContext context, Widget Function() listViewBuilder) {
    return listViewBuilder();
  }



  Widget buildRowWithIcon(BuildContext context) {
    return Material(
      elevation: 2,
      color: Colors.white,
      shape: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueGrey[400]!)),
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
                      text: "Material Name : ",
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
                        "${ViewPaymentData['sale_order_details']?[0]['material_name'] ?? 'N/A'}",
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Push key left & value right
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
                color: isRed ? Colors.redAccent : Colors.black54, // Color based on isRed
              ),
            ),
          ),
        ],
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
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            buildPaymentDetailsCard(ViewPaymentData),

            Divider(),
            buildTable(),
            SizedBox(height: 10), // Spacing between sections

            /// EMD Details ListView
            // Text(
            //   "EMD Details",
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            buildEmdDetailListView(),  // ❌ `context` hata diya

            SizedBox(height: 10), // Spacing

            /// CMD Details ListView
            // Text(
            //   "CMD Details",
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            buildCMDDetailListView(),  // ❌ `context` hata diya
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                ViewPaymentData['sale_order_details']?[0]['material_name'] ?? 'N/A',
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
                ViewPaymentData['sale_order_details'][0]['rate']?.toString() ?? 'No data',
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            DataColumn(
              label: Text(
                'Amount',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          ],
          rows: [
            DataRow(
              color: MaterialStateProperty.all(Colors.grey.shade200),
              cells: [
                DataCell(Text('Basic Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text('₹${taxAmount['basicTaxAmount']}', style: TextStyle(fontWeight: FontWeight.bold))),
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
                DataCell(Text('Final SO Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text('₹${taxAmount['finalTaxAmount']}', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMaterialListTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildExpansionTile(),
        ],
      ),
    );
  }

  Widget buildPaymentDetailListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment Details Heading
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            "Payment Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Payment Details List or No Data Message
        if (paymentStatus.isNotEmpty)
          ListView.builder(
            shrinkWrap: true, // Prevents infinite scroll issue
            physics:
                NeverScrollableScrollPhysics(), // Disables separate scrolling
            itemCount: paymentStatus.length,
            itemBuilder: (context, index) {
              final paymentIdIndex = paymentStatus[index];
              return buildPaymentDetailListTile(context, paymentIdIndex);
            },
          )
        else
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "No Payment Details Found",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18,color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildEmdDetailListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // EMD Details Heading
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            "EMD Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // EMD Details List or No Data Message
        if (emdStatus.isNotEmpty)
          ListView.builder(
            shrinkWrap: true, // Prevents infinite scroll issue
            physics:
                NeverScrollableScrollPhysics(), // Disables separate scrolling
            itemCount: emdStatus.length,
            itemBuilder: (context, index) {
              final emdStatusIndex = emdStatus[index];
              return buildEmdDetailListTile(context, emdStatusIndex);
            },
          )
        else
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "No EMD Details Found",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18,color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildCMDDetailListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CMD Details Heading
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            "CMD Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // CMD Details List or No Data Message
        if (cmdStatus.isNotEmpty)
          ListView.builder(
            shrinkWrap: true, // Prevents infinite scroll issue
            physics:
                NeverScrollableScrollPhysics(), // Disables separate scrolling
            itemCount: cmdStatus.length,
            itemBuilder: (context, index) {
              final cmdStatusIndex = cmdStatus[index];
              return buildCMDDetailListTile(context, cmdStatusIndex);
            },
          )
        else
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "No CMD Details Found",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18,color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildPaymentDetailListTile(BuildContext context, index) {
    if (index['payment_type'] == "Received Payment") {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(1),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12.0),
              leading: CircleAvatar(
                backgroundColor: Colors.indigo[800],
                child: Icon(Icons.border_outer, size: 24, color: Colors.white),
              ),
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Amount : ",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold, // Bold key
                        fontSize: 20,
                      ),
                    ),
                    TextSpan(
                      text: "${index['amt'] ?? 'N/A'}",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.normal, // Normal value
                        fontSize: 20,
                      ),
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
                          text: "Ref No : ",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold, // Bold key
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: "${index['pay_ref_no'] ?? 'N/A'}",
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
                          text: "Date : ",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold, // Bold key
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: formatDate(index['date'] ?? 'N/A'),
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
                  // Action on tapping the arrow
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => View_Payment_Amount(
                          branch_id_from_ids: widget.branch_id_from_ids,
                          vendor_id_from_ids: widget.vendor_id_from_ids,
                          sale_order_id: widget.sale_order_id,
                          bidder_id: widget.bidder_id,
                          paymentId: index['payment_id'] ?? 'N/A',
                          paymentType: index['payment_type'] ?? 'N/A',
                          date1: index['date'] ?? 'N/A',
                          amount: index['amt'] ?? 'N/A',
                          referenceNo: index['pay_ref_no'] ?? 'N/A',
                          typeOfTransfer: index['typeoftransfer'] ?? 'N/A',
                          remark: index['narration'] ?? 'N/A',
                          freezed: index['freezed'] ?? 'N/A'),
                    ),
                  ).then((value) => setState(() {
                        fetchPaymentDetails();
                      }));
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => View_Payment_Amount(
                        sale_order_id: widget.sale_order_id,
                        bidder_id: widget.bidder_id,
                        branch_id_from_ids: widget.branch_id_from_ids,
                        vendor_id_from_ids: widget.vendor_id_from_ids,
                        paymentId: index['payment_id'] ?? 'N/A',
                        paymentType: index['payment_type'] ?? 'N/A',
                        date1: index['date'] ?? 'N/A',
                        amount: index['amt'] ?? 'N/A',
                        referenceNo: index['pay_ref_no'] ?? 'N/A',
                        typeOfTransfer: index['typeoftransfer'] ?? 'N/A',
                        remark: index['narration'] ?? 'N/A',
                        freezed: index['freezed'] ?? 'N/A'),
                  ),
                ).then((value) => setState(() {
                      fetchPaymentDetails();
                    }));
              },
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget buildEmdDetailListTile(BuildContext context, index) {
    if (index['payment_type'] == "Received EMD") {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(1),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12.0),
              leading: CircleAvatar(
                backgroundColor: Colors.indigo[800],
                child: Icon(Icons.account_balance_wallet_rounded,
                    size: 24, color: Colors.white),
              ),
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Amount : ",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold, // Bold key
                        fontSize: 20,
                      ),
                    ),
                    TextSpan(
                      text: "${index['amt'] ?? 'N/A'}",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.normal, // Normal value
                        fontSize: 20,
                      ),
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
                          text: "Ref No : ",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold, // Bold key
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: "${index['pay_ref_no'] ?? 'N/A'}",
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
                          text: "Date : ",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold, // Bold key
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: formatDate(index['date'] ?? 'N/A'),
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
                  // Action on tapping the arrow
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => View_Payment_Amount(
                          branch_id_from_ids: widget.branch_id_from_ids,
                          vendor_id_from_ids: widget.vendor_id_from_ids,
                          sale_order_id: widget.sale_order_id,
                          bidder_id: widget.bidder_id,
                          paymentId: index['payment_id'] ?? "N/A",
                          paymentType: index['payment_type'] ?? "N/A",
                          date1: index['date'] ?? "N/A",
                          amount: index['amt'] ?? "N/A",
                          referenceNo: index['pay_ref_no'] ?? "N/A",
                          typeOfTransfer: index['typeoftransfer'] ?? "N/A",
                          remark: index['narration'] ?? 'N/A',
                          freezed: index['freezed'] ?? 'N/A'),
                    ),
                  ).then((value) => setState(() {
                        fetchPaymentDetails();
                      }));
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => View_Payment_Amount(
                        branch_id_from_ids: widget.branch_id_from_ids,
                        vendor_id_from_ids: widget.vendor_id_from_ids,
                        sale_order_id: widget.sale_order_id,
                        bidder_id: widget.bidder_id,
                        paymentId: index['payment_id'] ?? "N/A",
                        paymentType: index['payment_type'] ?? "N/A",
                        date1: index['date'] ?? "N/A",
                        amount: index['amt'] ?? "N/A",
                        referenceNo: index['pay_ref_no'] ?? "N/A",
                        typeOfTransfer: index['typeoftransfer'] ?? "N/A",
                        remark: index['narration'] ?? 'N/A',
                        freezed: index['freezed'] ?? 'N/A'),
                  ),
                ).then((value) => setState(() {
                      fetchPaymentDetails();
                    }));
              },
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget buildCMDDetailListTile(BuildContext context, index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12.0),
            leading: CircleAvatar(
              backgroundColor: Colors.indigo[800],
              child: Icon(Icons.account_balance_wallet_rounded,
                  size: 24, color: Colors.white),
            ),
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Amount : ",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold, // Bold key
                      fontSize: 20,
                    ),
                  ),
                  TextSpan(
                    text: "${index['amt'] ?? 'N/A'}",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.normal, // Normal value
                      fontSize: 20,
                    ),
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
                        text: "Ref No : ",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold, // Bold key
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: "${index['pay_ref_no'] ?? 'N/A'}",
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
                        text: "Date : ",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold, // Bold key
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: formatDate(index['date'] ?? 'N/A'),
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
                    builder: (context) => View_Payment_Amount(
                        branch_id_from_ids: widget.branch_id_from_ids,
                        vendor_id_from_ids: widget.vendor_id_from_ids,
                        sale_order_id: widget.sale_order_id,
                        bidder_id: widget.bidder_id,
                        paymentId: index['payment_id'] ?? "N/A",
                        paymentType: index['payment_type'] ?? "N/A",
                        date1: index['date'] ?? "N/A",
                        amount: index['amt'] ?? "N/A",
                        referenceNo: index['pay_ref_no'] ?? "N/A",
                        typeOfTransfer: index['typeoftransfer'] ?? "N/A",
                        remark: index['narration'] ?? 'N/A',
                        freezed: index['freezed'] ?? 'N/A'),
                  ),
                ).then((value) => setState(() {
                      fetchPaymentDetails();
                    }));
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => View_Payment_Amount(
                      branch_id_from_ids: widget.branch_id_from_ids,
                      vendor_id_from_ids: widget.vendor_id_from_ids,
                      sale_order_id: widget.sale_order_id,
                      bidder_id: widget.bidder_id,
                      paymentId: index['payment_id'] ?? "N/A",
                      paymentType: index['payment_type'] ?? "N/A",
                      date1: index['date'] ?? "N/A",
                      amount: index['amt'] ?? "N/A",
                      referenceNo: index['pay_ref_no'] ?? "N/A",
                      typeOfTransfer: index['typeoftransfer'] ?? "N/A",
                      remark: index['narration'] ?? 'N/A',
                      freezed: index['freezed'] ?? 'N/A'),
                ),
              ).then((value) => setState(() {
                    fetchPaymentDetails();
                  }));
            },
          ),
        ),
      ),
    );
  }
}

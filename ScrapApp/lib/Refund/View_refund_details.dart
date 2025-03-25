import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Refund/View_Refund_Amount.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../URL_CONSTANT.dart';
import 'addRefundToSaleOrder.dart';

class View_refund_details extends StatefulWidget {
  final String branch_id_from_ids;
  final String vendor_id_from_ids;
  final String? sale_order_id;
  final String bidder_id;

  View_refund_details({
    required this.sale_order_id,
    required this.bidder_id,
    required this.branch_id_from_ids,
    required this.vendor_id_from_ids
  });

  @override
  State<View_refund_details> createState() => _View_refund_detailsState();
}

class _View_refund_detailsState extends State<View_refund_details> {

  String? username = '';
 String uuid = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';
  bool isLoading = false;

  Map<String , dynamic> taxAmount = {};
  Map<String, dynamic> ViewRefundData = {};
  List<dynamic> refundId = [];
  List<dynamic> refundStatus =[];
  List<dynamic> emdStatus = [];
  List<dynamic> cmdStatus = [];
  List<dynamic> taxes =[];

  @override
  void initState() {
    super.initState();
    checkLogin().then((_){
      setState(() {});
    });
    fetchRefundDetails();
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

  Future<void> fetchRefundDetails() async {
    try {
      setState(() {
        isLoading = true;
      });
      await checkLogin();
      final url = Uri.parse("${URL}closuredetails");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid':uuid,
          'user_pass': password,
          'sale_order_id': widget.sale_order_id,
          'bidder_id': widget.bidder_id,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          var jsonData = json.decode(response.body);
          ViewRefundData = jsonData;
          refundId = ViewRefundData['sale_order_payments'] ?? [];
          refundStatus =  ViewRefundData['recieved_payment'] ?? [];
          emdStatus = ViewRefundData['emd_status'] ?? [];
          cmdStatus = ViewRefundData['cmd_status'] ?? [];
          taxes = ViewRefundData['tax_and_rate']['taxes'] ?? [];
          taxAmount = ViewRefundData['tax_and_rate'] ?? {};
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Allow horizontal scrolling
        child: Wrap(
          spacing: 8, // Space between buttons
          alignment: WrapAlignment.center,
          children: [
            buildNavButton(Icons.payment, "Payment Details", 0, selectedIndex,
                onItemTapped),
            buildNavButton(Icons.account_balance, "EMD Details", 1,
                selectedIndex, onItemTapped),
            buildNavButton(Icons.security, "CMD Details", 2, selectedIndex,
                onItemTapped),
          ],
        ),
      ),
    );
  }

  List<Color> buttonColors = [
    Colors.green,  // Payment Details
    Colors.orange, // EMD Details
    Colors.blue,    // CMD Details
  ];

  Widget buildNavButton(IconData icon, String label, int index,
      int selectedIndex, Function(int) onItemTapped) {
    return ElevatedButton.icon(
      onPressed: () => onItemTapped(index),
      icon: Icon(icon,
          size: 18, color: selectedIndex == index ? Colors.white : buttonColors[index]),
      label: Text(label,
          style: TextStyle(
              fontSize: 12,
              color: selectedIndex == index ? Colors.white : buttonColors[index])),
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedIndex == index ? buttonColors[index] : Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: buttonColors[index]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> _pages = [
      // buildMaterialListTab(),
      buildScrollableTabContent(context, buildPaymentListView),
      buildScrollableTabContent(context, buildEmdListView),
      buildScrollableTabContent(context, buildCMDDetailListView),
    ];

    return AbsorbPointer(
      absorbing: isLoading,
      child: Scaffold(
        drawer: AppDrawer(currentPage: 6),
        appBar: CustomAppBar(),
        body: isLoading
            ? showLoading()
            : SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Refund",
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
            // if (index == 3) {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => View_dispatch_details(
            //           sale_order_id: widget.sale_order_id,
            //           bidder_id: widget.bidder_id,
            //         )), // Navigate to DispatchList Page
            //   );
            // }
          });
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => addRefundToSaleOrder(
                  sale_order_id: widget.sale_order_id!,
                  material_name: ViewRefundData['sale_order_details']?[0]
                  ['material_name'] ??
                      'N/A',
                  branch_id_from_ids: widget.branch_id_from_ids, // Extracted from "Ids"
                  vendor_id_from_ids: widget.vendor_id_from_ids, // Extracted from "Ids"
                ),
              ),
            ).then((value) => setState(() {
              fetchRefundDetails();
            }));
          },
          child: Icon(Icons.add), // FAB icon
          backgroundColor: Colors.blueGrey[200],
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

  Widget buildScrollableTabContent(
      BuildContext context, Widget Function() listViewBuilder) {
    return listViewBuilder();
  }

  Widget buildRowWithIcon(BuildContext context) {
    return Material(
      elevation: 2,
      color: Colors.white,
      shape: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueGrey[400]!)
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
                        "${ViewRefundData['sale_order_details']?[0]['material_name']?? 'N/A'}",
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

  Widget buildVendorInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildVendorInfoText(
            "Vendor Name : ",
            ViewRefundData['vendor_buyer_details']['vendor_name'] ?? 'N/A',
            false),
        buildVendorInfoText(
            "Branch : ",
            ViewRefundData['vendor_buyer_details']['branch_name'] ?? 'N/A',
            false),
        buildVendorInfoText(
            "Buyer Name : ",
            ViewRefundData['vendor_buyer_details']['bidder_name'] ?? 'N/A',
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
                  fontSize: 21, // Increase font size
                  fontWeight: FontWeight.bold, // Make it bold
                ),
              ),
            ),
            buildPaymentDetailsCard(ViewRefundData),

            // buildListTile(
            //     "Material Name : ${ViewRefundData['sale_order_details']?[0]['material_name']?? 'N/A'}"),
            // buildListTile(
            //     "Total Qty :${ViewRefundData['sale_order_details'][0]['totalqty'] ?? "N/A"} ${ViewRefundData['sale_order_details'][0]['totunit'] ?? ""}"),
            // if(ViewRefundData['lifted_quantity'] != null &&
            //     ViewRefundData['lifted_quantity'] is List &&
            //     ViewRefundData['lifted_quantity'].isNotEmpty)
            // buildListTile(
            //     "Lifted Qty :${ViewRefundData['lifted_quantity'][0]['quantity'] ?? "N/A"} ${ViewRefundData['sale_order_details'][0]['totunit'] ?? ""}"),
            // buildListTile(
            //     "Rate :${ViewRefundData['sale_order_details'][0]['rate'] ?? "N/A"}"),
            // buildListTile(
            //     "SO Date :${ViewRefundData['sale_order_details'][0]['sod'] ?? "N/A"}"),
            // buildListTile(
            //     "SO Validity :${ViewRefundData['sale_order_details'][0]['sovu'] ?? "N/A"}"),
            //
            Divider(),
            buildTable(),
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

  Widget buildPaymentDetailsCard(Map<String, dynamic> ViewRefundData) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDetailTile(
                "Material Name : ",
                ViewRefundData['sale_order_details']?[0]['material_name'] ?? 'N/A',
                Icons.category),
            buildDetailTile(
                "Total Qty : ",
                "${ViewRefundData['sale_order_details'][0]['qty'] ?? 'No data'} ${ViewRefundData['sale_order_details'][0]['totunit'] ?? ''}",
                Icons.inventory),
            buildDetailTile(
                "Balance Qty : ",
                "${ViewRefundData['sale_order_details'][0]['qty'] ?? 'No data'} ${ViewRefundData['sale_order_details'][0]['totunit'] ?? ''}",
                Icons.inventory),
            if (ViewRefundData['lifted_quantity'] != null &&
                ViewRefundData['lifted_quantity'] is List &&
                ViewRefundData['lifted_quantity'].isNotEmpty)
              buildDetailTile(
                  "Lifted Qty : ",
                  "${ViewRefundData['lifted_quantity'][0]['quantity'] ?? 'No data'} ${ViewRefundData['sale_order_details'][0]['totunit'] ?? ''}",
                  Icons.local_shipping),
            buildDetailTile(
                "Rate : ",
                ViewRefundData['sale_order_details'][0]['rate']?.toString() ?? 'No data',
                Icons.attach_money),
            buildDetailTile(
                "SO Date : ",
                formatDate(ViewRefundData['sale_order_details'][0]['sod']),
                Icons.date_range),

            buildDetailTile(
                "SO Validity : ",
                formatDate(ViewRefundData['sale_order_details'][0]['sovu']),
                Icons.event_available),
          ],
        ),
      ),
    );
  }


  Widget buildListTile(String text) {
    return ListTile(
      title: Text(text),
    );
  }

  Widget buildTable() {
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
            if (taxes.isNotEmpty)
              ...taxes.map((tax) {
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
                DataCell(Text('Final Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text('₹${taxAmount['finalTaxAmount']}', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentListView() {
    // Filter the list based on the allowed payment types
    final filteredPayments = refundStatus.where((payment) =>
    payment['payment_type'] == "Penalty" ||
        payment['payment_type'] == "Refund All" ||
        payment['payment_type'] == "Refund Amount").toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        // Heading at the top
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Payment Details",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        // If there are no matching items, display the "No Payment Details Found" message
        if (filteredPayments.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "No Payment Details Found",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18,color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true, // Prevents infinite scroll issue
            physics:
            NeverScrollableScrollPhysics(),
            itemCount: filteredPayments.length,
            itemBuilder: (context, index) {
              final payment = filteredPayments[index];
              return buildPaymentStatusListTile(context, payment);
            },
          ),
      ],
    );
  }


  Widget buildEmdListView() {
    // Filter the list to only include items with "Refund EMD"
    final filteredEmdStatus = emdStatus.where((status) => status['payment_type'] == "Refund EMD").toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // Heading at the top
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "EMD Details",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        // If there are no matching items, display the "No EMD Details Found" message
        if (filteredEmdStatus.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "No EMD Details Found",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18,color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true, // Prevents infinite scroll issue
            physics:
            NeverScrollableScrollPhysics(),
            itemCount: filteredEmdStatus.length,
            itemBuilder: (context, index) {
              final emdStatusIndex = filteredEmdStatus[index];
              return buildEmdStatusListTile(context, emdStatusIndex);
            },
          ),
      ],
    );
  }

  Widget buildCMDDetailListView() {
    final filteredCmdStatus = cmdStatus.where((status) => status['payment_type'] == "Refund CMD").toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // Heading at the top
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "CMD Details",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        // If there are no matching items, display the "No CMD Details Found" message
        if (filteredCmdStatus.isEmpty)

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "No CMD Details Found",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18,color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true, // Prevents infinite scroll issue
            physics:
            NeverScrollableScrollPhysics(),
            itemCount: filteredCmdStatus.length,
            itemBuilder: (context, index) {
              final cmdStatusIndex = filteredCmdStatus[index];
              return buildEmdStatusListTile(context, cmdStatusIndex);
            },
          ),
      ],
    );
  }


  Widget buildPaymentStatusListTile(BuildContext context, index) {
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
                  // RichText(
                  //   text: TextSpan(
                  //     children: [
                  //       TextSpan(
                  //         text: "Ref No : ",
                  //         style: TextStyle(
                  //           color: Colors.black87,
                  //           fontWeight: FontWeight.bold, // Bold key
                  //           fontSize: 16,
                  //         ),
                  //       ),
                  //       TextSpan(
                  //         text: "${index['pay_ref_no'] ?? 'N/A'}",
                  //         style: TextStyle(
                  //           color: Colors.black54,
                  //           fontWeight: FontWeight.normal, // Normal value
                  //           fontSize: 16,
                  //
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
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
                          text: "${index['date'] ?? 'N/A'}",
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
              // trailing: IconButton(
              //   icon: Icon(Icons.arrow_forward_ios, size: 16),
              //   color: Colors.grey[600],
              //   onPressed: () {
              //     print(index['nfa_no']);
              //     // Action on tapping the arrow
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => View_Refund_Amount(
              //           sale_order_id: widget.sale_order_id,
              //           bidder_id: widget.bidder_id,
              //           refundId: index['payment_id'],
              //           paymentType: index['payment_type'],
              //           date1: index['date'],
              //           amount: index['amt'],
              //           totalPayment: ViewRefundData['totalPayment'].toString(),
              //           totalEmd: ViewRefundData['total_emd'].toString(),
              //           totalAmountIncludingEmd:ViewRefundData['totalAvailablebalIncludingEmd'],
              //           note: index['narration'],
              //           referenceNo: index['pay_ref_no'],
              //           rvNo: index['receipt_voucher_no'],
              //           date2: index['receipt_voucher_date'],
              //           typeOfTransfer: index['typeoftransfer'],
              //           nfa: index['nfa_no'],
              //         ),
              //       ),
              //     ).then((value) => setState((){
              //       fetchRefundDetails();
              //     }));
              //   },
              // ),
              // onTap: () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => View_Refund_Amount(
              //         sale_order_id: widget.sale_order_id,
              //         bidder_id: widget.bidder_id,
              //         refundId: index['payment_id'],
              //         paymentType: index['payment_type'],
              //         date1: index['pay_date'],
              //         amount: index['amt'],
              //         totalPayment: ViewRefundData['totalPayment'].toString(),
              //         totalEmd: ViewRefundData['total_emd'].toString(),
              //         totalAmountIncludingEmd: ViewRefundData['totalAvailablebalIncludingEmd'],
              //         note: index['narration'],
              //         referenceNo: index['pay_ref_no'],
              //         rvNo: index['receipt_voucher_no'],
              //         date2: index['receipt_voucher_date'],
              //         typeOfTransfer: index['typeoftransfer'],
              //         nfa: index['nfa_no'],
              //       ),
              //     ),
              //   ).then((value) => setState((){
              //     fetchRefundDetails();
              //   }));
              // },
            ),
          ),
        ),
      );
  }

  Widget buildEmdStatusListTile(BuildContext context, index) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
                  // RichText(
                  //   text: TextSpan(
                  //     children: [
                  //       TextSpan(
                  //         text: "Ref No : ",
                  //         style: TextStyle(
                  //           color: Colors.black87,
                  //           fontWeight: FontWeight.bold, // Bold key
                  //           fontSize: 16,
                  //         ),
                  //       ),
                  //       TextSpan(
                  //         text: "${index['pay_ref_no'] ?? 'N/A'}",
                  //         style: TextStyle(
                  //           color: Colors.black54,
                  //           fontWeight: FontWeight.normal, // Normal value
                  //           fontSize: 16,
                  //
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
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
                          text: "${index['date'] ?? 'N/A'}",
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
              // trailing: IconButton(
              //   icon: Icon(Icons.arrow_forward_ios, size: 16),
              //   color: Colors.grey[600],
              //   onPressed: () {
              //     // Action on tapping the arrow
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => View_Refund_Amount(
              //           sale_order_id: widget.sale_order_id,
              //           bidder_id: widget.bidder_id,
              //           refundId: index['payment_id'],
              //           paymentType: index['payment_type'],
              //           date1: index['date'],
              //           amount: index['amt'],
              //           totalPayment: ViewRefundData['totalPayment'].toString(),
              //           totalEmd: ViewRefundData['total_emd'].toString(),
              //           totalAmountIncludingEmd:ViewRefundData['totalAvailablebalIncludingEmd'],
              //           note: index['narration'],
              //           referenceNo: index['pay_ref_no'],
              //           rvNo: index['receipt_voucher_no'],
              //           date2: index['receipt_voucher_date'],
              //           typeOfTransfer: index['typeoftransfer'],
              //           nfa: index['nfa_no'],
              //         ),
              //       ),
              //     ).then((value) => setState((){
              //       fetchRefundDetails();
              //     }));
              //   },
              // ),
              // onTap: () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => View_Refund_Amount(
              //         sale_order_id: widget.sale_order_id,
              //         bidder_id: widget.bidder_id,
              //         refundId: index['payment_id'],
              //         paymentType: index['payment_type'],
              //         date1: index['date'],
              //         amount: index['amt'],
              //         totalPayment: ViewRefundData['totalPayment'].toString(),
              //         totalEmd: ViewRefundData['total_emd'].toString(),
              //         totalAmountIncludingEmd:ViewRefundData['totalAvailablebalIncludingEmd'],
              //         note: index['narration'],
              //         referenceNo: index['pay_ref_no'],
              //         rvNo: index['receipt_voucher_no'],
              //         date2: index['receipt_voucher_date'],
              //         typeOfTransfer: index['typeoftransfer'],
              //         nfa: index['nfa_no'],
              //       ),
              //     ),
              //   ).then((value) => setState((){
              //     fetchRefundDetails();
              //   }));
              // },
            ),
          ),
        ),
      );
    }

  Widget buildCMDDetailListTile(BuildContext context , index) {
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
              child: Icon(Icons.account_balance_wallet_rounded, size: 24, color: Colors.white),
            ),
            title:  RichText(
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
                // RichText(
                //   text: TextSpan(
                //     children: [
                //       TextSpan(
                //         text: "Ref No : ",
                //         style: TextStyle(
                //           color: Colors.black87,
                //           fontWeight: FontWeight.bold, // Bold key
                //           fontSize: 16,
                //         ),
                //       ),
                //       TextSpan(
                //         text: "${index['pay_ref_no'] ?? 'N/A'}",
                //         style: TextStyle(
                //           color: Colors.black54,
                //           fontWeight: FontWeight.normal, // Normal value
                //           fontSize: 16,
                //
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
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
                        text: "${index['date'] ?? 'N/A'}",
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
            // trailing: IconButton(
            //   icon: Icon(Icons.arrow_forward_ios, size: 16),
            //   color: Colors.grey[600],
            //   onPressed: () {
            //     // Navigator.push(
            //     //   context,
            //     //   MaterialPageRoute(
            //     //     builder: (context) => View_Payment_Amount(),
            //     //   ),
            //     // );
            //   },
            // ),
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => View_Payment_Amount(),
              //   ),
              // );
            },
          ),
        ),
      ),
    );
  }
}

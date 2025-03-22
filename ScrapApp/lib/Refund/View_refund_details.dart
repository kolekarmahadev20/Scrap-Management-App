import 'dart:convert';
import 'package:flutter/material.dart';
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.indigo[800],
          unselectedItemColor: Colors.black54,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.category),
            //   label: "Material Details",
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.payment),
              label: "Payment Details",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance),
              label: "EMD Details",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.security),
              label: "CMD Details",
            ),
          ],
        ),

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

  Widget buildScrollableTabContent(BuildContext context, Widget Function() listViewBuilder) {
    return SizedBox(
      height: MediaQuery.of(context).size.height, // Set the height of the container
      child: listViewBuilder(),
    );
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
                        fontSize: 22,
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

  Widget buildVendorInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildVendorInfoText(
            "Vendor Name: ", ViewRefundData['vendor_buyer_details']['vendor_name'] ?? 'N/A' ,false),
        buildVendorInfoText(
            "Branch: ", ViewRefundData['vendor_buyer_details']['branch_name'] ?? 'N/A',false),
        buildVendorInfoText(
            "Buyer Name: ", ViewRefundData['vendor_buyer_details']['bidder_name'] ?? 'N/A',false),
      ],
    );
  }

  Widget buildVendorInfoText(String key, String value , bool isRed) {
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
                ?TextSpan(
              text: value, // Value text (e.g., "XYZ Corp")
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent, // Normal value text
              ),
            )
                :TextSpan(
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
                  fontSize: 22, // Increase font size
                  fontWeight: FontWeight.bold, // Make it bold
                ),
              ),
            ),
            buildListTile(
                "Material Name : ${ViewRefundData['sale_order_details']?[0]['material_name']?? 'N/A'}"),
            buildListTile(
                "Total Qty :${ViewRefundData['sale_order_details'][0]['totalqty'] ?? "N/A"} ${ViewRefundData['sale_order_details'][0]['totunit'] ?? ""}"),
            if(ViewRefundData['lifted_quantity'] != null &&
                ViewRefundData['lifted_quantity'] is List &&
                ViewRefundData['lifted_quantity'].isNotEmpty)
            buildListTile(
                "Lifted Qty :${ViewRefundData['lifted_quantity'][0]['quantity'] ?? "N/A"} ${ViewRefundData['sale_order_details'][0]['totunit'] ?? ""}"),
            buildListTile(
                "Rate :${ViewRefundData['sale_order_details'][0]['rate'] ?? "N/A"}"),
            buildListTile(
                "SO Date :${ViewRefundData['sale_order_details'][0]['sod'] ?? "N/A"}"),
            buildListTile(
                "SO Validity :${ViewRefundData['sale_order_details'][0]['sovu'] ?? "N/A"}"),
            buildTable(),
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
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey), // Add a border around the table
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: DataTable(
          columnSpacing: 16.0,
          border: TableBorder.all(color: Colors.grey), // Add borders to table cells
          columns: [
            DataColumn(
              label: Text(
                'Tax',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Amount',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: [

            // Add a TOTAL row at the end
            DataRow(cells: [
              DataCell(Text('Basic Amount', /*style: TextStyle(fontWeight: FontWeight.bold)*/)),
              DataCell(Text('₹${taxAmount['basicTaxAmount']}' , /*style: TextStyle(fontWeight: FontWeight.bold)*/)),
            ]),
            // Dynamically add rows based on the 'taxes' list
            if (taxes.isNotEmpty)
              ...taxes.map((tax) {
                return DataRow(cells: [
                  DataCell(Text(tax['tax_name'] ?? 'No data')),
                  DataCell(Text('${tax['tax_amount'] ?? 'No data'}')),
                ]);
              }).toList(),
            DataRow(cells: [
              DataCell(Text('Final Amount', /*style: TextStyle(fontWeight: FontWeight.bold)*/)),
              DataCell(Text('₹${taxAmount['finalTaxAmount']}' , /*style: TextStyle(fontWeight: FontWeight.bold)*/)),
            ]),


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
      children: [
        // Heading at the top
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Payment Details",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),

        // If there are no matching items, display the "No Payment Details Found" message
        if (filteredPayments.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "No Payment Details Found",
                style: TextStyle( fontSize: 18),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: filteredPayments.length,
              itemBuilder: (context, index) {
                final payment = filteredPayments[index];
                return buildPaymentStatusListTile(context, payment);
              },
            ),
          ),
      ],
    );
  }


  Widget buildEmdListView() {
    // Filter the list to only include items with "Refund EMD"
    final filteredEmdStatus = emdStatus.where((status) => status['payment_type'] == "Refund EMD").toList();

    return Column(
      children: [
        // Heading at the top
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "EMD Details",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),

        // If there are no matching items, display the "No EMD Details Found" message
        if (filteredEmdStatus.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "No EMD Details Found",
                style: TextStyle( fontSize: 18),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: filteredEmdStatus.length,
              itemBuilder: (context, index) {
                final emdStatusIndex = filteredEmdStatus[index];
                return buildEmdStatusListTile(context, emdStatusIndex);
              },
            ),
          ),
      ],
    );
  }

  Widget buildCMDDetailListView() {
    final filteredCmdStatus = cmdStatus.where((status) => status['payment_type'] == "Refund CMD").toList();

    return Column(
      children: [
        // Heading at the top
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "CMD Details",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),

        // If there are no matching items, display the "No CMD Details Found" message
        if (filteredCmdStatus.isEmpty)

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "No CMD Details Found",
                style: TextStyle( fontSize: 18),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: filteredCmdStatus.length,
              itemBuilder: (context, index) {
                final cmdStatusIndex = filteredCmdStatus[index];
                return buildEmdStatusListTile(context, cmdStatusIndex);
              },
            ),
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

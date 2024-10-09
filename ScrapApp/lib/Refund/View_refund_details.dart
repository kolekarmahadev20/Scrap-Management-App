import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Refund/Add_refund_details.dart';
import 'package:scrapapp/Refund/View_Refund_Amount.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../URL_CONSTANT.dart';
import 'addRefundToSaleOrder.dart';

class View_refund_details extends StatefulWidget {
  final String? sale_order_id;
  View_refund_details({
    required this.sale_order_id,
  });

  @override
  State<View_refund_details> createState() => _View_refund_detailsState();
}

class _View_refund_detailsState extends State<View_refund_details> {
  String? username = '';
  String? password = '';
  bool isLoading = false;
  Map<String, dynamic> ViewRefundData = {};
  List<dynamic> refundId = [];
  List<dynamic> emdStatus = [];
  bool? isData;


  @override
  void initState() {
    super.initState();
    checkLogin();
    fetchRefundDetails();
  }

  checkLogin() async {
    final login = await SharedPreferences.getInstance();
    username = await login.getString("username") ?? '';
    password = await login.getString("password") ?? '';
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
          'user_pass': password,
          'sale_order_id': widget.sale_order_id,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          var jsonData = json.decode(response.body);
          ViewRefundData = jsonData;
          refundId = ViewRefundData['sale_order_payments'] ?? '';
          emdStatus = ViewRefundData['emd_status'] ?? '';
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
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        buildExpansionTile(),
                        buildScrollableContainer(
                            "Payment Status", buildPaymentListView),
                        buildScrollableContainer("EMD Status", buildEmdListView),
                      ],
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

  Widget buildRowWithIcon(BuildContext context) {
    return Material(
      elevation: 2,
      color: Colors.white,
      shape: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black12)
      ),
      child: Container(
        child: Row(
          children: [
            Spacer(),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Order ID :  ", // Key text (e.g., "Vendor Name: ")
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Bold key text
                    ),
                  ),
                  TextSpan(
                    text:ViewRefundData['sale_order']['sale_order_code'], // Value text (e.g., "XYZ Corp")
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      color: Colors.black54, // Normal value text
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            IconButton(
              icon: Icon(
                Icons.add_box_outlined,
                size: 30,
                color: Colors.indigo[800],
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => addRefundToSaleOrder(sale_order_id: widget.sale_order_id! , sale_order_code: ViewRefundData['sale_order']['sale_order_code']),
                  ),
                ).then((value) => setState((){
                  fetchRefundDetails();
                }));
              },
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
            "Vendor Name: ", ViewRefundData['vendor_buyer_details']['vendor_name'] ?? 'N/A'),
        buildVendorInfoText(
            "Branch: ", ViewRefundData['vendor_buyer_details']['branch_name'] ?? 'N/A'),
        buildVendorInfoText(
            "Buyer Name: ", ViewRefundData['vendor_buyer_details']['bidder_name'] ?? 'N/A'),
      ],
    );
  }

  Widget buildVendorInfoText(String key, String value) {
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
            TextSpan(
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
      child: ExpansionTile(
        title: Text(
          "Material Detail",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: Icon(
          Icons.menu,
          color: Colors.indigo[800],
        ),
        trailing: Icon(
          Icons.arrow_drop_down_sharp,
          color: Colors.indigo[800],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildListTile(
                    "Material Name : ${ViewRefundData['sale_order_details'][0]['material_name']}"),
                buildListTile(
                    "Total Qty :${ViewRefundData['sale_order_details'][0]['totalqty']}"),
                if(ViewRefundData['lifted_quantity'] != null &&
                    ViewRefundData['lifted_quantity'] is List &&
                    ViewRefundData['lifted_quantity'].isNotEmpty)
                buildListTile(
                    "Lifted Qty :${ViewRefundData['lifted_quantity'][0]['quantity']}"),
                buildListTile(
                    "Rate :${ViewRefundData['sale_order_details'][0]['rate']}"),
                buildListTile(
                    "SO Date :${ViewRefundData['sale_order_details'][0]['sod']}"),
                buildListTile(
                    "SO Validity :${ViewRefundData['sale_order_details'][0]['sovu']}"),
                buildTable(),
              ],
            ),
          ),
        ],
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
          border:
              Border.all(color: Colors.grey), // Add a border around the table
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: DataTable(
          columnSpacing: 16.0,
          border:
              TableBorder.all(color: Colors.grey), // Add borders to table cells
          columns: [
            DataColumn(
                label: Text(
              'Tax',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )),
            DataColumn(
                label: Text(
              'Amount',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )),
          ],
          rows: [
            DataRow(cells: [
              DataCell(Text('')),
              DataCell(Text('')),
            ]),
            DataRow(cells: [
              DataCell(Text('')),
              DataCell(Text('')),
            ]),
            DataRow(cells: [
              DataCell(Text('')),
              DataCell(Text('')),
            ]),
            DataRow(cells: [
              DataCell(Text('')),
              DataCell(Text('')),
            ]),
            DataRow(cells: [
              DataCell(Text('TOTAL')),
              DataCell(Text('')),
            ]),
          ],
        ),
      ),
    );
  }

  Widget buildScrollableContainer(
      String title, Widget Function() listViewBuilder) {
    return Container(
      width:double.infinity,
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(8.0),
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
            height: 300, // Adjusted to fit typical content
            child: listViewBuilder(),
          ),
        ],
      ),
    );
  }

  Widget buildEmdListView() {
    print("length : ${emdStatus}");
    if(emdStatus.length != 0){
      return ListView.builder(
        itemCount: emdStatus.length,
        itemBuilder: (context, index) {
          final emdStatusIndex = emdStatus[index];
          return buildEmdStatusListTile(context,emdStatusIndex);
        },
      );
    }else{
      return Center(child: Text("No EMD Details Found" ,style: TextStyle(fontWeight:FontWeight.bold , fontSize: 20),));
    }
  }

  Widget buildPaymentListView() {
    if(refundId.length != 0){
      return ListView.builder(
        itemCount:refundId.length,
        itemBuilder: (context, index) {
          final paymentIdIndex =refundId[index];
          return buildPaymentStatusListTile(context,paymentIdIndex);
        },
      );
    }else{
      return Center(child: Text("No Payment Details Found" ,style: TextStyle(fontWeight:FontWeight.bold , fontSize: 20),));
    }
  }


  Widget buildPaymentStatusListTile(BuildContext context, index) {
    // Check the payment_type condition
    if (index['payment_type'] == "Refund EMD" ||
        index['payment_type'] == "Refund CMD" ||
        index['payment_type'] == "Penalty" ||
        index['payment_type'] == "Refund All" ||
        index['payment_type'] == "Refund(Other than EMD/CMD)") {
      isData = true;
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
                        text: "${index['pay_date'] ?? 'N/A'}",
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
                    builder: (context) => View_Refund_Amount(
                      sale_order_id: widget.sale_order_id,
                      refundId: index['payment_id'],
                      paymentType: index['payment_type'],
                      date1: index['pay_date'],
                      amount: index['amt'],
                      totalPayment: ViewRefundData['totalPayment'].toString(),
                      totalEmd: ViewRefundData['total_emd'].toString(),
                      totalAmountIncludingEmd:
                          ViewRefundData['totalAvailablebalIncludingEmd'],
                      note: index['narration'],
                      referenceNo: index['pay_ref_no'],
                      rvNo: index['receipt_voucher_no'],
                      date2: index['receipt_voucher_date'],
                      typeOfTransfer: index['typeoftransfer'],
                      nfa: index['nfa_no'],
                    ),
                  ),
                ).then((value) => setState((){
                  fetchRefundDetails();
                }));
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => View_Refund_Amount(
                    sale_order_id: widget.sale_order_id,
                    refundId: index['payment_id'],
                    paymentType: index['payment_type'],
                    date1: index['pay_date'],
                    amount: index['amt'],
                    totalPayment: ViewRefundData['totalPayment'].toString(),
                    totalEmd: ViewRefundData['total_emd'].toString(),
                    totalAmountIncludingEmd:
                        ViewRefundData['totalAvailablebalIncludingEmd'],
                    note: index['narration'],
                    referenceNo: index['pay_ref_no'],
                    rvNo: index['receipt_voucher_no'],
                    date2: index['receipt_voucher_date'],
                    typeOfTransfer: index['typeoftransfer'],
                    nfa: index['nfa_no'],
                  ),
                ),
              ).then((value) => setState((){
                fetchRefundDetails();
              }));
            },
          ),
        ),
      );
    } else {
      isData = false;
      return Container(); // Return an empty container if the condition is not met
    }
  }

  Widget buildEmdStatusListTile(BuildContext context, index) {
    if (index['payment_type'] == "Refund EMD") {
      isData = true;
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
            trailing: IconButton(
              icon: Icon(Icons.arrow_forward_ios, size: 16),
              color: Colors.grey[600],
              onPressed: () {
                // Action on tapping the arrow
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => View_Refund_Amount(
                      sale_order_id: widget.sale_order_id,
                      refundId: index['payment_id'],
                      paymentType: index['payment_type'],
                      date1: index['date'],
                      amount: index['amt'],
                      totalPayment: ViewRefundData['totalPayment'].toString(),
                      totalEmd: ViewRefundData['total_emd'].toString(),
                      totalAmountIncludingEmd:
                          ViewRefundData['totalAvailablebalIncludingEmd'],
                      note: index['narration'],
                      referenceNo: index['pay_ref_no'],
                      rvNo: index['receipt_voucher_no'],
                      date2: index['receipt_voucher_date'],
                      typeOfTransfer: index['typeoftransfer'],
                      nfa: index['nfa_no'],
                    ),
                  ),
                ).then((value) => setState((){
                  fetchRefundDetails();
                }));
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => View_Refund_Amount(
                    sale_order_id: widget.sale_order_id,
                    refundId: index['payment_id'],
                    paymentType: index['payment_type'],
                    date1: index['date'],
                    amount: index['amt'],
                    totalPayment: ViewRefundData['totalPayment'].toString(),
                    totalEmd: ViewRefundData['total_emd'].toString(),
                    totalAmountIncludingEmd:
                        ViewRefundData['totalAvailablebalIncludingEmd'],
                    note: index['narration'],
                    referenceNo: index['pay_ref_no'],
                    rvNo: index['receipt_voucher_no'],
                    date2: index['receipt_voucher_date'],
                    typeOfTransfer: index['typeoftransfer'],
                    nfa: index['nfa_no'],
                  ),
                ),
              ).then((value) => setState((){
                fetchRefundDetails();
              }));
            },
          ),
        ),
      );
    } else {
      isData = false;
      return Container();
    }
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Payment/Add_payment_detail.dart';
import 'package:scrapapp/Payment/View_Payment_Amount.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../URL_CONSTANT.dart';
import 'addPaymentToSaleOrder.dart';

class View_payment_detail extends StatefulWidget {
  final String sale_order_id;
  View_payment_detail({
    required this.sale_order_id,
  });


  @override
  State<View_payment_detail> createState() => _View_payment_detailState();
}

class _View_payment_detailState extends State<View_payment_detail> {

  String? username = '';

  String? password = '';

  bool isLoading = false;

  Map<String , dynamic> ViewPaymentData = {};
  List<dynamic> paymentId =[];
  List<dynamic> emdStatus =[];
  List<dynamic> taxes =[];


  var checkLiftedQty ;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
    fetchPaymentDetails();
  }

  checkLogin()async{
    final login = await SharedPreferences.getInstance();
    username = await login.getString("username") ?? '';
    password = await login.getString("password") ?? '';
  }

  Future<void> fetchPaymentDetails() async {
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
        'sale_order_id':widget.sale_order_id,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        var jsonData = json.decode(response.body);
        ViewPaymentData = jsonData;
        paymentId = ViewPaymentData['sale_order_payments'] ?? '';
        emdStatus =  ViewPaymentData['emd_status'] ?? '';
        checkLiftedQty = ViewPaymentData['lifted_quantity'];
        taxes = ViewPaymentData['tax_and_rate'][0]['taxes'];
        print(taxes);
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

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isLoading,
      child: Scaffold(
        drawer: AppDrawer(),
        appBar: CustomAppBar(),
        body:
        Stack(
          children:[
            isLoading ?
            showLoading()
            :Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        buildExpansionTile(),
                        buildScrollableContainer("Payment Details", buildPaymentDetailListView),
                        buildScrollableContainer("EMD Details", buildEmdDetailListView),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ])
      ),
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
                    text:ViewPaymentData['sale_order']['sale_order_code'] ?? "N/A", // Value text (e.g., "XYZ Corp")
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
                    builder: (context) => addPaymentToSaleOrder(sale_order_id: widget.sale_order_id,sale_order_code: ViewPaymentData['sale_order']['sale_order_code'] ?? "N/A",)
                  ),
                ).then((value) => setState((){
                  fetchPaymentDetails();
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
            "Vendor Name : ", ViewPaymentData['vendor_buyer_details']['vendor_name'] ?? 'N/A'),
        buildVendorInfoText(
            "Branch : ", ViewPaymentData['vendor_buyer_details']['branch_name'] ?? 'N/A'),
        buildVendorInfoText(
            "Buyer Name : ", ViewPaymentData['vendor_buyer_details']['bidder_name'] ?? 'N/A'),
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
                buildListTile("Material Name :${ViewPaymentData['sale_order_details'][0]['material_name'] ?? 'No data'}"),
                buildListTile("Total Qty :${ViewPaymentData['sale_order_details'][0]['totalqty'] ?? 'No data'}"),
                if(ViewPaymentData['lifted_quantity'] != null &&
                    ViewPaymentData['lifted_quantity'] is List &&
                    ViewPaymentData['lifted_quantity'].isNotEmpty)
                buildListTile("Lifted Qty :${ViewPaymentData['lifted_quantity'][0]['quantity'] ?? 'No data'}"),
                buildListTile("Rate :${ViewPaymentData['sale_order_details'][0]['rate'] ?? 'No data'}"),
                buildListTile("SO Date :${ViewPaymentData['sale_order_details'][0]['sod'] ?? 'No data'}"),
                buildListTile("SO Validity :${ViewPaymentData['sale_order_details'][0]['sovu'] ?? 'No data'}"),
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
    int total_tax_amount = 0;
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
            // Dynamically add rows based on the 'taxes' list
            if (taxes != null && taxes.isNotEmpty)
              ...taxes.map((tax) {
                var total_taxes = int.tryParse(tax['tax_amount'].toString());
                print(total_taxes);
                total_tax_amount = total_tax_amount + total_taxes!;
                return DataRow(cells: [
                  DataCell(Text(tax['tax_name'] ?? 'No data')),
                  DataCell(Text('${tax['tax_amount'] ?? 'No data'}')),
                ]);
              }).toList(),
            // Add a TOTAL row at the end
            DataRow(cells: [
              DataCell(Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text('₹$total_tax_amount' , style: TextStyle(fontWeight: FontWeight.bold))),
            ]),
          ],
        ),
      ),
    );
  }

  Widget buildScrollableContainer(String title, Widget Function() listViewBuilder) {
    return Container(
      width:double.infinity,
      margin: EdgeInsets.all(8.0), // Match margin from second page
      padding: EdgeInsets.all(8.0), // Match padding from second page
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
            height: 300,
            child:
            listViewBuilder(),
          ),
        ],
      ),
    );
  }
  Widget buildPaymentDetailListView() {
    if(paymentId.length != 0){
    return ListView.builder(
      itemCount:paymentId.length,
      itemBuilder: (context, index) {
        final paymentIdIndex =paymentId[index];
        return buildPaymentDetailListTile(context,paymentIdIndex);
      },
    );
    }else{
      return Center(child: Text("No Payment Details Found" ,style: TextStyle(fontWeight:FontWeight.bold , fontSize: 20),));
    }
  }

  Widget buildEmdDetailListView() {
    if(emdStatus.length != 0){
    return ListView.builder(
      itemCount: emdStatus.length,
      itemBuilder: (context, index) {
        final emdStatusIndex = emdStatus[index];
        return buildEmdDetailListTile(context,emdStatusIndex);
      },
    );
    }else{
      return Center(child: Text("No EMD Details Found" ,style: TextStyle(fontWeight:FontWeight.bold , fontSize: 20),));
    }
  }

  Widget buildPaymentDetailListTile(BuildContext context , index) {
    if (index['payment_type'] == "Received EMD"
        || index['payment_type'] == "Received CMD"
        || index['payment_type'] == "Received Payment") {
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
                    builder: (context) =>
                        View_Payment_Amount(
                          sale_order_id: widget.sale_order_id,
                          paymentId: index['payment_id'] ?? 'N/A',
                          paymentType: index['payment_type']?? 'N/A',
                          date1: index['pay_date']?? 'N/A',
                          amount: index['amt']?? 'N/A',
                          referenceNo: index['pay_ref_no']?? 'N/A',
                          typeOfTransfer: index['typeoftransfer']?? 'N/A',
                        ),
                  ),
                ).then((value) => setState((){
                  fetchPaymentDetails();
                }));
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      View_Payment_Amount(
                        sale_order_id: widget.sale_order_id,
                        paymentId: index['payment_id'] ?? 'N/A',
                        paymentType: index['payment_type']?? 'N/A',
                        date1: index['pay_date']?? 'N/A',
                        amount: index['amt']?? 'N/A',
                        referenceNo: index['pay_ref_no']?? 'N/A',
                        typeOfTransfer: index['typeoftransfer']?? 'N/A',
                      ),
                ),
              ).then((value) => setState((){
                fetchPaymentDetails();
              }));
            },
          ),
        ),
      );
    }else{
      return Container();
    }
  }

  Widget buildEmdDetailListTile(BuildContext context , index) {
    if (index['payment_type'] == "Received EMD") {
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
              child: Icon(Icons.account_balance_wallet_rounded, size: 24,
                  color: Colors.white),
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
                    builder: (context) =>
                        View_Payment_Amount(
                          sale_order_id: widget.sale_order_id,
                          paymentId: index['payment_id'] ?? "N/A",
                          paymentType: index['payment_type'] ?? "N/A",
                          date1: index['date'] ?? "N/A",
                          amount: index['amt'] ?? "N/A",
                          referenceNo: index['pay_ref_no'] ?? "N/A",
                          typeOfTransfer: index['typeoftransfer'] ?? "N/A",
                        ),
                  ),
                ).then((value) => setState((){
                  fetchPaymentDetails();
                }));
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      View_Payment_Amount(
                        sale_order_id: widget.sale_order_id,
                        paymentId: index['payment_id'] ?? "N/A",
                        paymentType: index['payment_type'] ?? "N/A",
                        date1: index['date'] ?? "N/A",
                        amount: index['amt'] ?? "N/A",
                        referenceNo: index['pay_ref_no'] ?? "N/A",
                        typeOfTransfer: index['typeoftransfer'] ?? "N/A",
                      ),
                ),
              ).then((value) => setState((){
                fetchPaymentDetails();
              }));
            },
          ),
        ),
      );
    }else{
      return Container();
    }
  }
}

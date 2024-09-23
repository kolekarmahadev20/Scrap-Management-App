import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Payment/Add_payment_detail.dart';
import 'package:scrapapp/Payment/View_Payment_Amount.dart';
import 'package:http/http.dart' as http;
import '../URL_CONSTANT.dart';

class View_payment_detail extends StatefulWidget {
  final String sale_order_id;
  View_payment_detail({
    required this.sale_order_id,
  });


  @override
  State<View_payment_detail> createState() => _View_payment_detailState();
}

class _View_payment_detailState extends State<View_payment_detail> {



  Map<String , dynamic> ViewPaymentData = {};

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.sale_order_id);
    fetchPaymentList();
  }




  Future<void> fetchPaymentList() async {
  try {
    final url = Uri.parse("${URL}payment_details");
    var response = await http.post(
      url,
      headers: {"Accept": "application/json"},
      body: {
        'user_id': 'Bantu',
        'user_pass': 'Bantu#123',
        'sale_order_id':widget.sale_order_id,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        var jsonData = json.decode(response.body);
        ViewPaymentData = jsonData;
        print(ViewPaymentData);
        // print(ViewPaymentData['sale_order_id']);
      });
    } else {
      print("Unable to fetch data.");
      setState(() {
      });
    }
  } catch (e) {
    print("Server Exception: $e");
    setState(() {
    });
  }
}







@override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: CustomAppBar(),
      body: Container(
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
            Divider(
              thickness: 1.5,
              color: Colors.black54,
            ),
            buildRowWithIcon(context),
            Divider(
              thickness: 1.5,
              color: Colors.black54,
            ),
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
    );
  }

  Widget buildRowWithIcon(BuildContext context) {
    return Row(
      children: [
        Spacer(),
        Text(
          "Order ID",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
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
                builder: (context) => Add_payment_detail(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildVendorInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildVendorInfoText("Vendor Name : ${ViewPaymentData['vendor_buyer_details']['vendor_name']}"),
        buildVendorInfoText("Branch :${ViewPaymentData['vendor_buyer_details']['branch_name']}"),
        buildVendorInfoText("Buyer Name :${ViewPaymentData['vendor_buyer_details']['bidder_name']}"),
      ],
    );
  }

  Widget buildVendorInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildExpansionTile() {
    return Material(
      elevation: 5,
      child: ExpansionTile(
        title: Text(
          "Material Detail",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                buildListTile("Material Name :${ViewPaymentData['material_lifting_details']['1']['material_name']}"),
                buildListTile("Total Qty :${ViewPaymentData['material_lifting_details']['1']['qty']}"),
                buildListTile("Lifted Qty :${ViewPaymentData['material_lifting_details']['1']['material_name']}"),
                buildListTile("Rate :${ViewPaymentData['material_lifting_details']['1']['rate']}"),
                buildListTile("SO Date :${ViewPaymentData['material_lifting_details']['1']['date_time']}"),
                buildListTile("SO Validity :${ViewPaymentData['material_lifting_details']['1']['material_name']}"),
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
          border: Border.all(color: Colors.grey), // Add a border around the table
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: DataTable(
          columnSpacing: 16.0,
          border: TableBorder.all(color: Colors.grey), // Add borders to table cells
          columns: [
            DataColumn(label: Text('Tax' ,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)),
            DataColumn(label: Text('Amount',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)),
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

  Widget buildScrollableContainer(String title, Widget Function() listViewBuilder) {
    return Container(
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
            child: listViewBuilder(),
          ),
        ],
      ),
    );
  }

  Widget buildPaymentDetailListView() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return buildPaymentDetailListTile(context);
      },
    );
  }

  Widget buildEmdDetailListView() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return buildEmdDetailListTile(context);
      },
    );
  }

  Widget buildPaymentDetailListTile(BuildContext context) {
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
          title: Text(
            "Amount",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ref No :", style: TextStyle(color: Colors.black54)),
              Text("Date : ", style: TextStyle(fontSize: 14, color: Colors.black54)),
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
                  builder: (context) => View_Payment_Amount(),
                ),
              );
            },
          ),
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => View_Payment_Amount(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildEmdDetailListTile(BuildContext context) {
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
            child: Icon(Icons.account_balance_wallet_rounded, size: 24, color: Colors.white),
          ),
          title: Text(
            "Amount",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ref No :", style: TextStyle(color: Colors.black54)),
              Text("Date : ", style: TextStyle(fontSize: 14, color: Colors.black54)),
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
                  builder: (context) => View_Payment_Amount(),
                ),
              );
            },
          ),
          onTap: (){
            Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => View_Payment_Amount(),
            ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Dispatch/Add_dispatch_details.dart';
import 'package:scrapapp/Dispatch/View_dispatch_lifting_details.dart';

class View_dispatch_details extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: CustomAppBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // Match previous padding
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
              padding: const EdgeInsets.all(8.0), // Match padding from previous code
              child: buildVendorInfo(),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildScrollableContainerWithListView("Lifting Details", buildInvoiceListView),
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
                builder: (context) => Add_dispatch_details(),
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
        buildVendorInfoText("Vendor Name :"),
        buildVendorInfoText("Branch :"),
        buildVendorInfoText("Buyer Name :"),
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

  Widget buildScrollableContainerWithListView(String title, Widget Function() listViewBuilder) {
    return Container(
      height: 500,
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
            height: 400, // Match height from previous code
            child: listViewBuilder(),
          ),
        ],
      ),
    );
  }

  Widget buildInvoiceListView() {
    return ListView.builder(
      itemCount: 10, // Example number of items
      itemBuilder: (context, index) {
        return buildInvoiceListTile(context);
      },
    );
  }

  Widget buildInvoiceListTile(BuildContext context) {
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
            child: Icon(Icons.receipt_long, size: 24, color: Colors.white), // Adjust icon size
          ),
          title: Text(
            "Invoice No",
            style: TextStyle(
              fontSize: 16, // Adjust font size to match
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Material : ",
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              Text(
                "Date : ",
                style: TextStyle(
                  fontSize: 14, // Match subtitle font size
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.arrow_forward_ios, size: 16),
            color: Colors.grey[600],
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => View_dispatch_lifting_details()));
            },
          ),
        ),
      ),
    );
  }
}

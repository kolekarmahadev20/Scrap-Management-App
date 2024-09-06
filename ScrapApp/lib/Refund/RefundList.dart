import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Payment/Add_payment_detail.dart';
import 'package:scrapapp/Refund/Add_refund_details.dart';
import 'package:scrapapp/Refund/View_refund_details.dart';

class RefundList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: CustomAppBar(),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.grey[200], // Slightly lighter background color
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0), // Increased padding for the header
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Refund",
                    style: TextStyle(
                      fontSize: 26, // Slightly larger font size for prominence
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 1.2,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.filter_list_alt,
                      color: Colors.white,
                      size: 20, // Consistent icon size
                    ),
                    label: Text("Filter"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.indigo[800], // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                      ),
                      elevation: 5,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Consistent padding
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 1.5,
              color: Colors.black54,
            ),
            Row(
              children: [
                Spacer(),
                Text(
                  "Vendor, Plant",
                  style: TextStyle(
                    fontSize: 18, // Slightly larger font size
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.add_box_outlined,
                    size: 28, // Slightly smaller but prominent icon
                    color: Colors.indigo[800],
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Add_refund_details()));
                  },
                ),
              ],
            ),
            Divider(
              thickness: 1.5,
              color: Colors.black54,
            ),
            SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListView.builder(
                  itemCount: 10, // Number of items in the list
                  itemBuilder: (context, index) {
                    return buildCustomListTile(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCustomListTile(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2, // Slightly higher elevation for a more pronounced shadow
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0), // Reduced margins for compact design
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Slightly rounded corners
        side: BorderSide(color: Colors.grey[300]!, width: 1), // Subtle border for better visuals
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Reduced padding inside the card
        leading: CircleAvatar(
          backgroundColor: Colors.indigo[800],
          child: Icon(Icons.border_outer, size: 22, color: Colors.white), // Reduced icon size for compactness
        ),
        title: Text(
          "Order Id",
          style: TextStyle(
            fontSize: 16, // Consistent title font size
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Buyer",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14, // Slightly smaller font size for subtitle
              ),
            ),
            Text(
              "Material : ",
              style: TextStyle(
                fontSize: 14, // Consistent subtitle font size
                color: Colors.black54,
              ),
            ),
            Text(
              "Date : ",
              style: TextStyle(
                fontSize: 14, // Consistent subtitle font size
                color: Colors.black54,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.arrow_forward_ios, size: 18), // Adjusted trailing icon size
          color: Colors.grey[600],
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => View_refund_details()),
            );
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => View_refund_details()),
          );
        },
      ),
    );
  }
}

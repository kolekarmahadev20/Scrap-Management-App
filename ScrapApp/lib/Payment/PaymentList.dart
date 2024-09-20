import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Payment/Add_payment_detail.dart';
import 'package:scrapapp/Payment/View_payment_detail.dart';
import 'package:http/http.dart' as http;
import '../URL_CONSTANT.dart';

class PaymentList extends StatefulWidget {
  @override
  State<PaymentList> createState() => _PaymentListState();
}

class _PaymentListState extends State<PaymentList> {


  List<dynamic> dates = [];
  List<dynamic> orderIds = [];
  List<dynamic> buyerNames = [];
  List<dynamic> data = [];
  List<dynamic> material = [];
  bool isLoading = true; // Add a loading flag

  @override
  void initState() {
    super.initState();
    fetchPaymentList();
  }

  Future<void> fetchPaymentList() async {
    try {
      final url = Uri.parse("${URL}fetch_payment_data");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': 'Bantu',
          'user_pass': 'Bantu#123',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          var jsonData = json.decode(response.body);
          data = jsonData['aaData'];

          // Extract the relevant data
          for (var entry in data) {
            dates.add(entry[0]); // Date
            orderIds.add(entry[1]); // Order ID
            buyerNames.add(entry[5]); // Buyer Name
            material.add(entry[6]);
          }
          print(dates);
          print(orderIds);
          print(buyerNames);
          print(material);

          isLoading = false; // Set loading to false when data is loaded
        });
      } else {
        print("Unable to fetch data.");
        setState(() {
          isLoading = false; // Set loading to false in case of error
        });
      }
    } catch (e) {
      print("Server Exception: $e");
      setState(() {
        isLoading = false; // Set loading to false in case of exception
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: CustomAppBar(),
      body:
      isLoading
      ?Center(child: CircularProgressIndicator()) // Show loading spinner while fetching data
      :Container(
        height: double.infinity,
        width: double.infinity,
         // Increased padding around the body
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
                    "Payment",
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Add_payment_detail()));
                  },
                ),
              ],
            ),
            Divider(
              thickness: 1.5,
              color: Colors.black54,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListView.builder(
                  itemCount: data.length, // Number of items in the list
                  itemBuilder: (context, index) {
                    return buildCustomListTile(context,index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCustomListTile(BuildContext context , index) {
    return Card(
      color: Colors.white,
      elevation: 2, // Slightly higher elevation for a more pronounced shadow
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0), // Reduced margins
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // More rounded corners
        side: BorderSide(color: Colors.indigo[800]!, width: 1.5), // Accent border
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Reduced padding
        leading: CircleAvatar(
          backgroundColor: Colors.indigo[800]!,
          child: Icon(Icons.border_outer, size: 22, color: Colors.white), // Reduced icon size
        ),
        title: Center(
          child: Text(
            "#${orderIds[index]}",
            style: TextStyle(
              fontSize: 16, // Consistent font size for the title
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider( thickness: 1,color: Colors.black87),
            Text(
              "Buyer: ${buyerNames[index]}",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14, // Slightly smaller font size for subtitle

              ),
            ),
            Text(
              "Material :${material[index]}",
              style: TextStyle(
                fontSize: 14, // Consistent font size
                color: Colors.black54,
              ),
            ),
            Text(
              "Date : ${dates[index]}",
              style: TextStyle(
                fontSize: 14, // Consistent font size
                color: Colors.black54,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.arrow_forward_ios, size: 18), // Adjusted icon size
          color: Colors.grey[600],
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => View_payment_detail()),
            );
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => View_payment_detail()),
          );
        },
      ),
    );
  }
}

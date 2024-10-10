import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Payment/Add_payment_detail.dart';
import 'package:scrapapp/Payment/View_payment_detail.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../URL_CONSTANT.dart';

class PaymentList extends StatefulWidget {
  @override
  State<PaymentList> createState() => _PaymentListState();
}

class _PaymentListState extends State<PaymentList> {

  TextEditingController searchController = TextEditingController(); // Controller for search input

  String? username = '';

  String? password = '';

  List<Map<String, dynamic>> paymentList = [];
  List<dynamic> filteredPaymentList = []; // For filtered search results


  bool isLoading = false; // Add a loading flag

  @override
  void initState() {
    super.initState();
    checkLogin();
    fetchPaymentList();
  }

  checkLogin()async{
    final login = await SharedPreferences.getInstance();
    username = await login.getString("username") ?? '';
    password = await login.getString("password") ?? '';
  }

  Future<void> fetchPaymentList() async {
    try {
      setState(() {
        isLoading = true;
      });
      await checkLogin();
      final url = Uri.parse("${URL}fetch_payment_data");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'user_pass': password,
          'sale_order':searchController.text,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          var jsonData = json.decode(response.body);
          // Extract the relevant data
          paymentList = List<Map<String, dynamic>>.from(jsonData['saleOrder_paymentList']);
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



  showFilterDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.blueGrey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Search Sale Orders",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.black54),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
                SizedBox(height: 10),
                TextField(
                  controller: searchController,
                  onChanged: (value) {},
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: "Enter Order ID",
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color:Colors.indigo)// No border for cleaner look
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                ),
                SizedBox(height: 20),
               Row(
                 children: [
                 Expanded(
                   child: Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: ElevatedButton(
                       onPressed: () {
                         setState(() {
                           searchController.clear();
                           fetchPaymentList();
                         });
                         Navigator.pop(context); // Close dialog
                       },
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.red[400], // Primary color
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(15),
                         ),
                         padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                         elevation: 5,
                       ),
                       child: Text(
                         "Reset",
                         style: TextStyle(fontSize: 18, color: Colors.white),
                       ),
                     ),
                   ),
                 ),
                 Expanded(
                     child: Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: ElevatedButton(
                         onPressed: () {
                           setState(() {
                             fetchPaymentList();
                           });
                           Navigator.pop(context); // Close dialog
                         },
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.green[400], // Primary color
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(15),
                           ),
                           padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                           elevation: 5,
                         ),
                         child: Text(
                           "Apply",
                           style: TextStyle(fontSize: 18, color: Colors.white),
                         ),
                       ),
                     ),
                   ),
               ],)
              ],
            ),
          ),
        );
      },
    );
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
        isLoading
        ?showLoading()
        :Container(
          height: double.infinity,
          width: double.infinity,
           // Increased padding around the body
          color: Colors.grey[200], // Slightly lighter background color
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Payment",
                      style: TextStyle(
                        fontSize: 26, // Slightly larger font size for prominence
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          showFilterDialog();
                        });
                      },
                      icon: Icon(
                        Icons.filter_list_alt,
                        color: Colors.white,
                        size: 20, // Consistent icon size
                      ),
                      label: Text("Filter"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueGrey[400], // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                        ),
                        elevation: 5,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Consistent padding
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  elevation: 2,
                  color: Colors.white,
                  shape: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueGrey[400]!)
                  ),
                  child: Container(
                    width:double.infinity,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                Add_payment_detail())).then((value) => setState((){
                                  fetchPaymentList();
                            }));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height:20),
              Expanded(
                child:
                (paymentList.length !=0)
                ?ListView.separated(
                  itemCount: paymentList.length, // Number of items in the list
                  itemBuilder: (context, index) {
                    final paymentIndex = paymentList[index];
                    if(paymentList.length !=0) {
                      return buildCustomListTile(context, paymentIndex);
                    }else{
                      return Text("No data");
                    }
                  },
                  separatorBuilder: (context, index) => Divider(
                    color: Color(0xFF6482AD), // Custom color for the separator
                    thickness: 1, // Thickness of the divider
                    indent: 12, // Indentation before the divider
                    endIndent: 12, // Indentation after the divider
                  ),
                )
                :Center(child: Text("No data", style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCustomListTile(BuildContext context , index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        elevation: 2,
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5)
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Reduced padding
          leading: CircleAvatar(
            backgroundColor: Colors.indigo[800]!,
            child: Icon(Icons.border_outer, size: 22, color: Colors.white), // Reduced icon size
          ),
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Order ID :  ", // Key text (e.g., "Vendor Name: ")
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Bold key text
                  ),
                ),
                TextSpan(
                  text:index['sale_order_code'] ?? "N/A", // Value text (e.g., "XYZ Corp")
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.indigo[800]!, // Normal value text
                  ),
                ),
              ],
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider( thickness: 1,color: Colors.black87),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Buyer : ",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold, // Bold key
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text: "${index['bidder_name'] ?? 'N/A'}",
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.normal, // Normal value
                        fontSize: 18,

                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Material : ",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold, // Bold key
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text: "${index['description'] ?? 'N/A'}",
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.normal, // Normal value
                        fontSize: 18,

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
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text: "${index['date'] ?? 'N/A'}",
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.normal, // Normal value
                        fontSize: 18,
                      ),
                    ),
                  ],
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
                MaterialPageRoute(builder: (context) => View_payment_detail(
                  sale_order_id: index['sale_order_id'],
                )),
              ).then((value) => setState((){
                fetchPaymentList();
              }));
            },
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => View_payment_detail(
                sale_order_id: index['sale_order_id'],
              )),
            ).then((value) => setState((){
              fetchPaymentList();
            }));
          },
        ),
      ),
    );
  }
}

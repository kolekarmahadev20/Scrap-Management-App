import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Payment/Edit_payment_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


import '../URL_CONSTANT.dart';

class View_Payment_Amount extends StatefulWidget {
  final String? sale_order_id;
  final String? paymentId;
  final String? paymentType;
  final String? date1;
  final String? amount;
  final String? referenceNo;
  final String? typeOfTransfer;
  View_Payment_Amount({
    required this.sale_order_id,
    required this.paymentId,
    required this.paymentType,
    required this.date1,
    required this.amount,
    required this.referenceNo,
    required this.typeOfTransfer,

  });

  @override
  State<View_Payment_Amount> createState() => _View_Payment_AmountState();
}

class _View_Payment_AmountState extends State<View_Payment_Amount> {

  String? username = '';

  String? password = '';
  String? loginType = '';
  String? userType = '';

  String totalPayment='';
   String totalEmd='';
   String totalCmd='';
   String totalEmdCmd='';
   String paymentType='';

   String date1='';

   String amount='';

   String referenceNo='';

   String typeOfTransfer='';

   @override
  void initState() {
    super.initState();
    checkLogin();
    fetchPaymentDetails();
    paymentType = widget.paymentType ?? '';
    date1 = widget.date1 ?? '';
    amount = widget.amount ?? '';
    referenceNo = widget.referenceNo ?? '';
    typeOfTransfer = widget.typeOfTransfer ?? '';
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
  }

  Future<void> fetchPaymentDetails() async {
    try {
      await checkLogin();
      final url = Uri.parse("${URL}EMD_CMD_details");
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
        final jsonData = json.decode(response.body);
        setState(() {
          totalPayment= jsonData['t_amt'].toString() ;
          totalEmd= jsonData['total_EMD'].toString();
          totalCmd= jsonData['total_CMD'].toString();
          totalEmdCmd = jsonData['total_amount_included_emdCmd'].toString();
        });
      } else {
        Fluttertoast.showToast(
            msg: 'Unable to load data.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.yellow
        );
      }
    } catch (e) {
      print('$e');
      Fluttertoast.showToast(
          msg: 'Server Exception : $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.yellow
      );
    }
    finally{
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: CustomAppBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        color: Colors.grey[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Payment",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 1.5,
                ),
              ),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Spacer(),
                      Spacer(),
                      Center(
                        child: Text(
                          "VIEW PAYMENT DETAILS",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          size: 30,
                          color: Colors.indigo[800],
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Edit_payment_detail(
                                  sale_order_id: widget.sale_order_id,
                                  paymentId:widget.paymentId,
                                  paymentType: paymentType,
                                  date1: date1,
                                  amount: amount,
                                  referenceNo: referenceNo,
                                  typeOfTransfer: typeOfTransfer,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  buildDisplay("Total Payment", totalPayment),
                  buildDisplay("Total EMD", totalEmd),
                  buildDisplay("Total CMD", totalCmd),
                  buildDisplay("Total Amount Including EMD/CMD", totalEmdCmd),
                  buildDisplay("Payment Type", paymentType),
                  buildDisplay("Date", date1),
                  buildDisplay("Amount", amount),
                  buildDisplay("Ref/RV No.", referenceNo),
                  buildDisplay("Type Of Transfer", typeOfTransfer),
                  buildDisplay("Remark", ''),
                  SizedBox(height: 40,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Back"),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.indigo[800],
                              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDisplay(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0 , horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[400]!,
                  width: 1.5,
                ),
                color: Colors.white,
              ),
              child: Text(
                value,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

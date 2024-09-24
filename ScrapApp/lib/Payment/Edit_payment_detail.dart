import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../URL_CONSTANT.dart';

class Edit_payment_detail extends StatefulWidget {
  final String? sale_order_id;
  final String? paymentId;
  final String? paymentType;
  final String? date1;
  final String? amount;
  final String? referenceNo;
  final String? typeOfTransfer;

  Edit_payment_detail({
    required this.sale_order_id,
    required this.paymentId,
    required this.paymentType,
    required this.date1,
    required this.amount,
    required this.referenceNo,
    required this.typeOfTransfer,
  });

  @override
  _Edit_payment_detailState createState() => _Edit_payment_detailState();
}

class _Edit_payment_detailState extends State<Edit_payment_detail> {
  final TextEditingController dateController1 = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController refNoController = TextEditingController();
  final TextEditingController typeTransController = TextEditingController();


  String? username = '';

  String? password = '';



  String? selectedPaymentType;


  Map<String , String> PaymentType = {
    'Select' : 'Select',
    'Received Payment':'P',
    'Received EMD':'E',
    'Received CMD':'C',
  };


  void clearFields(){
    selectedPaymentType = null;
    dateController1.clear();
    amountController.clear();
    refNoController.clear();
    typeTransController.clear();
  }

  @override
  initState(){
    super.initState();
    checkLogin();
    if (PaymentType.containsKey(widget.paymentType)) {
      selectedPaymentType =PaymentType['${widget.paymentType}'];
      print(selectedPaymentType);
    } else {
      selectedPaymentType = 'Select';
      print(selectedPaymentType);
    }
    dateController1.text = widget.date1!;
    amountController.text = widget.amount!;
    refNoController.text = widget.referenceNo!;
    typeTransController.text = widget.typeOfTransfer!;
  }

  checkLogin()async{
    final login = await SharedPreferences.getInstance();
    username = await login.getString("username") ?? '';
    password = await login.getString("password") ?? '';
  }

  Future<void> editPaymentDetails() async {
    try {
      await checkLogin();
      final url = Uri.parse("${URL}add_payment_toSaleOrder");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'user_pass': password,
          'sale_order_id_pay':widget.sale_order_id,
          'pay_id':widget.paymentId,
          'payment_type': selectedPaymentType ?? '',
          'pay_date': dateController1.text ?? '',
          'amt':amountController.text ?? '',
          'pay_ref_no':refNoController.text ?? '',
          'typeoftransfer':typeTransController.text ?? '',
        },
      );
      print('hello');
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${jsonData['msg']}")));
        });
      } else {
        Fluttertoast.showToast(
            msg: 'Unable to insert data.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.yellow
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Server Exception : $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.yellow
      );
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
            Divider(
              thickness: 1.5,
              color: Colors.black54,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Edit",
                  style: TextStyle(
                    fontSize: 16, // Keep previous font size
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Divider(
              thickness: 1.5,
              color: Colors.black54,
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  buildDropdownPayment("Payment Type", PaymentType, (value) {
                    setState(() {
                      selectedPaymentType = value;
                    });
                  }),
                  buildTextField("Date", dateController1),
                  buildTextField("Amount", amountController),
                  buildTextField("Reference No.", refNoController),
                  buildTextField("Type Of Transfer", typeTransController),
                  SizedBox(height: 40,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            clearFields();
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
                        ElevatedButton(
                          onPressed: () {
                            editPaymentDetails();
                            // clearFields();
                          },
                          child: Text("Save"),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.indigo[800],
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDropdownPayment(String label, Map<String , String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0 , horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3, // Adjusts label width
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 7, // Adjusts dropdown width
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: selectedPaymentType,
              items: options.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.value, // Key is used as value for Dropdown
                  child: Text(entry.key), // Value is displayed as text
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }


  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0 ,horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3, // Adjusts label width
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 7, // Adjusts text field width
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.indigo[800]!,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey[400]!,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:http/http.dart' as http;
import '../URL_CONSTANT.dart';

class Add_payment_detail extends StatefulWidget {
  @override
  _Add_payment_detailState createState() => _Add_payment_detailState();
}

class _Add_payment_detailState extends State<Add_payment_detail> {
  final TextEditingController dateController1 = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController refNoController = TextEditingController();
  final TextEditingController typeTransController = TextEditingController();

  String? selectedOrderId;
  String? selectedPaymentType;
  List<String> orderIDs = ['Select',];

  void clearFields(){
    selectedOrderId = null;
    selectedPaymentType = null;
    dateController1.clear();
    amountController.clear();
    refNoController.clear();
    typeTransController.clear();
  }

  @override
  void initState(){
    super.initState();
    orderIdDropDowns();
  }


  Future<void> addPaymentDetails() async {
    try {
      final url = Uri.parse("${URL}add_payment_toSaleOrder");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': 'Bantu',
          'user_pass': 'Bantu#123',
          'sale_order_id_pay':selectedOrderId ?? '',
          'payment_type': selectedPaymentType ?? '',
          'pay_date': dateController1.text,
          'amt':amountController.text,
          'pay_ref_no':refNoController.text,
          'typeoftransfer':typeTransController.text,
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

  //fetching dropDowns of sale_order_list
  Future<void> orderIdDropDowns() async {
    try {
      final url = Uri.parse("${URL}saleOrder_list");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id':'Bantu',
          'user_pass':'Bantu#123',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          for(var entry in jsonData){
            if (entry['id'] != null) {
              orderIDs.add(entry['id']);
            }else{
              orderIDs.add("N/A");
            }
          }
        });
      } else {
       print("unable to load order ids.");
      }
    } catch (e) {
      print("Server Exception : $e");

    }
  }


  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (BuildContext context , StateSetter SetState) {
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
                    "Add",
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
                    buildDropdown("Order ID", orderIDs, (value) {
                      setState(() {
                        selectedOrderId = value;
                      });
                    }),
                    buildDropdown("Payment Type", [
                      "Select",
                      "Received Payment",
                      "Received EMD",
                      "Received CMD"
                    ], (value) {
                      setState(() {
                        selectedPaymentType = value;
                      });
                    }),
                    buildTextField("Date", dateController1, false),
                    buildTextField("Amount", amountController, false),
                    buildTextField("Reference No.", refNoController, false),
                    buildTextField("Type Of Transfer", typeTransController, false),
                    SizedBox(height: 180),
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              addPaymentDetails();
                              // clearFields();
                            },
                            child: Text("Add"),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.indigo[800],
                              padding: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
    });
  }

  Widget buildDropdown(String label, List<String> options, ValueChanged<String?> onChanged) {
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
              value: options.isNotEmpty ? options.first : null,
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }


  Widget buildTextField(String label, TextEditingController controller , bool isReadOnly) {
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
                readOnly: isReadOnly,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

  import 'dart:convert';

  import 'package:flutter/material.dart';
  import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
  import 'package:scrapapp/AppClass/AppDrawer.dart';
  import 'package:scrapapp/AppClass/appBar.dart';
  import 'package:http/http.dart' as http;
  import '../URL_CONSTANT.dart';

  class Add_refund_details extends StatefulWidget {
    @override
    _Add_refund_detailsState createState() => _Add_refund_detailsState();
  }

  class _Add_refund_detailsState extends State<Add_refund_details> {
    final TextEditingController orderIdController = TextEditingController();
    final TextEditingController dateController1 = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController totalPaymentController = TextEditingController();
    final TextEditingController totalEmdController = TextEditingController();
    final TextEditingController totalAmountController = TextEditingController();
    final TextEditingController noteController = TextEditingController();
    final TextEditingController refNoController = TextEditingController();
    final TextEditingController rvNoController = TextEditingController();
    final TextEditingController dateController2 = TextEditingController();
    final TextEditingController typeTransController = TextEditingController();
    final TextEditingController nfaController = TextEditingController();


    String? selectedOrderId;
    String? selectedPaymentType;
    List<String> orderIDs = ['Select',];
    List<String> materialId = [];
    String? totalAmount;


    void clearFields(){
      selectedOrderId = null;
      selectedPaymentType = null;
      dateController1.clear();
      amountController.clear();
      totalPaymentController.clear();
      totalEmdController.clear();
      totalAmountController.clear();
      noteController.clear();
      refNoController.clear();
      rvNoController.clear();
      dateController2.clear();
      typeTransController.clear();
    }


    @override
    void initState(){
      super.initState();
      orderIdDropDowns();
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

    Future<void> fetchTotalAmount() async {
      try {
        final url = Uri.parse("${URL}add_refund_payment");
        var response = await http.post(
          url,
          headers: {"Accept": "application/json"},
          body: {
            'user_id':'Bantu',
            'user_pass':'Bantu#123',
            'sale_order_id':selectedOrderId ?? '',
          },
        );
        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          setState(() {
            totalAmountController.text = jsonData['t_amt'].toString();
          });
        } else {
          print("unable to load order ids.");
        }
      } catch (e) {
        print("Server Exception : $e");

      }
    }

    Future<void> addRefundDetails() async {
      try {
        final url = Uri.parse("${URL}add_refund_toSaleOrdder");
        var response = await http.post(
          url,
          headers: {"Accept": "application/json"},
          body: {
            'user_id':'Bantu',
            'user_pass':'Bantu#123',
            'sale_order_id_pay': selectedOrderId ?? '',
            'payment_type':selectedPaymentType ?? '',
            'pay_date':dateController1.text,
            'amt':amountController.text,
            't_amt':totalAmountController.text,
            'total_emd':totalEmdController.text,
            'narration':noteController.text,
            'pay_ref_no':refNoController.text,
            'receipt_voucher_no':rvNoController.text,
            'receipt_voucher_date':dateController2.text,
            'nfa_no':nfaController.text,
          },
        );
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
                  "Refund",
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
                    buildDropdown("Order ID",orderIDs, (value) {
                      setState(() {
                        selectedOrderId = value;
                        fetchTotalAmount();
                      });
                    }),
                    buildDropdown("Payment Type", ["Select","Refund(Other than EMD/CMD)", "Refund EMD", "Refund CMD","Penalty","Refund All"], (value) {
                      setState(() {
                        selectedPaymentType = value;
                      });
                    }),

                    if (selectedPaymentType == "Refund(Other than EMD/CMD)") ...[
                      buildTextField("Date", dateController1, false),
                      buildTextField("Amount", amountController, false),
                      buildTextField("Total Payment", totalPaymentController, false),
                      buildTextField("NFA No.", nfaController, false),
                      buildTextField("Date", dateController2, false),
                    ] else if (selectedPaymentType == "Refund EMD" || selectedPaymentType =="Refund CMD") ...[
                      buildTextField("Date", dateController1, false),
                      buildTextField("Amount", amountController, false),
                      buildTextField("Total EMD", totalEmdController, false),
                      buildTextField("Total Amount Including EMD",totalAmountController, false),
                      buildTextField("NFA No.", nfaController, false),
                      buildTextField("Date", dateController2, false),
                    ]else if (selectedPaymentType == "Penalty") ...[
                      buildTextField("Date", dateController1, false),
                      buildTextField("Amount", amountController, false),
                      buildTextField("Total EMD", totalEmdController, false),
                      buildTextField("Total Amount Including EMD",totalAmountController, false),
                      buildTextField("Date", dateController2, false),
                    ]
                    else ...[
                      buildTextField("Date", dateController1, false),
                      buildTextField("Amount", amountController, false),
                      buildTextField("Total Payment", totalPaymentController, false),
                      buildTextField("Total EMD", totalEmdController, false),
                      buildTextField("Total Amount Including EMD",totalAmountController, false),
                      buildTextField("Note", noteController, false),
                      buildTextField("Reference No.", refNoController, false),
                      buildTextField("RV No.", rvNoController, false),
                      buildTextField("Date", dateController2, false),
                      buildTextField("Type Of Transfer", typeTransController, false),
                    ],
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
                              addRefundDetails();
                              // clearFields();
                            },
                            child: Text("Add"),
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
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
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

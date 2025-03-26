import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../URL_CONSTANT.dart';

class addRefundToSaleOrder extends StatefulWidget {

  final String sale_order_id;
  final String material_name;
  final String branch_id_from_ids;
  final String vendor_id_from_ids;

  addRefundToSaleOrder({
    required this.sale_order_id,
    required this.material_name,
    required this.branch_id_from_ids,
    required this.vendor_id_from_ids,
  });

  @override
  addRefundToSaleOrderState createState() => addRefundToSaleOrderState();
}

class addRefundToSaleOrderState extends State<addRefundToSaleOrder> {
  final TextEditingController materialController = TextEditingController();
  final TextEditingController dateController1 = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController totalPaymentController = TextEditingController();
  final TextEditingController totalEmdController = TextEditingController();
  final TextEditingController totalCmdController = TextEditingController();
  final TextEditingController totalEmdCmdController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController refNoController = TextEditingController();
  final TextEditingController nfaController = TextEditingController();

  String? username = '';
 String uuid = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';
  String? selectedOrderId;
  String? selectedPaymentType;
  bool isLoading = false; // Add a loading flag
  String rate = '';
  String totalAmount = '';

  List<String> orderIDs = [
    'Select',
  ];
  List<String> materialId = [];
  Map<String, String> refundMap = {
    "Select": "Select",
    "Refund Amount": "R",
    "Refund EMD": "RE",
    "Refund CMD": "Rc",
    "Penalty": "PE",
    "Refund All": "RA"
  };

  @override
  void initState() {
    super.initState();
    checkLogin().then((_) {
      setState(() {});
    });
    materialController.text = widget.material_name;
    fetchRefundPaymentDetails();
  }


  void clearFields() {
    selectedOrderId = null;
    selectedPaymentType = null;
    dateController1.clear();
    amountController.clear();
    totalPaymentController.clear();
    totalEmdController.clear();
    totalEmdCmdController.clear();
    noteController.clear();
    refNoController.clear();
  }



  Future<void> checkLogin() async {
     final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    uuid = prefs.getString("uuid")!;
    uuid = prefs.getString("uuid")!;
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
  }


  Future<void> fetchRefundPaymentDetails() async {
    try {
      await checkLogin();
      final url = Uri.parse("${URL}EMD_CMD_details");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid':uuid,
          'user_pass': password,
          'sale_order_id':widget.sale_order_id,
          'branch_id':widget.branch_id_from_ids,
          'vendor_id':widget.vendor_id_from_ids
        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          totalPaymentController.text = jsonData['Advance_payment'].toString()?? 'N/A';
          totalEmdController.text = jsonData['total_EMD'].toString() ?? 'N/A';
          totalCmdController.text = jsonData['total_CMD'].toString()  ?? 'N/A';
          totalEmdCmdController.text = jsonData['total_amount_included_emdCmd'].toString() ?? 'N/A';
          totalAmount = jsonData['totalAmount'].toString() ?? 'N/A';
          totalAmountController.text = jsonData['totalAmount'].toString() ?? 'N/A';
          rate = jsonData['rate'].toString();
        });
      } else {
        print("unable to load order ids.");
      }
    } catch (e) {
      print("Server Exception : $e");
    }
  }

  Future<void> addRefundDetails() async {
    /*print("User ID : $username");
    print("password : $password");
    print("sale_order_id : ${widget.sale_order_id}");
    print("selectedPaymentType: $selectedPaymentType");
    print("Date : ${dateController1.text}");
    print("Amount : ${amountController.text}");
    print("Total Emd : ${totalEmdController.text}");
    print("Total emd cmd : ${totalEmdCmdController.text}");
    print("Remark : ${noteController.text}");
    print("Ref No : ${refNoController.text}");
    print("Nfa No : ${nfaController.text}");*/
    try {
      setState(() {
        isLoading = true;
      });
      final url = Uri.parse("${URL}add_refund_toSaleOrdder");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid':uuid,
          'user_pass': password,
          'sale_order_id_pay': widget.sale_order_id ?? '',
          'payment_type': selectedPaymentType ?? '',
          'receipt_voucher_date': dateController1.text,
          'pay_date': dateController1.text,
          'amt': amountController.text,
          if(selectedPaymentType == "RA")
            'E': (totalCmdController.text.isNotEmpty) ? totalEmdController.text : '',
          if(selectedPaymentType == "RA")
            'C':(totalCmdController.text.isNotEmpty) ? totalCmdController.text : '',
          't_amt': totalPaymentController.text,
          'total_emd': totalEmdController.text,
          'total_amount_including_emd': totalEmdCmdController.text,
          'narration': noteController.text,
          'receipt_voucher_no':refNoController.text ,
          'nfa_no': nfaController.text,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print("jsonData:$jsonData");
        setState(() {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("${jsonData['msg']}")));
          Navigator.pop(context);
        });
      } else {
        Fluttertoast.showToast(
            msg: 'Unable to insert data.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.yellow);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Server Exception : $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.yellow);
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
      absorbing:isLoading,
      child: Scaffold(
        drawer: AppDrawer(currentPage: 6),
        appBar: CustomAppBar(),
        body: Stack(
            children: [
              isLoading
                  ?showLoading()
                  :Container(
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        elevation: 2,
                        color: Colors.white,
                        shape: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueGrey[400]!)
                        ),
                        child: Container(
                          child: Column(
                            children: [
                              SizedBox(height: 8,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "ADD REFUND DETAILS",
                                    style: TextStyle(
                                      fontSize: 16, // Keep previous font size
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8,),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: [
                          buildTextField("Total Payment", totalPaymentController, true,false ,Colors.grey[400]!, context),
                          buildTextField("Total EMD", totalEmdController, true,false , Colors.grey[400]!,context),
                          buildTextField("Total CMD", totalCmdController, true,false , Colors.grey[400]!,context),
                          buildTextField("Total EMD And CMD", totalEmdCmdController, true,false ,Colors.grey[400]!, context),
                          buildTextField("Total Amount", totalAmountController,true, false,Colors.grey[400]!, context),
                          Divider(),
                          buildTextField("Material Name", materialController, true, false , Colors.grey[400]!,context),
                          buildDropdownPayment("Payment Type", refundMap, (value) {
                            setState(() {
                              selectedPaymentType = value;
                              amountController.clear();
                              if(selectedPaymentType == "RA"){
                                amountController.text = totalAmount;
                              }else if(selectedPaymentType == "Rc"){
                                amountController.text = totalCmdController.text;
                              }else if(selectedPaymentType == "RE"){
                                amountController.text = totalEmdController.text;
                              }else if(selectedPaymentType == "R"){
                                amountController.text = totalPaymentController.text;
                              }
                            });
                          }),
                          if (selectedPaymentType == "R") ...[
                            buildTextField("Amount", amountController, false ,false , Colors.white,context),
                            buildTextField("NFA No.", nfaController, false,false ,Colors.white, context),
                            buildTextField("Date", dateController1, false,true ,Colors.white, context),
                          ] else if (selectedPaymentType == "RE" || selectedPaymentType == "Rc") ...[
                            buildTextField("Amount", amountController, false,false ,Colors.white, context),
                            buildTextField("NFA No.", nfaController, false,false ,Colors.white, context),
                            buildTextField("Date", dateController1, false,true , Colors.white,context),
                          ] else if (selectedPaymentType == "P") ...[
                            buildTextField("Amount", amountController, false,false ,Colors.white, context),
                            buildTextField("Date", dateController1, false,true ,Colors.white, context),
                          ]  else if (selectedPaymentType == "RA") ...[
                            buildTextField("Amount", amountController, false,false ,Colors.white, context),
                            buildTextField("NFA No.", nfaController, false,false ,Colors.white, context),
                            buildTextField("Date", dateController1, false,true ,Colors.white, context),
                          ]else ...[
                            buildTextField("Amount", amountController, false,false ,Colors.white, context),
                            buildTextField("NFA No.", refNoController, false,false , Colors.white,context),
                            buildTextField("Date", dateController1, false,true , Colors.white,context),
                            buildTextField("Remark", noteController, false,false , Colors.white,context),

                          ],
                          SizedBox(
                            height: 40,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // ElevatedButton(
                                //   onPressed: () {
                                //     clearFields();
                                //     Navigator.of(context).pop();
                                //   },
                                //   child: Text("Back"),
                                //   style: ElevatedButton.styleFrom(
                                //     foregroundColor: Colors.white,
                                //     backgroundColor: Colors.indigo[800],
                                //     padding: EdgeInsets.symmetric(
                                //         horizontal: 50, vertical: 12),
                                //     shape: RoundedRectangleBorder(
                                //       borderRadius: BorderRadius.circular(12),
                                //     ),
                                //   ),
                                // ),
                                ElevatedButton(
                                  onPressed: () {
                                    validateAndAddRefundDetails();
                                  },
                                  child: Text("Refund"),
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
            ]),
      ),
    );
  }

  void validateAndAddRefundDetails() {
    // Map selectedPaymentType to the corresponding total amount controller
    double? enteramt = double.tryParse(amountController.text.toString());

    print("Type of enteramt: ${enteramt.runtimeType}");

    final paymentTypeMap = {
      "RA": int.tryParse(totalAmount),
      "Rc": totalCmdController.text,
      "RE": totalEmdController.text,
      "R": totalPaymentController.text,
    };

    // Get the total amount based on the selected payment type
    // Retrieve the value from the map without casting
    // Ensure we have a String representation of totalAmountValue
    final dynamic totalAmountValue = paymentTypeMap[selectedPaymentType];
    print("totalAmountValue:$totalAmountValue");

    String totalAmountStr;

    if (totalAmountValue is int) {
      totalAmountStr = totalAmountValue.toString();
      print("Converted int to String: $totalAmountStr");
    } else if (totalAmountValue is String) {
      totalAmountStr = totalAmountValue;
      print("Value is already a String: $totalAmountStr");
    } else {
      totalAmountStr = '';
      print("Unexpected type or null: $totalAmountValue");
    }

// Now use totalAmountStr safely throughout your code
    print("Final Total Amount String: $totalAmountStr");


    if (totalAmountStr == null) {
      Fluttertoast.showToast(
        msg: "Invalid payment type selected.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }if(enteramt == null || enteramt <= 0){
      Fluttertoast.showToast(
        msg: "Invalid Amount",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    // print("totalAmountStr:$totalAmountStr");

    int enteredAmount = int.tryParse(amountController.text) ?? 0;
    double totalAmt = double.tryParse(totalAmountStr) ?? 0.0;

    // print("totalAmountStr:$totalAmountStr");
    // print("enteredAmount:$enteredAmount");
    // print("totalAmt:$totalAmt");

    if (enteredAmount > totalAmt) {

      Fluttertoast.showToast(
        msg: "Amount: $enteredAmount should not be greater than available amount: $totalAmt",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      addRefundDetails();
    }
  }


  Widget buildDropdown(
      String label, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
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
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

  Widget buildDropdownPayment(String label, Map<String, String> optionsMap,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
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
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: selectedPaymentType ??
                  optionsMap.values.first, // Use the map's value
              items: optionsMap.entries.map((option) {
                return DropdownMenuItem<String>(
                  value:
                  option.value, // Ensure the value here is the map's value
                  child: Text(option.key), // Display the key as the label
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
      controller.text = formattedDate;
    }
  }


  Widget buildTextField(
      String label, TextEditingController controller, bool isReadOnly ,bool isDateField, Color color,context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
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
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: color,
                ),
                child: TextField(
                  onTap: isDateField ? () => _selectDate(context, controller) : null,
                  controller: controller,
                  decoration: InputDecoration(
                    suffixIcon: isDateField
                        ? IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context, controller),
                    )
                        :null,
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
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  readOnly: isReadOnly,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

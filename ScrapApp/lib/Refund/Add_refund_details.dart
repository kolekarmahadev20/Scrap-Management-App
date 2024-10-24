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
  final TextEditingController totalAmountEmdController =
      TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController refNoController = TextEditingController();
  final TextEditingController rvNoController = TextEditingController();
  final TextEditingController dateController2 = TextEditingController();
  final TextEditingController nfaController = TextEditingController();

  String? username = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';
  String? selectedOrderId;
  String? selectedPaymentType;
  bool isLoading = false; // Add a loading flag
  List<String> materialId = [];
  String? totalAmount;
  Map<String, String> refundMap = {
    "Select": "Select",
    "Refund(Other than EMD/CMD)": "R",
    "Refund EMD": "RE",
    "Refund CMD": "Rc",
    "Penalty": "P",
    "Refund All": "RA"
  };
  Map<String,String> dropDownMap= {
    'Select' : 'Select',
  };

  void clearFields() {
    selectedOrderId = null;
    selectedPaymentType = null;
    dateController1.clear();
    amountController.clear();
    totalPaymentController.clear();
    totalEmdController.clear();
    totalAmountEmdController.clear();
    noteController.clear();
    refNoController.clear();
    rvNoController.clear();
    dateController2.clear();
  }

  @override
  void initState() {
    super.initState();
    checkLogin().then((_) {
      setState(() {});
    });
    fetchDropDwonKeyValuePair();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
  }

  Future<void> fetchDropDwonKeyValuePair() async {
    try {
      setState(() {
        isLoading = true;
      });
      await checkLogin();
      final url = Uri.parse("${URL}fetch_refund_data");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'user_pass': password,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          var jsonData = json.decode(response.body);
          // Extract the relevant data
          List<Map<String, dynamic>> keyValuePair = List<Map<String, dynamic>>.from(jsonData['saleOrder_refundList']);
          for (var keyValue in keyValuePair) {
            // Example key-value pairs of sale_order_code and vendor_name
            var saleOrderCode = keyValue['sale_order_code'] ?? "N/A";
            var saleOrderId = keyValue['sale_order_id']?? "N/A";

            // You can store these key-value pairs in a map if needed
            dropDownMap[saleOrderCode] = saleOrderId;
          }
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

  Future<void> fetchRefundPaymentDetails() async {
    try {
      print("Hello");
      print("Hello");
      print("Hello");
      print("Hello");
      await checkLogin();
      final url = Uri.parse("${URL}Addrefunddata");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'user_pass': password,
          'sale_order_id': selectedOrderId ?? '',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          totalPaymentController.text = jsonData['totalPayment'].toString();
          totalEmdController.text = jsonData['total_emd'].toString();
          totalAmountEmdController.text =
              jsonData['totalAvailablebalIncludingEmd'].toString();
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
      setState(() {
        isLoading = true;
      });
      final url = Uri.parse("${URL}add_refund_toSaleOrdder");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'user_pass': password,
          'sale_order_id_pay': selectedOrderId ?? '',
          'payment_type': selectedPaymentType ?? '',
          'pay_date': dateController1.text,
          'amt': amountController.text,
          't_amt': totalPaymentController.text,
          'total_emd': totalEmdController.text,
          'total_amount_including_emd': totalAmountEmdController.text,
          'narration': noteController.text,
          'pay_ref_no': refNoController.text,
          'receipt_voucher_no': rvNoController.text,
          'receipt_voucher_date': dateController2.text,
          'nfa_no': nfaController.text,
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        // print('test');
        final jsonData = json.decode(response.body);
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
        drawer: AppDrawer(),
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
                      buildDropdown("Order ID", dropDownMap, (value) {
                        setState(() {
                          selectedOrderId = value;
                          print(value);
                          if (selectedOrderId == dropDownMap.keys.first) {
                            totalPaymentController.clear();
                            totalEmdController.clear();
                            totalAmountEmdController.clear();
                          }
                          fetchRefundPaymentDetails();
                        });
                      }),
                      buildDropdownPayment("Payment Type", refundMap, (value) {
                        setState(() {
                          selectedPaymentType = value;
                          print(value);
                        });
                      }),
                      if (selectedPaymentType == "R") ...[
                        buildTextField("Date", dateController1, false, true , context),
                        buildTextField("Amount", amountController, false ,false , context),
                        buildTextField(
                            "Total Payment", totalPaymentController, true, false , context),
                        buildTextField("NFA No.", nfaController, false,false , context),
                        buildTextField("RV Date", dateController2, false,true , context),
                      ] else if (selectedPaymentType == "RE" ||
                          selectedPaymentType == "Rc") ...[
                        buildTextField("Date", dateController1, false,true , context),
                        buildTextField("Amount", amountController, false,false , context),
                        buildTextField("Total EMD", totalEmdController, true,false , context),
                        buildTextField("Total Amount Including EMD",
                            totalAmountEmdController, true,false , context),
                        buildTextField("NFA No.", nfaController, false,false , context),
                        buildTextField("RV Date", dateController2, false,true , context),
                      ] else if (selectedPaymentType == "P") ...[
                        buildTextField("Date", dateController1, false,true , context),
                        buildTextField("Amount", amountController, false,false , context),
                        buildTextField(
                            "Total Payment", totalPaymentController, true,false , context),
                        buildTextField("Total EMD", totalEmdController, true,false , context),
                        buildTextField("Total Amount Including EMD",
                            totalAmountEmdController, true,false , context),
                        buildTextField("RV Date", dateController2, false,true , context),
                      ] else ...[
                        buildTextField("Date", dateController1, false,true , context),
                        buildTextField("Amount", amountController, false,false , context),
                        buildTextField(
                            "Total Payment", totalPaymentController, true,false , context),
                        buildTextField("Total EMD", totalEmdController, true,false , context),
                        buildTextField("Total Amount Including EMD",
                            totalAmountEmdController, true,false , context),
                        buildTextField("Note", noteController, false,false , context),
                        buildTextField("Reference No.", refNoController, false,false , context),
                        buildTextField("RV No.", rvNoController, false,false , context),
                        buildTextField("RV Date", dateController2, false,true , context),
                      ],
                      SizedBox(
                        height: 40,
                      ),
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
                                addRefundDetails();
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
        ]),
      ),
    );
  }

  Widget buildDropdown(String label, Map<String,String> options, ValueChanged<String?> onChanged) {
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
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: selectedOrderId ?? options.keys.first,
              items: options.entries.map((option) {
                return DropdownMenuItem<String>(
                  value: option.value,
                  child: Text(option.key),
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
      String label, TextEditingController controller, bool isReadOnly ,bool isDateField ,context) {
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
        ],
      ),
    );
  }
}

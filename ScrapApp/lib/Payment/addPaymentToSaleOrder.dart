import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../URL_CONSTANT.dart';
import 'package:intl/intl.dart'; // Add this package for date formatting

class addPaymentToSaleOrder extends StatefulWidget {

  final String sale_order_id;
  final String material_name;
  final String branch_id_from_ids;
  final String vendor_id_from_ids;
  final String materialID;


  addPaymentToSaleOrder({
    required this.sale_order_id,
    required this.material_name,
    required this.branch_id_from_ids,
    required this.vendor_id_from_ids,
    required this.materialID,

  });

  @override
  addPaymentToSaleOrderState createState() => addPaymentToSaleOrderState();
}

class addPaymentToSaleOrderState extends State<addPaymentToSaleOrder> {


  final TextEditingController totalPaymentController = TextEditingController();
  final TextEditingController totalEmdController = TextEditingController();
  final TextEditingController totalCmdController = TextEditingController();
  final TextEditingController totalEmdCmdController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController materialNameController = TextEditingController();
  final TextEditingController dateController1 = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController refNoController = TextEditingController();
  final TextEditingController typeTransController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();

  String? username = '';
  String uuid = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';
  String? selectedOrderId;
  String? selectedPaymentType;
  String rate = '';
  bool isLoading = false;
  bool _isChecked = false;

  Map<String , String> PaymentType = {
    'Select' : 'Select',
    'Received Payment':'P',
    'Received EMD':'E',
    'Received CMD':'C',
  };
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
    checkLogin().then((_){
      setState(() {});
    });
    fetchPaymentDetails();
    materialNameController.text = widget.material_name;
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


  Future<void> addPaymentDetails() async {
    if (selectedPaymentType == null || selectedPaymentType!.isEmpty )  {
      Fluttertoast.showToast(msg: 'Please select a payment type.');
      return;
    }

    if (selectedPaymentType == 'Select'){
      Fluttertoast.showToast(msg: 'Please kindly select the Payment type.');
      return;
    }

    if (dateController1.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter a payment date.');
      return;
    }
    if (amountController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter the amount.');
      return;
    }
    if (typeTransController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter the type of transfer.');
      return;
    }
    if (refNoController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter the payment reference number.');
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });
      await checkLogin();
      // ✅ Print all values before sending
      print("======= Payment Details to API =======");
      print("user_id        : $username");
      print("uuid           : $uuid");
      print("user_pass      : $password");
      print("sale_order_id  : ${widget.sale_order_id}");
      print("payment_type   : $selectedPaymentType");
      print("pay_date       : ${dateController1.text}");
      print("emd_type       : ${(selectedPaymentType == 'E' && _isChecked) ? 'F' : 'C'}");
      print("amt            : ${amountController.text}");
      print("pay_ref_no     : ${refNoController.text}");
      print("typeoftransfer : ${typeTransController.text}");
      print("remark         : ${remarkController.text}");
      print("mat_id         : ${widget.materialID}");
      print("======================================");
      final url = Uri.parse("${URL}add_payment_toSaleOrder");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid':uuid,
          'user_pass': password,
          'sale_order_id_pay':widget.sale_order_id ?? '',
          'payment_type': selectedPaymentType ?? '',
          'pay_date': dateController1.text,
          'emd_type': (selectedPaymentType == 'E' && _isChecked) ? 'F' : 'C',
          'amt':amountController.text,
          'pay_ref_no':refNoController.text,
          'typeoftransfer':typeTransController.text,
          'remark':remarkController.text,
          'mat_id':widget.materialID,
        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${jsonData['msg']}")));
          clearFields();
          Navigator.pop(context);
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
    finally{
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchPaymentDetails() async {
    print(widget.sale_order_id);
    print(widget.branch_id_from_ids);
    print(widget.vendor_id_from_ids);

    try {
      setState(() {
        isLoading = true;
      });
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
          'vendor_id':widget.vendor_id_from_ids,
          'mat_id': widget.materialID,

        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          totalPaymentController.text = jsonData['Advance_payment'].toString()?? 'N/A';
          totalEmdController.text = jsonData['total_EMD'].toString() ?? 'N/A';
          totalCmdController.text = jsonData['total_CMD'].toString()  ?? 'N/A';
          totalEmdCmdController.text = jsonData['total_amount_included_emdCmd'].toString() ?? 'N/A';
          totalAmountController.text =  jsonData['totalAmount'].toString() ?? 'N/A';
          rate = jsonData['rate'].toString();
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
      setState(() {
        isLoading = false;
      });
    }
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
      child: StatefulBuilder(builder: (BuildContext context , StateSetter SetState) {
        return Scaffold(
          drawer: AppDrawer(currentPage: 4),
          appBar: CustomAppBar(),
          body:
          Stack(
              children: [
                isLoading ?
                showLoading()
                    :Container(
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
                            child: Column(
                              children: [
                                SizedBox(height: 8,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "ADD PAYMENT DETAILS",
                                      style: TextStyle(
                                        fontSize: 16,
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
                            buildTextField("Total Payment", totalPaymentController,true, false, Colors.grey[400]!,context),
                            buildTextField("Total EMD", totalEmdController,true, false,Colors.grey[400]!, context),
                            buildTextField("Total CMD", totalCmdController,true, false, Colors.grey[400]!,context),
                            buildTextField("Total EMD And CMD", totalEmdCmdController,true, false,Colors.grey[400]!, context),
                            buildTextField("Total Amount", totalAmountController,true, false,Colors.grey[400]!, context),
                            Divider(),
                            buildTextField("Material Name", materialNameController,true, false,Colors.grey[400]!, context), // Modified here for DatePicker
                            buildDropdownPayment("Payment Type", PaymentType, (value) {
                              setState(() {
                                selectedPaymentType = value;
                              });
                            }),
                            if(selectedPaymentType == "E")
                              Row(
                                children: [
                                  Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("is Freezed" , style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w500),),
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Checkbox(
                                      value: _isChecked,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _isChecked = value ?? false;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),

                            buildTextField("Date", dateController1,false, true, Colors.white,context), // Modified here for DatePicker
                            buildTextField("Amount", amountController,false, false,Colors.white, context),
                            buildTextField("Ref/RV No.", refNoController,false, false, Colors.white,context),
                            buildTextField("Type Of Transfer", typeTransController, false,false, Colors.white,context),
                            buildTextField("Remark", remarkController, false,false, Colors.white,context),
                            SizedBox(height: 20),
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
                                      addPaymentDetails();
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
        );
      }),
    );
  }


  Widget buildDropdownPayment(String label, Map<String, String> options, ValueChanged<String?> onChanged) {
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
              value: selectedPaymentType ?? options.keys.first,
              items: options.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.value,
                  child: Text(entry.key),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String labelText, TextEditingController controller,bool isReadOnly, bool isDateField, Color color,BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              labelText,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: GestureDetector(
              onTap: isDateField ? () => _selectDate(context, controller) : null,
              child: AbsorbPointer(
                absorbing: isDateField,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: color
                  ),
                  child: TextFormField(

                    controller: controller,
                    decoration: InputDecoration(
                      suffixIcon: isDateField
                          ? IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context, controller),
                      )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    readOnly: isReadOnly,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }}

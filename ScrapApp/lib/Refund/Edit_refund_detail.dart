import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Refund/View_refund_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../URL_CONSTANT.dart';

class Edit_refund_detail extends StatefulWidget {

  final String? sale_order_id;
  final String? bidder_id;
  final String? refundId;
  final String? paymentType;
  final String? date1;
  final String? amount;
  final String? totalPayment;
  final String? totalEmd;
  final String? totalAmountIncludingEmd;
  final String? note;
  final String? referenceNo;
  final String? rvNo;
  final String? date2;
  final String? typeOfTransfer;
  final String? nfa;
  Edit_refund_detail({
    required this.sale_order_id,
    required this.bidder_id,
    required this.refundId,
    required this.paymentType,
    required this.date1,
    required this.amount,
    required this.totalPayment,
    required this.totalEmd,
    required this.totalAmountIncludingEmd,
    required this.note,
    required this.referenceNo,
    required this.rvNo,
    required this.date2,
    required this.typeOfTransfer,
    required this.nfa,

  });
  @override
  _Edit_refund_detailState createState() => _Edit_refund_detailState();
}

class _Edit_refund_detailState extends State<Edit_refund_detail> {
  final TextEditingController dateController1 = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController totalPaymentController = TextEditingController();
  final TextEditingController totalEmdController = TextEditingController();
  final TextEditingController totalAmountEmdController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController refNoController = TextEditingController();
  final TextEditingController rvNoController = TextEditingController();
  final TextEditingController dateController2 = TextEditingController();
  final TextEditingController nfaController = TextEditingController();

  String? username = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';
  String date1='';
  String amount='';
  String totalPayment='';
  String totalEmd='';
  String totalAmountIncludingEmd='';
  String note='';
  String referenceNo='';
  String rvNo='';
  String date2='';
  String typeOfTransfer='';
  String nfa = '';
  String? selectedPaymentType;
  bool isLoading = false; // Add a loading flag

  Map <String , String> refundMap ={
    "Select" : "Select",
    "Refund(Other than EMD/CMD)" :"R",
    "Refund EMD" : "RE",
    "Refund CMD" : "Rc",
    "Penalty" : "P",
    "Refund All" : "RA"
  };

  void clearFields(){
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

  void initState(){
    super.initState();
    checkLogin().then((_){
      setState(() {});
    });
    getData();
  }

  getData(){
    if (refundMap.containsKey(widget.paymentType)) {
      selectedPaymentType =refundMap['${widget.paymentType}'];
    } else {
      selectedPaymentType = 'Select';
    }
    dateController1.text = widget.date1 ?? 'N/A';
    amountController.text = widget.amount ?? 'N/A';
    totalPaymentController.text = widget.totalPayment ?? 'N/A';
    totalEmdController.text = widget.totalEmd ?? 'N/A';
    totalAmountEmdController.text = widget.totalAmountIncludingEmd ?? 'N/A';
    noteController.text = widget.note ?? 'N/A';
    refNoController.text = widget.referenceNo ?? 'N/A';
    rvNoController.text = widget.rvNo ?? 'N/A';
    dateController2.text = widget.date2 ?? 'N/A';
    nfaController.text = widget.nfa ?? 'N/A';
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
  }

  Future<void> editRefundDetails() async {
    try {
      setState(() {
        isLoading = true;
      });
      await checkLogin();
      final url = Uri.parse("${URL}add_refund_toSaleOrdder");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id':username,
          'user_pass':password,
          'sale_order_id_pay':widget.sale_order_id,
          'pay_id':widget.refundId,
          'payment_type':selectedPaymentType ?? '',
          'pay_date':dateController1.text,
          'amt':amountController.text,
          't_amt':totalPaymentController.text,
          'total_emd':totalEmdController.text,
          'total_amount_including_emd': totalAmountEmdController.text,
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
          Navigator.pop(context);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => View_refund_details(sale_order_id: widget.sale_order_id , bidder_id: widget.bidder_id!,)));
        });
      }else {
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
      absorbing: isLoading,
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
                                "EDIT REFUND DETAILS",
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
                      buildTextField("Total Amount Including EMD", totalAmountEmdController, true,false ,Colors.grey[400]!, context),
                      Divider(),
                      buildDropdownPayment("Payment Type", refundMap, (value) {
                        setState(() {
                          selectedPaymentType = value;
                        });
                      }),
                      if (selectedPaymentType == "R") ...[
                        buildTextField("Date", dateController1, false, true ,Colors.white, context),
                        buildTextField("Amount", amountController, false ,false , Colors.white,context),
                        // buildTextField("Total Payment", totalPaymentController, true, false , Colors.white,context),
                        buildTextField("NFA No.", nfaController, false,false ,Colors.white, context),
                        buildTextField("RV Date", dateController2, false,true ,Colors.white, context),
                      ] else if (selectedPaymentType == "RE" ||
                          selectedPaymentType == "Rc") ...[
                        buildTextField("Date", dateController1, false,true , Colors.white,context),
                        buildTextField("Amount", amountController, false,false ,Colors.white, context),
                        // buildTextField("Total EMD", totalEmdController, true,false ,Colors.white, context),
                        // buildTextField("Total Amount Including EMD", totalAmountEmdController, true,false , Colors.white,context),
                        buildTextField("NFA No.", nfaController, false,false ,Colors.white, context),
                        buildTextField("RV Date", dateController2, false,true ,Colors.white, context),
                      ] else if (selectedPaymentType == "P") ...[
                        buildTextField("Date", dateController1, false,true ,Colors.white, context),
                        buildTextField("Amount", amountController, false,false ,Colors.white, context),
                        // buildTextField("Total Payment", totalPaymentController, true,false ,Colors.white, context),
                        // buildTextField("Total EMD", totalEmdController, true,false ,Colors.white, context),
                        // buildTextField("Total Amount Including EMD", totalAmountEmdController, true,false ,Colors.white, context),
                        buildTextField("RV Date", dateController2, false,true , Colors.white,context),
                      ] else ...[
                        buildTextField("Date", dateController1, false,true , Colors.white,context),
                        buildTextField("Amount", amountController, false,false ,Colors.white, context),
                        // buildTextField("Total Payment", totalPaymentController, true,false , Colors.white,context),
                        // buildTextField("Total EMD", totalEmdController, true,false , Colors.white,context),
                        // buildTextField("Total Amount Including EMD", totalAmountEmdController, true,false ,Colors.white, context),
                        buildTextField("Note", noteController, false,false , Colors.white,context),
                        buildTextField("Ref/RV No.", refNoController, false,false , Colors.white,context),
                        // buildTextField("RV No.", rvNoController, false,false , Colors.white,context),
                        buildTextField("RV Date", dateController2, false,true ,Colors.white, context),
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
                                editRefundDetails();
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
        ]),
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
              value: selectedPaymentType ?? options.keys.first ,
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
      String label, TextEditingController controller, bool isReadOnly ,bool isDateField ,Color color,context) {
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

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:intl/intl.dart';
// import 'package:scrapapp/AppClass/AppDrawer.dart';
// import 'package:scrapapp/AppClass/appBar.dart';
// import 'package:http/http.dart' as http;
// import 'package:scrapapp/Payment/View_payment_detail.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../URL_CONSTANT.dart';
//
// class Edit_payment_detail extends StatefulWidget {
//   final String? sale_order_id;
//   final String? bidder_id;
//   final String? paymentId;
//   final String? paymentType;
//   final String? date1;
//   final String? amount;
//   final String? referenceNo;
//   final String? typeOfTransfer;
//
//   Edit_payment_detail({
//     required this.sale_order_id,
//     required this.bidder_id,
//     required this.paymentId,
//     required this.paymentType,
//     required this.date1,
//     required this.amount,
//     required this.referenceNo,
//     required this.typeOfTransfer,
//   });
//
//   @override
//   _Edit_payment_detailState createState() => _Edit_payment_detailState();
// }
//
// class _Edit_payment_detailState extends State<Edit_payment_detail> {
//   final TextEditingController totalPaymentController = TextEditingController();
//   final TextEditingController totalEmdController = TextEditingController();
//   final TextEditingController totalCmdController = TextEditingController();
//   final TextEditingController totalEmdCmdController = TextEditingController();
//   final TextEditingController dateController1 = TextEditingController();
//   final TextEditingController amountController = TextEditingController();
//   final TextEditingController refNoController = TextEditingController();
//   final TextEditingController typeTransController = TextEditingController();
//   final TextEditingController remarkController = TextEditingController();
//
//   String? username = '';
//   String uuid = '';
//   String? password = '';
//   String? loginType = '';
//   String? userType = '';
//   bool isLoading = false;
//   String? selectedPaymentType;
//
//   Map<String, String> PaymentType = {
//     'Select': 'Select',
//     'Received Payment': 'P',
//     'Received EMD': 'E',
//     'Received CMD': 'C',
//   };
//
//   void clearFields() {
//     selectedPaymentType = null;
//     dateController1.clear();
//     amountController.clear();
//     refNoController.clear();
//     typeTransController.clear();
//   }
//
//   @override
//   initState() {
//     super.initState();
//     checkLogin().then((_) {
//       setState(() {});
//     });
//     fetchPaymentDetails();
//     getData();
//   }
//
//   getData() {
//     if (PaymentType.containsKey(widget.paymentType)) {
//       selectedPaymentType = PaymentType['${widget.paymentType}'];
//     } else {
//       selectedPaymentType = 'Select';
//     }
//     dateController1.text = widget.date1!;
//     amountController.text = widget.amount!;
//     refNoController.text = widget.referenceNo!;
//     typeTransController.text = widget.typeOfTransfer!;
//   }
//
//   Future<void> checkLogin() async {
//     final prefs = await SharedPreferences.getInstance();
//     username = prefs.getString("username");
//     uuid = prefs.getString("uuid")!;
//     uuid = prefs.getString("uuid")!;
//     password = prefs.getString("password");
//     loginType = prefs.getString("loginType");
//     userType = prefs.getString("userType");
//   }
//
//   Future<void> editPaymentDetails() async {
//     try {
//       setState(() {
//         isLoading = true;
//       });
//       await checkLogin();
//       final url = Uri.parse("${URL}add_payment_toSaleOrder");
//       var response = await http.post(
//         url,
//         headers: {"Accept": "application/json"},
//         body: {
//           'user_id': username,
//           'uuid': uuid,
//           'user_pass': password,
//           'sale_order_id_pay': widget.sale_order_id,
//           'pay_id': widget.paymentId,
//           'payment_type': selectedPaymentType ?? '',
//           'pay_date': dateController1.text ?? '',
//           'amt': amountController.text ?? '',
//           'pay_ref_no': refNoController.text ?? '',
//           'typeoftransfer': typeTransController.text ?? '',
//           'narration': remarkController.text,
//         },
//       );
//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         setState(() {
//           ScaffoldMessenger.of(context)
//               .showSnackBar(SnackBar(content: Text("${jsonData['msg']}")));
//           clearFields();
//           Navigator.pop(context);
//           Navigator.pop(context);
//           Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => View_payment_detail(
//                         sale_order_id: widget.sale_order_id!,
//                         bidder_id: widget.bidder_id!,
//                         branch_id_from_ids: '',
//                         vendor_id_from_ids: '',
//                         materialId: '', // Extracted from "Ids"
//                       )));
//         });
//       } else {
//         Fluttertoast.showToast(
//             msg: 'Unable to insert data.',
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             timeInSecForIosWeb: 1,
//             backgroundColor: Colors.red,
//             textColor: Colors.yellow);
//       }
//     } catch (e) {
//       Fluttertoast.showToast(
//           msg: 'Server Exception : $e',
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           timeInSecForIosWeb: 1,
//           backgroundColor: Colors.red,
//           textColor: Colors.yellow);
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> fetchPaymentDetails() async {
//     try {
//       setState(() {
//         isLoading = true;
//       });
//       await checkLogin();
//       final url = Uri.parse("${URL}EMD_CMD_details");
//       var response = await http.post(
//         url,
//         headers: {"Accept": "application/json"},
//         body: {
//           'user_id': username,
//           'uuid': uuid,
//           'user_pass': password,
//           'sale_order_id': widget.sale_order_id,
//           'sale_order_id': widget.sale_order_id,
//           'branch_id':widget.branch_id_from_ids,
//           'vendor_id':widget.vendor_id_from_ids,
//         },
//       );
//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         setState(() {
//           totalPaymentController.text = jsonData['t_amt'].toString() ?? 'N/A';
//           totalEmdController.text = jsonData['total_EMD'].toString() ?? 'N/A';
//           totalCmdController.text = jsonData['total_CMD'].toString() ?? 'N/A';
//           totalEmdCmdController.text =
//               jsonData['total_amount_included_emdCmd'].toString() ?? 'N/A';
//         });
//       } else {
//         Fluttertoast.showToast(
//             msg: 'Unable to load data.',
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             timeInSecForIosWeb: 1,
//             backgroundColor: Colors.red,
//             textColor: Colors.yellow);
//       }
//     } catch (e) {
//       Fluttertoast.showToast(
//           msg: 'Server Exception : $e',
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           timeInSecForIosWeb: 1,
//           backgroundColor: Colors.red,
//           textColor: Colors.yellow);
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   showLoading() {
//     return Container(
//       height: double.infinity,
//       width: double.infinity,
//       color: Colors.transparent,
//       child: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AbsorbPointer(
//       absorbing: isLoading,
//       child: Scaffold(
//         drawer: AppDrawer(currentPage: 4),
//         appBar: CustomAppBar(),
//         body: Stack(children: [
//           isLoading
//               ? showLoading()
//               : Container(
//                   padding: const EdgeInsets.symmetric(vertical: 4.0),
//                   color: Colors.grey[100],
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           "Payment",
//                           style: TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                             letterSpacing: 1.5,
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Material(
//                           elevation: 2,
//                           color: Colors.white,
//                           shape: OutlineInputBorder(
//                               borderSide:
//                                   BorderSide(color: Colors.blueGrey[400]!)),
//                           child: Container(
//                             child: Column(
//                               children: [
//                                 SizedBox(
//                                   height: 8,
//                                 ),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                       "EDIT PAYMENT DETAILS",
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         color: Colors.black54,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(
//                                   height: 8,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 16),
//                       Expanded(
//                         child: ListView(
//                           children: [
//                             buildTextField(
//                                 "Total Payment",
//                                 totalPaymentController,
//                                 true,
//                                 false,
//                                 Colors.grey[400]!,
//                                 context),
//                             buildTextField("Total EMD", totalEmdController,
//                                 true, false, Colors.grey[400]!, context),
//                             buildTextField("Total CMD", totalCmdController,
//                                 true, false, Colors.grey[400]!, context),
//                             buildTextField(
//                                 "Total Amount Including EMD/CMD",
//                                 totalEmdCmdController,
//                                 true,
//                                 false,
//                                 Colors.grey[400]!,
//                                 context),
//                             Divider(),
//                             buildDropdownPayment("Payment Type", PaymentType,
//                                 (value) {
//                               setState(() {
//                                 selectedPaymentType = value;
//                               });
//                             }),
//                             buildTextField(
//                                 "Date",
//                                 dateController1,
//                                 false,
//                                 true,
//                                 Colors.white,
//                                 context), // Modified here for DatePicker
//                             buildTextField("Amount", amountController, false,
//                                 false, Colors.white, context),
//                             buildTextField("Ref/RV No.", refNoController, false,
//                                 false, Colors.white, context),
//                             buildTextField(
//                                 "Type Of Transfer",
//                                 typeTransController,
//                                 false,
//                                 false,
//                                 Colors.white,
//                                 context),
//                             buildTextField("Remark", remarkController, false,
//                                 false, Colors.white, context),
//                             SizedBox(
//                               height: 40,
//                             ),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 8.0),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   ElevatedButton(
//                                     onPressed: () {
//                                       clearFields();
//                                       Navigator.of(context).pop();
//                                     },
//                                     child: Text("Back"),
//                                     style: ElevatedButton.styleFrom(
//                                       foregroundColor: Colors.white,
//                                       backgroundColor: Colors.indigo[800],
//                                       padding: EdgeInsets.symmetric(
//                                           horizontal: 50, vertical: 12),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                     ),
//                                   ),
//                                   ElevatedButton(
//                                     onPressed: () {
//                                       editPaymentDetails();
//                                     },
//                                     child: Text("Save"),
//                                     style: ElevatedButton.styleFrom(
//                                       foregroundColor: Colors.white,
//                                       backgroundColor: Colors.indigo[800],
//                                       padding: EdgeInsets.symmetric(
//                                           horizontal: 50, vertical: 12),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//         ]),
//       ),
//     );
//   }
//
//   Widget buildDropdownPayment(String label, Map<String, String> options,
//       ValueChanged<String?> onChanged) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 3, // Adjusts label width
//             child: Text(
//               label,
//               style: TextStyle(
//                 color: Colors.black54,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 7, // Adjusts dropdown width
//             child: DropdownButtonFormField<String>(
//               isExpanded: true,
//               decoration: InputDecoration(
//                 contentPadding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               value: selectedPaymentType,
//               items: options.entries.map((entry) {
//                 return DropdownMenuItem<String>(
//                   value: entry.value, // Key is used as value for Dropdown
//                   child: Text(entry.key), // Value is displayed as text
//                 );
//               }).toList(),
//               onChanged: onChanged,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _selectDate(
//       BuildContext context, TextEditingController controller) async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null) {
//       String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
//       controller.text = formattedDate;
//     }
//   }
//
//   Widget buildTextField(String labelText, TextEditingController controller,
//       bool isReadOnly, bool isDateField, Color color, BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 3,
//             child: Text(
//               labelText,
//               style: TextStyle(
//                 color: Colors.black54,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 7,
//             child: GestureDetector(
//               onTap:
//                   isDateField ? () => _selectDate(context, controller) : null,
//               child: AbsorbPointer(
//                 absorbing: isDateField,
//                 child: Container(
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12), color: color),
//                   child: TextFormField(
//                     controller: controller,
//                     decoration: InputDecoration(
//                       suffixIcon: isDateField
//                           ? IconButton(
//                               icon: Icon(Icons.calendar_today),
//                               onPressed: () => _selectDate(context, controller),
//                             )
//                           : null,
//                       contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 16),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     readOnly: isReadOnly,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

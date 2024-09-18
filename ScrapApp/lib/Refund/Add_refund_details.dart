import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';

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

  String? selectedOrderId;
  String? selectedPaymentType;

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
                  buildTextField("Order ID" ,orderIdController, true),
                  buildDropdown("Payment Type", ["Select","Refund(Other than EMD/CMD)", "Refund EMD", "Refund CMD","Penalty","Refund All"], (value) {
                    setState(() {
                      selectedPaymentType = value;
                    });
                  }),
                  buildTextField("Date", dateController1 , false),
                  buildTextField("Amount", amountController, false),
                  buildTextField("Total Payment", totalPaymentController, false),
                  buildTextField("Total EMD", totalEmdController, false),
                  buildTextField("Total Amount Including EMD", totalAmountController, false),
                  buildTextField("Note", noteController, false),
                  buildTextField("Reference No.", refNoController, false),
                  buildTextField("RV No.", rvNoController, false),
                  buildTextField("Date", dateController2, false),
                  buildTextField("Type Of Transfer", typeTransController, false),
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
                            clearFields();
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

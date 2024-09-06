import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Payment/Edit_payment_detail.dart';

class View_Payment_Amount extends StatelessWidget {
   String paymentType='';
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

  // View_Payment_Amount({
  //   required this.paymentType,
  //   required this.date1,
  //   required this.amount,
  //   required this.totalPayment,
  //   required this.totalEmd,
  //   required this.totalAmountIncludingEmd,
  //   required this.note,
  //   required this.referenceNo,
  //   required this.rvNo,
  //   required this.date2,
  //   required this.typeOfTransfer,
  // });

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
                Spacer(),
                Text(
                  "View",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
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
                        builder: (context) => Edit_payment_detail(),
                      ),
                    );
                  },
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
                  buildDisplay("Payment Type", paymentType),
                  buildDisplay("Date", date1),
                  buildDisplay("Amount", amount),
                  buildDisplay("Total Payment", totalPayment),
                  buildDisplay("Total EMD", totalEmd),
                  buildDisplay("Total Amount Including EMD", totalAmountIncludingEmd),
                  buildDisplay("Note", note),
                  buildDisplay("Reference No.", referenceNo),
                  buildDisplay("RV No.", rvNo),
                  buildDisplay("Date", date2),
                  buildDisplay("Type Of Transfer", typeOfTransfer),
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

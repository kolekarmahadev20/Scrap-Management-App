import 'package:flutter/material.dart';

class InvoicePage extends StatefulWidget {
  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Invoice"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("TAX INVOICE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text("Balance Due: RS 54,000", style: TextStyle(color: Colors.red, fontSize: 16)),
                        SizedBox(height: 10),
                        Text("Invoice Date: 24/6/2025"),
                        Text("Start: Due on receive"),
                        Text("End Date: 12/3/2025"),
                        Text("POD: 34344343"),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text("Bill To:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Mishra Traders"),
              Text("35, Asha Colony, Coimbatore, Chennai"),
              Text("GSTIN: 4545454544"),
              SizedBox(height: 20),
              Table(
                border: TableBorder.all(),
                columnWidths: {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(1),
                  5: FlexColumnWidth(1),
                  6: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[300]),
                    children: [
                      tableCell("Items & Description"),
                      tableCell("MGN & SRC"),
                      tableCell("HRS"),
                      tableCell("Rate"),
                      tableCell("CGST"),
                      tableCell("SGST"),
                      tableCell("Amount"),
                    ],
                  ),
                  tableRow("Structure Design", "992", "1.00", "2323", "5454", "7878", "50,000"),
                  tableRow("Responsive Design", "456", "3.00", "5323", "5554", "7578", "80,000"),
                  tableRow("Startofand Design", "456", "3.00", "5323", "5554", "7578", "80,000"),
                ],
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Sub Total: 53,000", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("CGST: 6,3600", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("SGST: 6,3600", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("Balance Due: RS 45,000", style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tableCell(String text) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  TableRow tableRow(String item, String mgn, String hrs, String rate, String cgst, String sgst, String amount) {
    return TableRow(
      children: [
        tableCell(item),
        tableCell(mgn),
        tableCell(hrs),
        tableCell(rate),
        tableCell(cgst),
        tableCell(sgst),
        tableCell(amount),
      ],
    );
  }
}


import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Dispatch/Edit_dispatch_details.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../URL_CONSTANT.dart'; // Import for File

class View_dispatch_lifting_details extends StatefulWidget {
  final String sale_order_id;
  final String bidder_id;
  final String lift_id;
  final String? selectedOrderId;
  final String? material;
  final String? invoiceNo;
  final String? date;
  final String? truckNo;
  final String? firstWeight;
  final String? fullWeight;
  final String? moistureWeight;
  final String? netWeight;
  final String? quantity;
  final String? note;

  View_dispatch_lifting_details({
    required this.sale_order_id,
    required this.bidder_id,
    required this.lift_id,
    required this.selectedOrderId,
    required this.material,
    required this.invoiceNo,
    required this.date,
    required this.truckNo,
    required this.firstWeight,
    required this.fullWeight,
    required this.moistureWeight,
    required this.netWeight,
    required this.quantity,
    required this.note,
  });

  @override
  State<View_dispatch_lifting_details> createState() => _View_dispatch_lifting_detailsState();
}

class _View_dispatch_lifting_detailsState
    extends State<View_dispatch_lifting_details> {
  String? username = '';
 String uuid = '';

  String? password = '';
  String? loginType = '';
  String? userType = '';


  String selectedOrderId = '';

  String material = '';

  String invoiceNo = '';

  String date = '';

  String truckNo = '';

  String firstWeight= '';

  String fullWeight = '';

  String moistureWeight = '';

  String netWeight = '';

  String quantity = '';

  String note = '';

  bool isLoading = false;

  String? frontVehicle;
  String? backVehicle;
  String? materialImg;
  String? materialHalfLoad;
  String? materialFullLoad;
  // String? otherImg;

  List<String> otherImg = [];

  @override
  void initState() {
    super.initState();
    checkLogin().then((_){
      setState(() {});
    });
    fetchPaymentDetails();
    fetchImageList();
    getData();
    print("Hello");
    print(widget.bidder_id);
    print("Hello");

  }


  getData(){


    print("GM : ${widget.netWeight}");


    selectedOrderId = widget.selectedOrderId ?? "N/A";
    material = widget.material ?? 'N/A';
    invoiceNo = widget.invoiceNo ?? 'N/A';
    date = widget.date ?? 'N/A';
    truckNo = (widget.truckNo?? 'N/A').toUpperCase() ;
    firstWeight = widget.firstWeight ?? "N/A";
    fullWeight = widget.fullWeight ?? "N/A";
    moistureWeight = widget.moistureWeight ?? "N/A";
    netWeight = widget.netWeight ?? "N/A";
    quantity = widget.quantity ?? 'N/A';
    note = widget.note ?? 'N/A';

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


  List<Map<String, dynamic>> taxDetailsList = [];


  Map<String , dynamic> taxAmount = {};
  Map<String , dynamic> ViewPaymentData = {};
  List<dynamic> paymentId =[];
  List<dynamic> paymentStatus =[];
  List<dynamic> emdStatus =[];
  List<dynamic> cmdStatus =[];
  List<dynamic> taxes =[];
  var checkLiftedQty ;
  var netAmount;

  showLoading() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.transparent,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }


  Future<void> fetchImageList() async {
    print("BAHSFHASF");

    print(widget.sale_order_id);
    print( widget.invoiceNo);


    try {
      setState(() {
        isLoading = true;
      });
      await checkLogin();
      final url = Uri.parse("${URL}check_url");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid': uuid,
          'user_pass': password,
          'sale_order_id': widget.sale_order_id,
          'invoice_no': widget.invoiceNo,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          var jsonData = json.decode(response.body);

          print("Response Data: $jsonData");

          // Check if the response is empty
          if (jsonData.isEmpty) {
            print("No data returned from the API.");
            frontVehicle = "";
            backVehicle = "";
            materialImg = "";
            materialHalfLoad = "";
            materialFullLoad = "";
            otherImg = [];
          } else if (jsonData is Map<String, dynamic>) {
            // Handle the valid map response
            frontVehicle = jsonData['Fr'] != null ? '${Image_URL}${jsonData['Fr']}' : "";
            backVehicle = jsonData['Ba'] != null ? '${Image_URL}${jsonData['Ba']}' : "";
            materialImg = jsonData['Ma'] != null ? '${Image_URL}${jsonData['Ma']}' : "";
            materialHalfLoad = jsonData['Ha'] != null ? '${Image_URL}${jsonData['Ha']}' : "";
            materialFullLoad = jsonData['Fu'] != null ? '${Image_URL}${jsonData['Fu']}' : "";

            // Handling 'ot' as a list
            if (jsonData['ot'] != null && jsonData['ot'] is List) {
              otherImg = (jsonData['ot'] as List)
                  .map((img) => '${Image_URL}$img')
                  .toList();
            } else {
              otherImg = [];
            }
          } else {
            print("Unexpected data structure: $jsonData");
          }
        });
      } else {
        print("Unable to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Server Exception: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> fetchPaymentDetails() async {

    print(widget.sale_order_id);
    print(widget.bidder_id);
    print("asfasfasf");

    try {
      setState(() {
        isLoading = true;
      });
      await checkLogin();
      final url = Uri.parse("${URL}payment_details");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid':uuid,
          'user_pass': password,
          'sale_order_id':widget.sale_order_id,
          'bidder_id':widget.bidder_id,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          final data = json.decode(response.body);
          var jsonData = json.decode(response.body);
          ViewPaymentData = jsonData;
          paymentId = ViewPaymentData['sale_order_payments'] ?? [];
          emdStatus =  ViewPaymentData['emd_status'] ?? [];
          cmdStatus =  ViewPaymentData['cmd_status'] ?? [];
          paymentStatus =  ViewPaymentData['recieved_payment'] ?? [];
          checkLiftedQty = ViewPaymentData['lifted_quantity'];
          taxes = ViewPaymentData['tax_and_rate']['taxes'] ??[];
          taxAmount = ViewPaymentData['tax_and_rate'] ?? {};

          // Update your variables with the fetched data
          materialLiftingDetails = List<Map<String, dynamic>>.from(data['material_lifting_details'].values);
          totalMaterialLiftedAmount = data['total_material_lifted_amount'];
          liftedQuantity = List<Map<String, dynamic>>.from(data['lifted_quantity']);


          taxDetailsList = List<Map<String, dynamic>>.from(data['taxDetails'] ?? []);
          balanceQty = data['balance_qty'];
          totalBalance = data['total_balance'];
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


  // Future<void> downloadFile(String url, String fileName) async {
  //
  //   try {
  //     print('Fetching file from URL: $url');
  //     final response = await http.get(Uri.parse(url));
  //
  //     if (response.statusCode == 200) {
  //       final directory = await getTemporaryDirectory();
  //       final filePath = '${directory.path}/$fileName';
  //       final file = File(filePath);
  //
  //       await file.writeAsBytes(response.bodyBytes);
  //       print('File saved to: $filePath');
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('File downloaded: $fileName')),
  //       );
  //       // Open the file
  //       OpenFile.open(filePath);
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to download file: ${response.statusCode}')),
  //       );
  //     }
  //   } catch (e) {
  //     print('Exception: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: $e')),
  //     );
  //   }
  // }

  Widget buildVendorInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildVendorInfoText(
            "Vendor Name : ",
            ViewPaymentData['vendor_buyer_details']['vendor_name'] ?? 'N/A',
            false),
        buildVendorInfoText(
            "Branch : ",
            ViewPaymentData['vendor_buyer_details']['branch_name'] ?? 'N/A',
            false),
        buildVendorInfoText(
            "Buyer Name : ",
            ViewPaymentData['vendor_buyer_details']['bidder_name'] ?? 'N/A',
            false),
      ],
    );
  }

  Widget buildVendorInfoText(String key, String value, bool isRed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Push key left & value right
        children: [
          Text(
            key,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black, // Bold key text
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isRed ? FontWeight.bold : FontWeight.normal,
                color: isRed ? Colors.redAccent : Colors.black54, // Color based on isRed
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildExpansionTile() {
    return Material(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Sale Order Details",
                style: TextStyle(
                  fontSize: 21, // Increase font size
                  fontWeight: FontWeight.bold, // Make it bold
                ),
              ),
            ),
            buildPaymentDetailsCard(ViewPaymentData),

            // buildListTile(
            //     "Material Name : ${ViewPaymentData['sale_order_details']?[0]['material_name'] ?? 'N/A'}"),
            // buildListTile(
            //     "Total Qty : ${ViewPaymentData['sale_order_details'][0]['qty'] ?? 'No data'} ${ViewPaymentData['sale_order_details'][0]['totunit'] ?? ''}"),
            // if (ViewPaymentData['lifted_quantity'] != null &&
            //     ViewPaymentData['lifted_quantity'] is List &&
            //     ViewPaymentData['lifted_quantity'].isNotEmpty)
            //   buildListTile(
            //       "Lifted Qty : ${ViewPaymentData['lifted_quantity'][0]['quantity'] ?? 'No data'} ${ViewPaymentData['sale_order_details'][0]['totunit'] ?? ''}"),
            // buildListTile(
            //     "Rate : ${ViewPaymentData['sale_order_details'][0]['rate'] ?? 'No data'}"),
            // buildListTile(
            //     "SO Date : ${ViewPaymentData['sale_order_details'][0]['sod'] ?? 'No data'}"),
            // buildListTile(
            //     "SO Validity : ${ViewPaymentData['sale_order_details'][0]['sovu'] ?? 'No data'}
            Divider(),
            buildTable(),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentDetailsCard(Map<String, dynamic> ViewPaymentData) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDetailTile(
                "Material Name : ",
                ViewPaymentData['sale_order_details']?[0]['material_name'] ?? 'N/A',
                Icons.category),
            buildDetailTile(
                "Total Qty : ",
                "${ViewPaymentData['sale_order_details'][0]['qty'] ?? 'No data'} ${ViewPaymentData['sale_order_details'][0]['totunit'] ?? ''}",
                Icons.inventory),
            // buildDetailTile(
            //     "Balance Qty : ",
            //     "${ViewPaymentData['sale_order_details'][0]['qty'] ?? 'No data'} ${ViewPaymentData['sale_order_details'][0]['totunit'] ?? ''}",
            //     Icons.inventory),
            if (ViewPaymentData['lifted_quantity'] != null &&
                ViewPaymentData['lifted_quantity'] is List &&
                ViewPaymentData['lifted_quantity'].isNotEmpty)
              buildDetailTile(
                  "Lifted Qty : ",
                  "${ViewPaymentData['lifted_quantity'][0]['quantity'] ?? 'No data'} ${ViewPaymentData['sale_order_details'][0]['totunit'] ?? ''}",
                  Icons.local_shipping),
            buildDetailTile(
                "Rate : ",
                ViewPaymentData['sale_order_details'][0]['rate']?.toString() ?? 'No data',
                Icons.attach_money),
            buildDetailTile(
                "SO Date : ",
                formatDate(ViewPaymentData['sale_order_details'][0]['sod']),
                Icons.date_range),
            buildDetailTile(
                "SO Validity : ",
                formatDate(ViewPaymentData['sale_order_details'][0]['sovu']),
                Icons.event_available),
          ],
        ),
      ),
    );
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return 'No data';
    }
    try {
      DateTime parsedDate = DateTime.parse(dateStr);
      return
        DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Widget buildDetailTile(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListTile(String text) {
    return ListTile(
      title: Text(text),
      visualDensity: VisualDensity(vertical: -4),
    );
  }

  Widget buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: 400,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              spreadRadius: 2,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: DataTable(
          columnSpacing: 20,
          headingRowHeight: 48,
          dataRowHeight: 44,
          border: TableBorder.symmetric(
            inside: BorderSide(color: Colors.grey.shade300),
          ),
          columns: [
            DataColumn(
              label: Text(
                'Tax',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            DataColumn(
              label: Text(
                'Amount',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          ],
          rows: [
            DataRow(
              color: MaterialStateProperty.all(Colors.grey.shade200),
              cells: [
                DataCell(Text('Basic Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text('₹${taxAmount['basicTaxAmount']}', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            if (taxes.isNotEmpty)
              ...taxes.map((tax) {
                return DataRow(
                  cells: [
                    DataCell(Text(tax['tax_name'] ?? 'No data')),
                    DataCell(Text('₹${tax['tax_amount'] ?? 'No data'}')),
                  ],
                );
              }).toList(),
            DataRow(
              color: MaterialStateProperty.all(Colors.grey.shade200),
              cells: [
                DataCell(Text('Final Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text('₹${taxAmount['finalTaxAmount']}', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> materialLiftingDetails = [];
  List<dynamic> liftedQuantity = [];
  double balanceQty = 0.0;
  double totalBalance = 0.0;
  double totalMaterialLiftedAmount = 0.0;

  TableRow buildTableRows(List<String> labels, List<String?> values, int index) {
    assert(labels.length == values.length);

    return TableRow(
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : Colors.grey[200],
      ),
      children: List.generate(labels.length, (idx) {
        return TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labels[idx],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(values[idx] ?? ''),
              ],
            ),
          ),
        );
      }),
    );
  }

  TableRow buildTableRow(String label, String? value,int index) {
    return TableRow(
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : Colors.grey[200],
      ),
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(value.toString()),
          ),
        ),
      ],
    );
  }

  Widget buildSummary() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSummaryRow(
              "Lifted Quantity:",
          liftedQuantity.isNotEmpty
              ? "${liftedQuantity[0]['quantity']} ${ViewPaymentData['sale_order_details'][0]['totunit'] ?? ""}"
              : "N/A",
              totalMaterialLiftedAmount != null ? totalMaterialLiftedAmount.toStringAsFixed(2) : "N/A"
          ),
          buildSummaryRow(
              "Balance:",
              balanceQty != null
                  ? "${balanceQty} ${ViewPaymentData['sale_order_details'][0]['totunit'] ?? ""}"
                  : "N/A",
              totalBalance != null ? totalBalance.toStringAsFixed(2) : "N/A"
          ),
        ],
      ),
    );
  }


  Widget buildSummaryRow(String title, String qty, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 20),
          Text(qty),
          SizedBox(width: 20),
          Text(amount),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentPage: 5),
      appBar: CustomAppBar(),
      body: isLoading
          ? showLoading()
          : Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        color: Colors.grey[100],
        child: SingleChildScrollView( // Wrap Column inside this
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Dispatch",
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
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blueGrey[400]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Spacer(),
                      Text(
                        "VIEW MATERIAL LIFTING DETAIL",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Spacer(),
                      Opacity(
                        opacity: 1.0,
                        child: IconButton(
                          icon: Icon(
                            Icons.edit,
                            size: 30,
                            color: Colors.indigo[800],
                          ),
                          onPressed: (userType == 'S' || userType == 'A' || userType == 'U')
                              ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Edit_dispatch_details(
                                  sale_order_id: widget.sale_order_id,
                                  bidder_id: widget.bidder_id,
                                  lift_id: widget.lift_id,
                                  material: material,
                                  invoiceNo: invoiceNo,
                                  truckNo: truckNo,
                                  firstWeight: firstWeight,
                                  fullWeight: fullWeight,
                                  moistureWeight: moistureWeight,
                                  netWeight: netWeight,
                                  note: note,
                                  quantity: quantity,
                                  selectedOrderId: selectedOrderId,
                                  date: date,
                                ),
                              ),
                            );
                          }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildVendorInfo(),
              ),
              buildExpansionTile(),
              SizedBox(height: 16),
              ListView(
                shrinkWrap: true, // Important to avoid infinite height issue
                physics: NeverScrollableScrollPhysics(), // Prevent nested scrolling
                children: [
                  buildDisplayField("Material", material),
                  buildDisplayField("Invoice No", invoiceNo),
                  buildDisplayField("Date", date),
                  buildDisplayField("Truck No", truckNo),
                  buildDisplayField("First Weight", firstWeight),
                  buildDisplayField("Full Weight", fullWeight),
                  buildDisplayField("Moisture Weight", moistureWeight),
                  buildDisplayField("Net Weight", netWeight),
                  buildDisplayField("Quantity", quantity),
                  buildDisplayField("Note", note),

                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: materialLiftingDetails.asMap().entries.map((entry) {
                        int index = entry.key;
                        var item = entry.value;

                        // Get tax details for the current invoice based on index
                        List<Map<String, dynamic>> taxDetails = (ViewPaymentData['taxDetails'] as List<dynamic>?)
                            ?.map((taxItem) => Map<String, dynamic>.from(taxItem))
                            .toList() ?? [];

                        // Ensure taxDetails length matches invoice count
                        Map<String, dynamic> currentTax = (index < taxDetails.length) ? taxDetails[index] : {};

                        print("Invoice: ${item['invoice_no']}");
                        print("Tax Details for this invoice: $currentTax");

                        List<String> taxNames = [];
                        List<String> taxAmounts = [];

                        if (currentTax.isNotEmpty) {
                          currentTax.forEach((key, value) {
                            taxNames.add(key); // Tax Name (e.g., IGST-18, TCS)
                            taxAmounts.add(value.toString()); // Corresponding tax amount
                          });
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(),
                            Center(
                              child: Text(
                                "Invoice Details - ${item['invoice_no']}",
                                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: 5),
                            Table(
                              border: TableBorder.symmetric(
                                inside: BorderSide(color: Colors.grey.shade300),
                              ),
                              columnWidths: {
                                0: FixedColumnWidth(150),
                              },
                              children: [
                                buildTableRows(['INVOICE NO', 'DATE'], [item['invoice_no'], item['date_time']], 1),
                                buildTableRows(
                                    ['MATERIAL NAME', 'TRUCK NO'],
                                    [item['material_name'], item['truck_no'].toString().toUpperCase()],
                                    0
                                ),
                                buildTableRows(
                                    ['QTY', 'Amount'],
                                    [
                                      "${item['qty']} ${ViewPaymentData['sale_order_details'][0]['totunit'] ?? ""}",
                                      item['total_amt'].toString()
                                    ],
                                    1
                                ),
                                for (int i = 0; i < taxNames.length; i++)
                                  buildTableRows([taxNames[i], 'Amount'], [taxNames[i], taxAmounts[i]], i % 2 == 0 ? 0 : 1),
                              ],
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),


                  Divider(),

                  SizedBox(height: 5),
                  buildSummary(),

                  SizedBox(height: 50),
                  if( otherImg!= null ||  otherImg!.isNotEmpty)
                     Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: Text(
                        //     "View Images",
                        //     style: TextStyle(
                        //         fontWeight: FontWeight.bold, fontSize: 24),
                        //   ),
                        // ),
                        // ImageWidget(value: '1) Vehicle Front', filePath: frontVehicle!),
                        // ImageWidget(value: '2) Vehicle Back', filePath: backVehicle!),
                        // ImageWidget(value: '3) Material', filePath: materialImg!),
                        // ImageWidget(value: '4) Material Half Load', filePath: materialHalfLoad!),
                        // ImageWidget(value: '5) Material Full Load', filePath: materialFullLoad!),
                        ImageWidget(value: 'View Images', filePaths: otherImg),
                      ],
                    ),
                  ),
                  SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                  SizedBox(height: 16),
                ],
              ),
            ],
          ),
        ),
      ),

    );
  }

  Widget buildDisplayField(String label, String value) {
    return Padding(
       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          SizedBox(width: 15),
          Expanded(
            flex: 3, // Adjusts label width
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3, // Adjusts text display width
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 25,)
        ],
      ),
    );
  }
}

class ImageWidget extends StatefulWidget {
  final String value;
  final List<String>? filePaths;

  const ImageWidget({
    Key? key,
    required this.value,
    required this.filePaths,
  }) : super(key: key);

  @override
  _ImageWidgetState createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  List<Uint8List> imageBytesList = [];

  void showNoImage() {
    Fluttertoast.showToast(
      msg: "No images Found",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _fetchFileBytesFromServer(List<String> fileUrls) async {
    try {
      List<Uint8List> loadedImages = [];
      for (String fileUrl in fileUrls) {
        var response = await http.get(Uri.parse(fileUrl));
        if (response.statusCode == 200) {
          loadedImages.add(response.bodyBytes);
        }
      }

      if (loadedImages.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImagePreviewScreen(images: loadedImages),
          ),
        );
      } else {
        showNoImage();
      }
    } catch (e) {
      showNoImage();
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                widget.value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.photo, color: Colors.blue, size: 30),
                onPressed: () {
                  if (widget.filePaths == null || widget.filePaths!.isEmpty) {
                    showNoImage();
                  } else {
                    _fetchFileBytesFromServer(widget.filePaths!);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// New Page for Image Preview with Slider
class ImagePreviewScreen extends StatefulWidget {
  final List<Uint8List> images;

  const ImagePreviewScreen({Key? key, required this.images}) : super(key: key);

  @override
  _ImagePreviewScreenState createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor:Colors.blueGrey[700],
        title: Text(
          "Image Preview",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 2,
        shadowColor: Colors.black,
        shape: OutlineInputBorder(

            borderSide: BorderSide(style: BorderStyle.solid ,color: Colors.white60)
        ),

      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                itemCount: widget.images.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Center(
                    child: Image.memory(
                      widget.images[index],
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "${currentIndex + 1} / ${widget.images.length}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


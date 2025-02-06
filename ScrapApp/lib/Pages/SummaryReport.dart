import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:clipboard/clipboard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';
import '../URL_CONSTANT.dart';

class SummaryReport extends StatefulWidget {

  final int currentPage;
  SummaryReport({required this.currentPage});

  @override
  _SummaryReportState createState() => _SummaryReportState();
}

class _SummaryReportState extends State<SummaryReport> {


  String locationDataString = '';
  List<dynamic> scrapSummaryData = [];
  final DateFormat formatter = DateFormat('yyyy-MM-dd');


  // State variables
  String? selectedLocationId = '0'; // Default value for "All Location"
  Map<String, String> locationMap = {'All Location': '0'};

  //Variables for user selected values
  DateTime? fromDate;
  DateTime? toDate;


  final searchStrController = TextEditingController();


  //Variables for user details
  String? username = '';
 String uuid = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';

  List<TextSpan> textSpans = [];



  @override
  void initState() {
    super.initState();
    checkLogin();
    fetchLocations();
    // get_scrap_summary();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    searchStrController.dispose();
    super.dispose();
  }

  //Fetching user details from sharedpreferences
  Future<void> checkLogin() async {
     final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    uuid = prefs.getString("uuid")!;
    uuid = prefs.getString("uuid")!;
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
  }

  Future<void> fetchLocations() async {
    try {
      await checkLogin();
      final url = '${URL}get_dropdown';
      final response = await http.post(
        Uri.parse(url),
        body: {
        'user_id': username,
'uuid':uuid,
          'user_pass': password,
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == "1") {
          setState(() {
            // Keep "All Location" as the first option
            locationMap = {'All Location': '0'};
            for (var location in data['location']) {
              locationMap[location['location_name']] = location['id'];
            }
          });
        } else {
          print("Error: No locations found.");
        }
      } else {
        print("Error: Failed to fetch data.");
      }
    } catch (e) {
      print("Error: $e");
    }
  }


  // Fetching API for Search Seal Data
  get_scrap_summary() async {

    print(username);
    print(password);
    print(selectedLocationId);
    print(formatter.format(fromDate!));
    print(formatter.format(toDate!));

    try {
      await checkLogin();
      final response = await http.post(
        Uri.parse('${URL}get_scrap_summary'),
        headers: {"Accept": "application/json"},
        body: {
          // 'uuid': _uuid,
        'user_id': username,
'uuid':uuid,
          'user_pass': password,
          'branch_id':selectedLocationId.toString(),
          'from_date': fromDate != null ? formatter.format(fromDate!) : '',
          'to_date': toDate != null ? formatter.format(toDate!) : '',
          // 'from_date':fromDate != null ? fromDate?.toLocal().toString() : '',
          // 'to_date': toDate != null ? toDate?.toLocal().toString() : '',

          // 'user_id': "Bantu",
          // 'user_pass': "Bantu#123",
          // 'branch_id':"5",
          // 'from_date':"2023-11-30",
          // 'to_date': "2023-12-02",

        },
      );

      // 08/16/2019

      if (response.statusCode == 200) {
        // Parse the API response
        final parsedResponse = jsonDecode(response.body);

        setState(() {
          if (parsedResponse != null && parsedResponse['result'] != null) {
            scrapSummaryData = parsedResponse['result'];
            print("$scrapSummaryData Pooja");
          } else {
            scrapSummaryData = []; // Fallback to an empty list if 'result' is null
            print("Result key is null or missing in API response.");
          }
        });
      } else {
        print('Failed to fetch Seal Summary API. Status code: ${response.statusCode}');
      }

    } catch (e) {
      print('Error: $e');
    }
  }


  Widget buildDynamicTable(List<dynamic> data) {
    if (data.isEmpty) {
      return Text('No Data Available');
    }

    // Group data by material_name
    Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var item in data) {
      String materialName = item['material_name'];
      if (!groupedData.containsKey(materialName)) {
        groupedData[materialName] = [];
      }
      groupedData[materialName]?.add(item);
    }

    // Define table columns
    List<DataColumn> columns = [
      DataColumn(label: Text('Invoice No', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(label: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(label: Text('Unit', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(label: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(label: Text('Truck No', style: TextStyle(fontWeight: FontWeight.bold))),
    ];

    List<Widget> tableWidgets = [];

    groupedData.forEach((materialName, items) {
      // Calculate the total quantity for the current material
      double totalQty = items.fold(0.0, (sum, item) => sum + double.parse(item['qty']));

      // Create rows for the material
      List<DataRow> rows = items.map((item) {
        return DataRow(
          cells: [
            DataCell(Text(item['invoice_no'])),
            DataCell(Text(item['qty'])),
            DataCell(Text(item['unit'])),
            DataCell(Text(item['lifted_rate'])),
            DataCell(Text(item['truck_no'])),
          ],
        );
      }).toList();

      // Add a "Total" row
      rows.add(DataRow(
        color: MaterialStateProperty.resolveWith((states) => Colors.grey.shade300),
        cells: [
          DataCell(Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Text(totalQty.toStringAsFixed(3), style: TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
        ],
      ));

      // Add material title and table to widgets
      tableWidgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          materialName,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ));
      tableWidgets.add(DataTable(
        border: TableBorder.all(color: Colors.grey),
        columns: columns,
        rows: rows,
        headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
      ));
    });

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tableWidgets,
      ),
    );
  }

  Widget buildTableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildDropdown(String label, Map<String, String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: selectedLocationId, // Set the default value
              items: options.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.value, // Return ID
                  child: Text(entry.key), // Display name
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: AppDrawer(currentPage: widget.currentPage),
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Summary Report",
                          style: TextStyle(
                            fontSize: 26, // Slightly larger font size for prominence
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.all(screenWidth * 0.02),

                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SizedBox(height: 16.0),
                      buildDropdown(
                        "Location:",
                        locationMap,
                            (value) {
                          setState(() {
                            selectedLocationId = value;
                            print("Selected Location ID: $selectedLocationId");
                          });
                        },
                      ),
                      SizedBox(height: 10.0),
                      buildFieldWithDatePicker(
                        'From Date:',
                        fromDate,
                            (selectedDate) {
                          setState(() {
                            fromDate = selectedDate;
                          });
                        },
                      ),
                      SizedBox(height: 10.0),
                      buildFieldWithDatePicker(
                        'To Date:',
                        toDate,
                            (selectedEndDate) {
                          setState(() {
                            toDate = selectedEndDate;
                          });
                        },
                      ),
                      SizedBox(height: 24.0), // Increased spacing
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            get_scrap_summary();
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blueGrey[400], // Text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                            ),
                            elevation: 5,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Consistent padding
                          ),
                          child: Text('Get Data'),
                        ),
                      ),
                      // SizedBox(height: 16.0,),
                      // if (fromDate != null && toDate != null)
                      //   Padding(
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: Text(
                      //       'From : (${fromDate!.toLocal().toString().split(' ')[0]})' '  To : '
                      //           '(${toDate!.toLocal().toString().split(' ')[0]})',
                      //       style: TextStyle(fontSize: 18),
                      //     ),
                      //   ),
                      SizedBox(height: 16.0,),
                      if (fromDate != null && toDate != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'From : (${fromDate!.toLocal().toString().split(' ')[0]})' '  To : '
                                '(${toDate!.toLocal().toString().split(' ')[0]})',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      SizedBox(height:16.0),
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: buildDynamicTable(scrapSummaryData)),
                      // If data is still loading, you can return an empty container or other widget
                      Container(),
                      SizedBox(height:16.0),
                      if (scrapSummaryData.isNotEmpty) // Condition to check if the data is not empty
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              _copyToClipboard();
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blueGrey[700],
                            ),
                            child: Text('Copy to Clipboard'),
                          ),
                        ),
                    ],
                    ),
                  ),
                ],
              )
          ),
        ),
      ),
    );
  }

  void _copyToClipboard() {
    // Check if there is data in the table and date range is selected
    if (scrapSummaryData.isNotEmpty && fromDate != null && toDate != null) {
      // Group data by material_name
      Map<String, List<Map<String, dynamic>>> groupedData = {};
      for (var item in scrapSummaryData) {
        String materialName = item['material_name'];
        if (!groupedData.containsKey(materialName)) {
          groupedData[materialName] = [];
        }
        groupedData[materialName]?.add(item);
      }

      // Prepare clipboard content
      StringBuffer clipboardContent = StringBuffer();

      // Format the selected date range
      String formattedFromDate = "${fromDate!.year}-${fromDate!.month.toString().padLeft(2, '0')}-${fromDate!.day.toString().padLeft(2, '0')}";
      String formattedToDate = "${toDate!.year}-${toDate!.month.toString().padLeft(2, '0')}-${toDate!.day.toString().padLeft(2, '0')}";
      clipboardContent.writeln("Date: ($formattedFromDate) to ($formattedToDate)");
      // clipboardContent.writeln("================================");

      // Variables to calculate grand totals
      double grandTotalQty = 0.0;
      // Iterate over the grouped data and write to the clipboard
      double totalNetWT = 0.0;
      int totalSeal = 0;
      int totalVehicle = 0;

      // Process each material group
      groupedData.forEach((materialName, items) {
        clipboardContent.writeln("\n-----------------------------------------------");
        clipboardContent.writeln("$materialName");
        clipboardContent.writeln("-------------------------------------------------");

        // clipboardContent.writeln("Invoice No | Qty   | Unit | Rate | Truck No");
        // clipboardContent.writeln("\n");


        double materialTotalQty = 0.0;

        int counter = 1;  // Initialize a counter for numbering

        for (var item in items) {
          String invoiceNo = item['invoice_no'];
          String qty = item['qty'];
          String unit = item['unit'].isEmpty ? "N/A" : item['unit'];
          String rate = item['lifted_rate'].isEmpty ? "N/A" : item['lifted_rate'];
          String truckNo = item['truck_no'];

          // Add numbering to the item display
          clipboardContent.writeln("$counter. Invoice No : $invoiceNo | Qty : $qty "
              "| Unit : $unit | Rate : $rate | Truck No : $truckNo\n");

          // Increase counter for next item
          counter++;

          // Add the quantity to the total
          materialTotalQty += double.parse(qty);
        }


        // Add total for the material group
        clipboardContent.writeln("~~~~~~~~~~~~~~~~~~~~~~");
        // clipboardContent.writeln("\n");
        clipboardContent.writeln("                    Total Qty: ${materialTotalQty.toStringAsFixed(3)}");
        // clipboardContent.writeln("________________________________________");

        grandTotalQty += materialTotalQty;
      });

      // Add grand total
      clipboardContent.writeln("\n=============================");
      clipboardContent.writeln("Grand Total Qty: ${grandTotalQty.toStringAsFixed(3)}");
      clipboardContent.writeln("=============================");

      // Copy the content to clipboard
      FlutterClipboard.copy(clipboardContent.toString()).then((value) {
        Fluttertoast.showToast(
          msg: 'Table data copied to clipboard',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      });
    } else {
      // Show a toast if no data or date range is available
      Fluttertoast.showToast(
        msg: 'No data or date range available to copy',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Widget buildFieldWithDatePicker(String label, DateTime? selectedDate,
      void Function(DateTime?) onDateChanged,) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final newSelectedDate = await showDatePicker(
                        context: context, // Make sure you have access to the context
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (newSelectedDate != null) {
                        onDateChanged(newSelectedDate);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),


                      ),
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDate != null
                                ? '${selectedDate.toLocal()}'.split(' ')[0]
                                : 'Select Date',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            size: 19.0, // Adjust the size as needed
                          ), // Calendar icon
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget buildTextField(
      String labelText,
      String? text,
      void Function(String?) onChanged,
      ) {
    return Row(
      children: [
        Icon(
          Icons.directions_car,
          color: Colors.blue.shade900,
          size: 30.0, // Icon size
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: Text(
            labelText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: TextFormField(
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Enter Vehicle No',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Colors.blue.shade900, // Border color
                ),
              ),
            ),
            style: TextStyle(
              fontSize: 18,
              color: Colors.blue.shade900, // Text input color
            ),
          ),
        ),
      ],
    );
  }
}


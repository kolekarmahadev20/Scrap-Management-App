import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:clipboard/clipboard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';

import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';
import '../URL_CONSTANT.dart';

class SummaryReport extends StatefulWidget {
  @override
  _SummaryReportState createState() => _SummaryReportState();
}

class _SummaryReportState extends State<SummaryReport> {

  List<List<dynamic>> locationLists = [];

  String locationDataString = '';
  List<dynamic> sealSummaryData = [];


  //Variables for user selected values
  String? selectedLocation;
  DateTime? fromDate;
  DateTime? toDate;


  final searchStrController = TextEditingController();

  //Variables for user details
  bool _isloggedin = true;
  String _id = '';
  String _username = '';
  String _full_name = '';
  String _email = '';
  String userImageUrl = '';
  String _user_type = '';
  String _password = '';
  String _uuid = '';

  // List to store location names
  List<String> locations = [];

  List<TextSpan> textSpans = [];
  // List to store location_id
  List<String> locationIds = [];


  @override
  void initState() {
    super.initState();
    _getUserDetails();
    fetchdropdownData();
    get_seal_summary();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    searchStrController.dispose();
    super.dispose();
  }

  //Fetching user details from sharedpreferences
  _getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isloggedin = prefs.getBool("loggedin")!;
      _id = prefs.getString('id')!;
      _username = prefs.getString('username')!;
      _full_name = prefs.getString('full_name')!;
      _email = prefs.getString('email')!;
      _user_type = prefs.getString('user_type') ?? '';
      _password = prefs.getString('password')??'';
      _uuid= prefs.getString('uuid')??'';

    });

    if (kDebugMode) {
      //print("is logged in$_isloggedin");
    }
    if (_isloggedin == false) {
      // ignore: use_build_context_synchronously

    }
  }

  //Fetching API for Dropdown
  fetchdropdownData() async {
    await _getUserDetails();
    try {
      final response = await http.post(
        Uri.parse('$URL/Mobile_flutter_api/get_dropdown_data'),
        headers: {"Accept": "application/json"},
        body: {
          'uuid': _uuid,
          'user_id': _username,
          'password': _password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        //Fetching API for location
        if (data["status"] == "1") {
          if (data.containsKey("location")) {
            updateLocationData(data["location"]);
          } else {
            print('No "location" data found in the response');
          }

          if (data['material'] != null && data['material'].isNotEmpty) {
            List<dynamic> materials = data['material'];
            String materialNames = '';

          }
          setState(() {
            selectedLocation;
            // a = material['material_name'].toString();
          });

          setState(() {
            selectedLocation;
          });

        } else {
          print('Status is not 1 in the response');
        }
      } else {
        print('Failed to fetch Dropdown API. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void updateLocationData(List<dynamic> locationDataList) {
    locations.clear();
    locationIds.clear();

    for (var locationData in locationDataList) {
      String locationName = locationData["location_name"].toString();
      String locationId = locationData["location_id"].toString();

      locations.add(locationName);
      locationIds.add(locationId);
    }
  }

  // Define a function to get the location_id for the selected location name
  String? getSelectedLocationId() {
    if (selectedLocation != null && selectedLocation != null) {
      int selectedIndex = locations.indexOf(selectedLocation!);
      if (selectedIndex != -1 && selectedIndex < locationIds.length) {
        return locationIds[selectedIndex];
      }
    }
    return null;
  }

  //Fetching API for Search Seal Data
  get_seal_summary({String? plantId, String? locationId,String? materialId, String? vehicleNumber })
  async {
    try {
      await _getUserDetails();
      final response = await http.post(
        Uri.parse('$URL/Mobile_flutter_api/get_seal_summary'),
        headers: {"Accept": "application/json"},
        body: {
          'uuid': _uuid,
          'user_id': _username,
          'password': _password,
          'location_id':locationId,
          'report_date_from':fromDate != null ? fromDate?.toLocal().toString() : '',
          // '2019-08-18',
          'report_date_to': toDate != null ? toDate?.toLocal().toString() : '',
          // '2019-08-18',
        },
      );

      // 08/16/2019

      if (response.statusCode == 200) {

        setState(() {
          sealSummaryData = json.decode(response.body); // Store fetched data

          print(sealSummaryData);
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
      return Text('');
    }

    // Assuming there is at least one item in the list
    var firstItem = data[0];

    // Check if the first item has a dynamic key (the key for your data)
    if (firstItem.isNotEmpty) {
      var dynamicKey = firstItem.keys.first;

      // Extract the keys dynamically from the first item's dynamic key
      var keys = (firstItem[dynamicKey][0] as Map<String, dynamic>).keys.toList();

      // Create a list of DataColumn widgets with custom names
      List<DataColumn> customColumns = [
        DataColumn(label: Text('Material',style: TextStyle(fontSize: 16.0 , fontWeight: FontWeight.bold),)),
        ...keys.where((key) => key != 'location_id').map((key) => DataColumn(label: Text(_getCustomColumnName(key) ,
          style: TextStyle(fontSize: 16.0 , fontWeight: FontWeight.bold),))).toList(),
      ];

      // Calculate totals
      double totalNetWT = 0.0;
      int totalSeal = 0;
      int totalVehicle = 0;

      // Create DataRow widgets for each item
      List<DataRow> dataRows = firstItem[dynamicKey].map<DataRow>((item) {
        // Update totals
        totalNetWT += double.parse(item['net_weight']);
        totalSeal += int.parse(item['total_seal']);
        totalVehicle += int.parse(item['no_of_trucks']);

        // Create cells for each key-value pair
        List<DataCell> cells = [
          DataCell(Text(dynamicKey)),
          ...keys.where((key) => key != 'location_id').map<DataCell>((key) {
            return DataCell(Text(item[key].toString()));
          }).toList(),
        ];

        return DataRow(cells: cells);
      }).toList();

      // Add a row for totals
      dataRows.add(DataRow(
        color: MaterialStateColor.resolveWith((states) => Colors.blue.shade200), // Set background color for the entire DataRow
        cells: [
          DataCell(Text('Grand Total',style: TextStyle(fontSize: 16.0 , fontWeight: FontWeight.bold),)),
          DataCell(Text(totalNetWT.toStringAsFixed(3),style: TextStyle(fontSize: 16.0 , fontWeight: FontWeight.bold),)),
          DataCell(Text(totalSeal.toString(),style: TextStyle(fontSize: 16.0 , fontWeight: FontWeight.bold),)),
          DataCell(Text(totalVehicle.toString(),style: TextStyle(fontSize: 16.0 , fontWeight: FontWeight.bold),)),
          DataCell(Text('')), // Placeholder for 'Location'
          DataCell(Text('')), // Placeholder for 'Plant'
        ],
      ));

      // Return the DataTable
      return DataTable(
        border: TableBorder.all(color: Colors.grey, width: 1.0),
        headingRowColor: MaterialStateProperty.all(Colors.grey.shade300), // Set background color for the header row
        columns: customColumns,
        dataRowHeight: 50, // Adjust the row height as needed
        columnSpacing: 10, // Set the column spacing
        horizontalMargin: 10, // Set the horizontal margin
        rows: dataRows,
      );

    } else {
      return Text('Data Not Found');
    }
  }

  String _getCustomColumnName(String originalName) {
    // Map original column names to custom names
    Map<String, String> customNames = {
      'net_weight':'NetWT',
      'total_seal':'TotalSeal',
      'no_of_trucks':'Vehicle',
      'location_name':'Location',
      // 'location_id': 'Id',
      'plant_name':'Plant',
    };

    // Return the custom name if available, otherwise use the original name
    return customNames[originalName] ?? originalName;
  }

  Future<bool> _onWillPop() async {
    bool exit = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    );

    if (exit != null && exit) {
      SystemNavigator.pop(); // Exit the app
    }

    return exit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    String? selectedLocationId = getSelectedLocationId();

    return Scaffold(
      drawer: AppDrawer(currentPage: 0),
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.circle_notifications,
                      color: Colors.blue.shade900,
                      size: 35, // Adjust the icon size as needed
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Summary Report',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    child: Padding(padding: EdgeInsets.all(screenWidth * 0.02),

                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        SizedBox(height: 16.0),
                        buildDropdown(
                          " All Location",
                          "Location:",
                          locations,
                          selectedLocation,
                              (value) {
                            setState(() {
                              selectedLocation = value;
                            });
                          },
                        ),
                        SizedBox(height: 16.0),
                        buildFieldWithDatePicker(
                          'From Date:',
                          fromDate,
                              (selectedDate) {
                            setState(() {
                              fromDate = selectedDate;
                            });
                          },
                        ),
                        SizedBox(height: 16.0),
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
                              get_seal_summary
                                (
                                locationId: selectedLocationId,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, // Set button color
                            ),
                            child: Text('Get Data'),
                          ),
                        ),
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
                            child: buildDynamicTable(sealSummaryData)),
                        // If data is still loading, you can return an empty container or other widget
                        Container(),
                        SizedBox(height:16.0),
                        if (sealSummaryData.isNotEmpty) // Condition to check if the data is not empty
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                _copyToClipboard();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: Text('Copy to Clipboard'),
                            ),
                          ),
                      ],
                      ),
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
    // Check if there is data in the table
    if (sealSummaryData.isNotEmpty && fromDate != null && toDate != null) {
      // Convert the table data to a string
      String tableData = _getTableDataAsString(sealSummaryData);

      // Calculate totals
      double totalNetWT = 0.0;
      int totalSeal = 0;
      int totalVehicle = 0;

      for (var item in sealSummaryData) {
        var dynamicKey = item.keys.first;
        for (var material in item[dynamicKey]) {
          totalNetWT += double.parse(material['net_weight']);
          totalSeal += int.parse(material['total_seal']);
          totalVehicle += int.parse(material['no_of_trucks']);
        }
      }

      // Format the selected date range
      String dateRange = 'Date: (${fromDate!.day}-${fromDate!.month}-${fromDate!.year}) '
          'to (${toDate!.day}-${toDate!.month}-${toDate!.year})\n\n';

      // Combine the date range and table data
      String clipboardData = '$dateRange==============\n$tableData\n\n'
          '=============\nGrand Total: NetWT: ${totalNetWT.toStringAsFixed(3)}, '
          'TotalSeal: $totalSeal, Vehicle: $totalVehicle\n=============';

      // Copy the data to the clipboard
      FlutterClipboard.copy(clipboardData).then((value) {
        // Show a toast message indicating that the data has been copied
        Fluttertoast.showToast(
          msg: 'Table data copied to clipboard',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      });
    } else {
      // If there is no data or date range selected, show a toast message
      Fluttertoast.showToast(
        msg: 'No data or date range available to copy',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }





  // Function to convert table data to a formatted string
  // Function to convert table data to a formatted string
  String _getTableDataAsString(List<dynamic> data) {
    if (data.isEmpty) {
      return 'No data available';
    }

    // Assuming there is at least one item in the list
    var firstItem = data[0];

    // Check if the first item has a dynamic key (the key for your data)
    if (firstItem.isNotEmpty) {
      var dynamicKey = firstItem.keys.first;

      // Extract the keys dynamically from the first item's dynamic key
      var keys = (firstItem[dynamicKey][0] as Map<String, dynamic>).keys.toList();

      // Data rows
      var dataRows = data.expand((item) {
        var materialName = item.keys.first;
        return item[materialName].map((material) {
          var formattedMaterialName = materialName.toUpperCase(); // Capitalize material name
          var rowData = [
            // 'Date: (${fromDate!.day}-${fromDate!.month}-${fromDate!.year}) to (${toDate!.day}-${toDate!.month}-${toDate!.year})',
            // '',
            // '==============',
            formattedMaterialName,
            '------------------------',
            ...keys.where((key) => key != 'location_id').map((key) => '$key: ${material[key]}')
          ];
          return rowData.join('\n');
        });
      }).toList();

      // Calculate totals
      double totalNetWT = 0.0;
      int totalSeal = 0;
      int totalVehicle = 0;

      // Iterate through data to calculate totals
      firstItem[dynamicKey].forEach((item) {
        totalNetWT += double.parse(item['net_weight']);
        totalSeal += int.parse(item['total_seal']);
        totalVehicle += int.parse(item['no_of_trucks']);
      });

      // Add totals to the data rows
      // dataRows.add('=============',
      //     '\nGrand Total: NetWT: ${totalNetWT.toStringAsFixed(3)}, TotalSeal: $totalSeal, Vehicle: $totalVehicle',
      //     '=============');

      // Combine all data rows into a single string
      return dataRows.join('\n');
    } else {
      return 'No Data Found..';
    }
  }



  Widget buildDropdown(
      String hint,
      String labelText,
      List<String> items,
      String? selectedItem,
      void Function(String?) onChanged,
      ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            labelText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: Container(
            height: 30,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border.all(
                color: Colors.grey.shade600,
                width: 1.0,
              ),
            ),
            child: Center(
              child: DropdownButtonFormField<String>(
                value: selectedItem,
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: SizedBox(
                      height: 40,
                      child: Center(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
                isExpanded: true,
                decoration: InputDecoration.collapsed(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.black),
                ),
                selectedItemBuilder: (BuildContext context) {
                  return items.map<Widget>((String item) {
                    return Center(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList();
                },
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildFieldWithDatePicker(String label,
      DateTime? selectedDate,
      void Function(DateTime?) onDateChanged,) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
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
                    ),
                    padding: EdgeInsets.all(8.0),
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


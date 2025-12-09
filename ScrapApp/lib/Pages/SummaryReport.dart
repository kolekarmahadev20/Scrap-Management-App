import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:scrapapp/URL_CONSTANT.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class Summary_Report extends StatefulWidget {
  final int currentPage;
  Summary_Report({required this.currentPage});

  @override
  _Summary_ReportState createState() => _Summary_ReportState();
}

class _Summary_ReportState extends State<Summary_Report> {
  // Variables for user details
  String? username = '';
  String uuid = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';

  DateTime? fromDate;
  DateTime? toDate;

  List<dynamic> searchResults = [];
  bool isLoading = false;

  // Variables for selected dropdown values
  String? selectedVendorType;
  String? selectedPlantName;
  String? selectedBuyer;
  String? selectedMaterial;

  // Data for dropdowns
  Map<String, String> VendorType = {};
  Map<String, String> PlantName = {};
  Map<String, String> Buyer = {};
  Map<String, String> Material = {};

  List<Map<String, dynamic>> scrapData = [];

  TextEditingController vendorController = TextEditingController();
  TextEditingController plantController = TextEditingController();
  TextEditingController buyerController = TextEditingController();
  TextEditingController materialController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkLogin();
    fetchDropdownData();
    // fetchScrapData();
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

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Function to fetch data from the API
  Future<void> fetchScrapData() async {
    setState(() {
      isLoading = true;
    });

    print('selectedVendorType');
    print(selectedPlantName);

    String formattedFromDate = DateFormat('yyyy-MM-dd').format(fromDate!);
    String formattedToDate = DateFormat('yyyy-MM-dd').format(toDate!);


    await checkLogin();
    final response = await http.post(
      Uri.parse('${URL}search_scrap_data'),
      headers: {"Accept": "application/json"},
      body: {
        'user_id': username,
        'uuid':uuid,
        'user_pass': password,
        // 'vendor_id':'6',
        // 'plant_id':'4',
        // 'buyer_id':'2',
        // 'mat_id':'393',
        // 'from_date':'2025-03-01',
        // 'to_date':'2025-04-01',

        // if(selectedPlantName!=null && selectedPlantName !='Select')
        //   "plant_id": selectedPlantName.toString()?? '',

        "plant_id": (selectedPlantName != null && selectedPlantName != 'All Select')
            ? selectedPlantName.toString()
            : '',


        "from_date": formattedFromDate,
        "to_date": formattedToDate,


      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      List<Map<String, dynamic>> fetchedData = [];

      if (responseData != null && responseData is Map<String, dynamic>) {
        responseData.forEach((materialName, items) {
          if (items is List) {
            for (var item in items) {
              fetchedData.add({
                'material': item['material'],
                'net_weight': item['net_weight'],
                'total_amount': item['total_amount'],
                'vehicle_no': item['vehicle_no'],
                'location': item['location'],
                'rate': item['rate'],
                'vendor_name': item['vendor_name'],  // Add this
                'bidder_name': item['bidder_name'],  // Add this
              });
            }
          }
        });
      }


      setState(() {
        scrapData = fetchedData;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Handle error
      print('Failed to load data');
    }
  }

  Widget buildDynamicTable(List<dynamic> data) {
    if (data.isEmpty) {
      return Text('No Data Available');
    }

    // Group data by material name (in your case, it's all 'BRASS 1')
    Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var item in data) {
      String materialName = item['material']; // Adjusted to 'material'
      if (!groupedData.containsKey(materialName)) {
        groupedData[materialName] = [];
      }
      groupedData[materialName]?.add(item);
    }

    // Define table columns
    List<DataColumn> columns = [
      DataColumn(label: Text('Material', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(label: Text('Vehicle No', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(label: Text('Location', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(label: Text('Net Weight', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(label: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(label: Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold))),
    ];

    List<Widget> tableWidgets = [];

    groupedData.forEach((materialName, items) {
      // Initialize totals for net weight, total amount, and rate
      double totalNetWeight = 0.0;
      double totalAmount = 0.0;
      double totalRate = 0.0;

      // Create rows for the material and calculate totals
      List<DataRow> rows = items.map((item) {
        totalNetWeight += double.parse(item['net_weight']);

        totalAmount += (item['total_amount'] is double)
            ? item['total_amount']
            : double.tryParse(item['total_amount'].toString()) ?? 0.0;

        totalRate += (item['rate'] is double)
            ? item['rate']
            : double.tryParse(item['rate'].toString()) ?? 0.0;


        return DataRow(
          cells: [
            DataCell(Text(item['material'])),
            DataCell(Text(item['vehicle_no']?.toUpperCase() ?? '')),
            DataCell(Text(item['location'])),
            DataCell(Text(item['net_weight'])),
            DataCell(Text(item['rate'].toString())),
            DataCell(Text(item['total_amount'].toString())),
          ],
        );
      }).toList();

      // Add a "Total" row
      rows.add(DataRow(
        color: MaterialStateProperty.resolveWith((states) => Colors.grey.shade300),
        cells: [
          DataCell(Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Text('')), // Empty cells for Vehicle No and Location
          DataCell(Text('')),
          DataCell(Text(totalNetWeight.toStringAsFixed(3), style: TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Text(totalRate.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Text(totalAmount.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold))),

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


  void _copyToClipboard() {
    if (scrapData.isNotEmpty && fromDate != null && toDate != null) {
      Map<String, List<Map<String, dynamic>>> groupedData = {};

      for (var item in scrapData) {
        String materialName = item['material'];
        if (!groupedData.containsKey(materialName)) {
          groupedData[materialName] = [];
        }
        groupedData[materialName]?.add(item);
      }

      // ✅ Declare clipboardContent here
      StringBuffer clipboardContent = StringBuffer();

      // ✅ Format the selected date range
      String formattedFromDate = DateFormat('yyyy-MM-dd').format(fromDate!);
      String formattedToDate = DateFormat('yyyy-MM-dd').format(toDate!);
      clipboardContent.writeln("Date: ($formattedFromDate) to ($formattedToDate)");

      double grandTotalQty = 0.0;

      groupedData.forEach((materialName, items) {
        String locationName = items.isNotEmpty ? items.first['location'] : "Unknown";

        double materialTotalQty = 0.0;

        // ✅ Declare counter before the loop
        int counter = 1;

        for (var item in items) {
          String material = item['material'].toString().toUpperCase();
          String netWeight = item['net_weight'];
          String totalAmount = item['total_amount'].toString();
          String vehicleNo = item['vehicle_no'].toString().toUpperCase();
          String location = item['location'].toString().toUpperCase();
          String rate = item['rate'];
          String vendorName = (item['vendor_name'] ?? 'UNKNOWN VENDOR').toString().toUpperCase();
          String bidderName = (item['bidder_name'] ?? 'UNKNOWN BIDDER').toString().toUpperCase();

          clipboardContent.writeln("\n-----------------------------------------------");
          clipboardContent.writeln("Vendor Name: $vendorName");
          clipboardContent.writeln("Buyer Name: $bidderName");
          clipboardContent.writeln("Location: $locationName");

          clipboardContent.writeln("-------------------------------------------------");


          // ✅ Include vendor_name and bidder_name
          clipboardContent.writeln(
              "$counter. Material: $material | Net Weight: $netWeight | Total Amount: $totalAmount | "
                  "Vehicle No: $vehicleNo | Location: $location | Rate: $rate "
          );

          counter++;
          materialTotalQty += double.parse(netWeight);
        }

        clipboardContent.writeln("~~~~~~~~~~~~~~~~~~~~~~");
        clipboardContent.writeln("Total Net Weight: ${materialTotalQty.toStringAsFixed(3)}");

        grandTotalQty += materialTotalQty;
      });

      clipboardContent.writeln("\n=============================");
      clipboardContent.writeln("Grand Total Net Weight: ${grandTotalQty.toStringAsFixed(3)}");
      clipboardContent.writeln("=============================");

      // ✅ Debugging: Print to console before copying
      print(clipboardContent.toString());

      // ✅ Copy to clipboard
      FlutterClipboard.copy(clipboardContent.toString()).then((value) {
        Fluttertoast.showToast(
          msg: 'Table data copied to clipboard',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      });
    } else {
      Fluttertoast.showToast(
        msg: 'No data or date range available to copy',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }



  // Fetch dropdown data from the API
  Future<void> fetchDropdownData() async {
    try {
      await checkLogin();
      final response = await http.post(
        Uri.parse('${URL}get_dropdown'),
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid': uuid,
          'user_pass': password,
        },
      );

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);

          setState(() {
            setState(() {
              PlantName = {
                'All Location': 'All Location',
                ...{
                  for (var item in data['plant'])
                    item['plant_name']: item['plant_id'] ?? '0'
                }
              };
            });

            // Material
            // Material = {
            //   'Select': 'Select',
            //   ...{
            //     for (var item in data['material_list'] ?? [])
            //       item['material_name'] ?? 'Unknown':
            //       (item['material_id'] ?? '0').toString()
            //   }
            // };

            // Vendor
            // VendorType = {
            //   'Select': 'Select',
            //   ...{
            //     for (var item in data['vendor_list'] ?? [])
            //       item['vendor_name'] ?? 'Unknown':
            //       (item['vendor_id'] ?? '0').toString()
            //   }
            // };

            // Buyer
            // Buyer = {
            //   'Select': 'Select',
            //   ...{
            //     for (var item in data['buyer_list'] ?? [])
            //       item['buyer_name'] ?? 'Unknown':
            //       (item['buyer_id'] ?? '0').toString()
            //   }
            // };
          });
        } catch (e) {
          print("Error decoding JSON: $e");
        }
      } else {
        print(
            'Failed to fetch dropdown data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  // Fetch plant data based on the selected vendor
  Future<void> fetchPlantData(String vendorId) async {
    try {
      await checkLogin();
      final response = await http.post(
        Uri.parse('${URL}vendor_wise_plant'),
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid': uuid,
          'user_pass': password,
          'vendor_id': vendorId,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // print(data);

        // Update the PlantName dropdown data based on the response
        setState(() {
          PlantName = {
            'Select': 'Select',
            ...{
              for (var item in data['plant_list'])
                item['branch_name']: item['branch_id'] ?? '0'
            }
          };
        });
      } else {
        print(
            'Failed to fetch plant data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching plant data: $e');
    }
  }

  Future<void> fetchBuyerData(String plantId) async {
    try {
      await checkLogin();
      final response = await http.post(
        Uri.parse('${URL}plant_wise_bidders'),
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid': uuid,
          'user_pass': password,
          'plant_id': plantId,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // print(data);

        // Update the PlantName dropdown data based on the response
        setState(() {
          Buyer = {
            'Select': 'Select',
            ...{
              for (var item in data['bidder_list'] ?? [])
                item['bidder_name'] ?? 'Unknown':
                (item['buyer_id'] ?? '0').toString()
            }
          };
        });
      } else {
        print(
            'Failed to fetch plant data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching plant data: $e');
    }
  }

  Future<void> fetchMaterialData(String bidderId) async {
    try {
      await checkLogin();
      final response = await http.post(
        Uri.parse('${URL}bidder_wise_material'),
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid': uuid,
          'user_pass': password,
          'bidder_id': bidderId,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // print(data);

        // Update the PlantName dropdown data based on the response
        setState(() {
          Material = {
            'Select': 'Select',
            ...{
              for (var item in data['material_list'] ?? [])
                item['description'] ?? 'Unknown': (item['id'] ?? '0').toString()
            }
          };
        });
      } else {
        print(
            'Failed to fetch plant data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching plant data: $e');
    }
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
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Summary Report",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // buildDropdown(
                      //     'Select Vendor', VendorType, vendorController,
                      //         (value) {
                      //       setState(() {
                      //         selectedVendorType = value;
                      //         selectedPlantName = null;
                      //         plantController.clear();
                      //       });
                      //       if (value != null) {
                      //         fetchPlantData(value);
                      //       }
                      //     }),

                      buildDropdown('Location', PlantName, plantController,
                              (value) {
                            setState(() {
                              selectedPlantName = value;
                              selectedBuyer = null;
                              buyerController.clear();
                            });
                            if (value != null) {
                              fetchBuyerData(value);
                            }
                          }),

                      // buildDropdown('Buyer', Buyer, buyerController, (value) {
                      //   setState(() {
                      //     selectedBuyer = value;
                      //     selectedMaterial = null;
                      //     materialController.clear();
                      //   });
                      //   if (value != null) {
                      //     fetchMaterialData(value);
                      //   }
                      // }),
                      //
                      // buildDropdown('Material', Material, materialController,
                      //         (value) {
                      //       setState(() {
                      //         selectedMaterial = value;
                      //       });
                      //     }),

                      buildFieldWithDatePicker(
                        'From Date',
                        fromDate,
                            (selectedDate) {
                          setState(() {
                            fromDate = selectedDate;
                          });
                        },
                      ),
                      buildFieldWithDatePicker(
                        'To Date',
                        toDate,
                            (selectedEndDate) {
                          setState(() {
                            toDate = selectedEndDate;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            fetchScrapData();
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blueGrey[400], // Text color
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12), // Rounded corners
                            ),
                            elevation: 5,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8), // Consistent padding
                          ),
                          child: Text("Get Data"),
                        ),
                      ),
                      const SizedBox(
                          height: 20), // Spacing between button and results
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: buildDynamicTable(scrapData)),
                      // If data is still loading, you can return an empty container or other widget
                      Container(
                        height: 20,
                      ),
                      if (scrapData.isNotEmpty) // Condition to check if the data is not empty
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
                      Container(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDropdown(
      String label,
      Map<String, String> options,
      TextEditingController controller,
      ValueChanged<String?> onChanged,
      ) {
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
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TypeAheadFormField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: controller,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Select', // Adds "Select" as placeholder
                      suffixIcon: controller.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.clear,
                            size: 18), // Reduce icon size
                        onPressed: () {
                          setState(() {
                            controller.clear();
                            onChanged(null); // Clear selected value
                          });
                        },
                      )
                          : null,
                    ),
                  ),
                  suggestionsCallback: (pattern) {
                    return options.keys
                        .where((key) =>
                        key.toLowerCase().contains(pattern.toLowerCase()))
                        .toList();
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      controller.text = suggestion;
                      onChanged(options[suggestion]);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFieldWithDatePicker(
      String label,
      DateTime? selectedDate,
      void Function(DateTime?) onDateChanged,
      ) {
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
                        context:
                        context, // Make sure you have access to the context
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
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
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
}
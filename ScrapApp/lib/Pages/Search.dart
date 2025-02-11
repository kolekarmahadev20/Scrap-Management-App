import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scrapapp/URL_CONSTANT.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';

class Search extends StatefulWidget {
  final int currentPage;
  Search({required this.currentPage});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
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

  @override
  void initState() {
    super.initState();
    checkLogin();
    fetchDropdownData();
    // fetchData();
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

  Future<void> fetchData() async {
    try {
      print('selectedVendorType');

      print(selectedVendorType);
      print(selectedPlantName);
      print(selectedBuyer);
      print(selectedMaterial);

      await checkLogin();
      final response = await http.post(
        Uri.parse('${URL}search_scrap_data'),
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid':uuid,
          'user_pass': password,
          "vendor_id": selectedVendorType.toString()?? '',
          if(selectedPlantName!=null && selectedPlantName !='Select')
           "plant_id": selectedPlantName.toString()?? '',
          if(selectedBuyer!=null&& selectedBuyer !='Select')
            "buyer_id": selectedBuyer?.toString() ?? '', // Use empty string if null
          if(selectedMaterial!=null&& selectedMaterial !='Select')
            "mat_id": selectedMaterial?.toString() ?? '', // Use empty string if null
          "from_date": fromDate.toString(),
          "to_date": toDate.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        print("sdgk;lrk");
        if (data['status'] == "1") {
          setState(() {
            searchResults = data['search_result'];
          });
        } else {
          showError("No data found.");
        }
      } else {
        showError("Error: ${response.statusCode}");
      }
    } catch (e) {
      showError("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
'uuid':uuid,
          'user_pass': password,
        },
      );

      // Check if the response is in JSON format
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          // print(data);

          // Update dropdown data
          setState(() {
            // Location (PlantName)
            // PlantName = {
            //   'Select': 'Select',
            // };

            // Material
            Material = {
              'Select': 'Select',
              ...{
                for (var item in data['material_list'])
                  item['material_name']: item['material_id'] ?? '0'
              }
            };

            // Vendor
            VendorType = {
              'Select': 'Select',
              ...{
                for (var item in data['vendor_list'])
                  item['vendor_name']: item['vendor_id'] ?? '0'
              }
            };

            // Buyer
            Buyer = {
              'Select': 'Select',
              ...{
                for (var item in data['buyer_list'])
                  item['buyer_name']: item['buyer_id'] ?? '0'
              }
            };
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
'uuid':uuid,
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
                        "Search Scrap",
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
                      buildDropdown('Select Vendor', VendorType, (value) {
                        setState(() {
                          selectedVendorType = value;
                          selectedPlantName = null; // Reset plant selection
                        });
                        if (value != null && value != 'Select') {
                          fetchPlantData(
                              value); // Fetch plant data for selected vendor
                        }
                      }),

                      // Plant Dropdown
                      buildDropdown('Select Plant', PlantName, (value) {
                        setState(() {
                          selectedPlantName = value;
                        });
                      }),

                      buildDropdown("Buyer", Buyer, (value) {
                        setState(() {
                          selectedBuyer = value;
                        });
                      }),
                      buildDropdown("Material", Material, (value) {
                        setState(() {
                          selectedMaterial = value;
                        });
                      }),
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
                            fetchData();
                            // Add action to Get Data
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
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text("Get Data"),
                        ),
                      ),
                      const SizedBox(
                          height: 20), // Spacing between button and results
                      searchResults.isEmpty
                          ? const Center(
                              child: Text("No Data Available"),
                            )
                          : ListView.builder(
                              shrinkWrap:
                                  true, // Ensures it doesn't take infinite space in SingleChildScrollView
                              physics:
                                  const NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
                              itemCount: searchResults.length,
                              itemBuilder: (context, index) {
                                final item = searchResults[index];
                                // return Card(
                                //   elevation: 4,
                                //   margin: const EdgeInsets.symmetric(
                                //       horizontal: 16, vertical: 8),
                                //   shape: RoundedRectangleBorder(
                                //     borderRadius: BorderRadius.circular(10),
                                //   ),
                                //   child: Padding(
                                //     padding: const EdgeInsets.all(16.0),
                                //     child: Column(
                                //       crossAxisAlignment:
                                //           CrossAxisAlignment.start,
                                //       children: [
                                //         Text(
                                //           "ID: ${item['id']}",
                                //           style: const TextStyle(
                                //               fontWeight: FontWeight.bold),
                                //         ),
                                //         Text("Vendor ID: ${item['vendor_id']}"),
                                //         Text("Lot ID: ${item['lot_id']}"),
                                //         Text(
                                //             "Auction ID: ${item['auction_id']}"),
                                //         Text(
                                //             "Description: ${item['description']}"),
                                //         Text(
                                //             "Auction Date: ${item['auction_date']}"),
                                //         Text(
                                //             "Created By: ${item['created_by']}"),
                                //       ],
                                //     ),
                                //   ),
                                // );
                               return Column(
                                 children: [
                                   Card(
                                     color: Colors.blueGrey[500],
                                     child: Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                         Expanded(
                                           child: Padding(
                                             padding: const EdgeInsets.all(8.0),
                                             child: Container(
                                               child: Text(
                                                 'Lot Id : ${item['lot_id']}'
                                                     // ' ${item['sale_order_code']}'
                                                 ,
                                                 style: TextStyle(
                                                   fontWeight: FontWeight.bold,
                                                   fontSize: 17,
                                                   color: Colors.white,
                                                 ),
                                               ),
                                             ),
                                           ),
                                         ),
                                       ],
                                     ),
                                   ),

                                   Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Table(
                                        columnWidths: {
                                          0: FixedColumnWidth(150),
                                        },
                                        children: [
                                          buildTableRow('Sale Order Code','${item['sale_order_code']}', 0),

                                          // buildTableRows(
                                          //   ['Lot Id', 'Sale Order Code'],
                                          //   ['${item['lot_id']}', '${item['sale_order_code']}'], 0,
                                          // ),
                                          // buildTableRow('Contact', vendor.phone, 1),
                                          buildTableRows(
                                            ['Auction ID', 'Auction Date'],
                                            ['${item['auction_id']}', '${item['auction_date']}'],
                                            1,
                                          ),
                                          buildTableRows(
                                            ['Freezed', 'Approval Status'],
                                            ['${item['freezed']}', '${item['approval_status']}'],
                                            0,
                                          ),
                                          buildTableRows(
                                            ['Payment Type', 'Lifting Type'],
                                            ['${item['payment_type']}', '${item['lifting_type']}'],
                                            1,
                                          ),
                                          buildTableRows(
                                            ['More Quantity Lifting', 'Cancel Order'],
                                            ['${item['more_quantity_lifting']}', '${item['cancle_order']}'],
                                            0,
                                          ),
                                          buildTableRow('Description','${item['description']}', 1),
                                          // buildTableRow('User by', vendor.contactPerson, 0),
                                        ],
                                      ),
                                    ),
                                 ],
                               );

                              },
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

  TableRow buildTableRows(
      List<String> labels, List<String?> values, int index) {
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

  TableRow buildTableRow(String label, String? value, int index) {
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

  Widget buildDropdown(String label, Map<String, String> options,
      ValueChanged<String?> onChanged) {
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
              value: options.isNotEmpty
                  ? options.keys.first
                  : null, // Check for empty options
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

import 'package:flutter/material.dart';
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
  String? password = '';
  String? loginType = '';
  String? userType = '';

  DateTime? fromDate;
  DateTime? toDate;

  // Variables for selected dropdown values
  String? selectedVendorType;
  String? selectedPlantName;
  String? selectedBuyer;
  String? selectedMaterial;

  // Data for dropdowns
  Map<String, String> VendorType = {
    'Select': 'Select',
    'Received Payment': 'P',
    'Received EMD': 'E',
    'Received CMD': 'C',
  };

  Map<String, String> PlantName = {
    'Select': 'Select',
    'Plant 1': 'P1',
    'Plant 2': 'P2',
    'Plant 3': 'P3',
  };

  Map<String, String> Buyer = {
    'Select': 'Select',
    'Buyer 1': 'B1',
    'Buyer 2': 'B2',
    'Buyer 3': 'B3',
  };

  Map<String, String> Material = {
    'Select': 'Select',
    'Steel': 'S',
    'Copper': 'C',
    'Aluminum': 'A',
  };

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: AppDrawer(currentPage: 0),
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
                          fontSize: 26, // Slightly larger font size for prominence
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
                      buildDropdownPayment("Vendor", VendorType, (value) {
                        setState(() {
                          selectedVendorType = value;
                        });
                      }),
                      buildDropdownPayment("Plant Name", PlantName, (value) {
                        setState(() {
                          selectedPlantName = value;
                        });
                      }),
                      buildDropdownPayment("Buyer", Buyer, (value) {
                        setState(() {
                          selectedBuyer = value;
                        });
                      }),
                      buildDropdownPayment("Material", Material, (value) {
                        setState(() {
                          selectedMaterial = value;
                        });
                      }),
                      buildFieldWithDatePicker('From Date',
                        fromDate,
                            (selectedDate) {
                          setState(() {
                            fromDate = selectedDate;
                          });
                        },
                      ),
                      buildFieldWithDatePicker('To Date',
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

  Widget buildDropdownPayment(String label, Map<String, String> options, ValueChanged<String?> onChanged) {
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
              value: options.keys.first,
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


import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';
import '../URL_CONSTANT.dart';


class Add_user extends StatefulWidget {

  @override
  State<Add_user> createState() => _Add_userState();
}

class _Add_userState extends State<Add_user> {


  String? selectedUserType;
  String? selectedVendorType;
  String? selectedPlantName;

  // Data for dropdowns
  Map<String, String> UserTypes = {
    'S': 'Super Admin',
    'A': 'Admin',
    'U': 'User'
  };

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

  // Controllers for the text fields
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailIdController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController uuIDController = TextEditingController();

  bool isActiveYes = false;
  bool isActiveNo = false;
  bool isMobileLoginYes = false;
  bool isMobileLoginNo = false;
  bool hasAccessSaleOrderDataYes = false;
  bool hasAccessSaleOrderDataNo = false;
  bool isRefundYes = false;
  bool isRefundNo = false;
  bool isReceiverYes = false;
  bool isReceiverNo = false;
  bool isPaymentYes = false;
  bool isPaymentNo = false;
  bool isDispatchYes = false;
  bool isDispatchNo = false;

  // Variables for user details
  String? username = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';


  @override
  void dispose() {
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
  }

  Widget _buildTextField(String labelText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,// Fixed width for the label, adjust as needed
            child: Text(
              labelText,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
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
              value: selectedUserType ?? options.keys.first, // Use the selected value or the first option
              items: options.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key, // Set the correct value for each dropdown item
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxWithOptions(String label, bool yesValue, bool noValue, Function(bool?) onChanged, {bool isMandatory = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,// Fixed width for the label, adjust as needed
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Row(
            children: [
              Row(
                children: [
                  Radio(
                    value: true,
                    groupValue: yesValue,
                    onChanged: (value) {
                      onChanged(value as bool);
                    },
                  ),
                  Text('Yes'),
                ],
              ),
              SizedBox(width: 20),
              Row(
                children: [
                  Radio(
                    value: true,
                    groupValue: noValue,
                    onChanged: (value) {
                      onChanged(!(value as bool));
                    },
                  ),
                  Text('No'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: AppDrawer(currentPage: 0),
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Add User",
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
            SizedBox(height: 12),
            buildDropdown("User Type", UserTypes, (value) {
              setState(() {
                selectedUserType = value;
              });
            }),
            _buildTextField("Full Name", fullNameController),
            _buildTextField('Email ID', emailIdController),
            _buildTextField('Username', usernameController),
            _buildTextField('Password', passwordController),
            _buildCheckboxWithOptions('Active?', isActiveYes, isActiveNo, (bool? yesChecked) {
              setState(() {
                isActiveYes = yesChecked ?? false;
                isActiveNo = !yesChecked! ?? true;
              });
            }, isMandatory: true),
            _buildCheckboxWithOptions(
              'Mobile Login?',
              isMobileLoginYes,
              isMobileLoginNo,
                  (bool? yesChecked) {
                setState(() {
                  isMobileLoginYes = yesChecked ?? false;
                  isMobileLoginNo = !yesChecked! ?? true;
                });
              },
              isMandatory: true,
            ),
            _buildCheckboxWithOptions(
              'Access Sale Order?',
              hasAccessSaleOrderDataYes,
              hasAccessSaleOrderDataNo,
                  (bool? yesChecked) {
                setState(() {
                  hasAccessSaleOrderDataYes = yesChecked ?? false;
                  hasAccessSaleOrderDataNo = !(yesChecked ?? true);
                });
              },
              isMandatory: true,
            ),
            _buildCheckboxWithOptions(
              'Access Dispatch?',
              isDispatchYes,
              isDispatchNo,
                  (bool? yesChecked) {
                setState(() {
                  isDispatchYes = yesChecked ?? false;
                  isDispatchNo = !yesChecked! ?? true;
                });
              },
              isMandatory: true,
            ),
            _buildCheckboxWithOptions(
              'Access Refund?',
              isRefundYes,
              isRefundNo,
                  (bool? yesChecked) {
                setState(() {
                  isRefundYes = yesChecked ?? false;
                  isRefundNo = !yesChecked! ?? true;
                });
              },
              isMandatory: true,
            ),
            _buildCheckboxWithOptions(
              'Access Payment?',
              isPaymentYes,
              isPaymentNo,
                  (bool? yesChecked) {
                setState(() {
                  isPaymentYes = yesChecked ?? false;
                  isPaymentNo = !yesChecked! ?? true;
                });
              },
              isMandatory: true,
            ),
            buildDropdown("Vendor", VendorType, (value) {
              setState(() {
                selectedVendorType = value;
              });
            }),
            buildDropdown("Plant Name", PlantName, (value) {
              setState(() {
                selectedPlantName = value;
              });
            }),
            _buildTextField('UUID', uuIDController),

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
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }







}
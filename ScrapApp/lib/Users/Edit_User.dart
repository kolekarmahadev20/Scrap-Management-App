import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';
import '../URL_CONSTANT.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:math';

import 'User_list.dart'; // For Random

class Edit_User extends StatefulWidget {
  final User user;

  const Edit_User({required this.user, Key? key}) : super(key: key);

  @override
  State<Edit_User> createState() => _Edit_UserState();
}

class _Edit_UserState extends State<Edit_User> {

  final TextEditingController _vendorController = TextEditingController();
  final List<Map<String, String>> _vendorList = []; // Stores vendor data
  final List<String> _vendorOptions = []; // Stores vendor_name for suggestions
  final List<String> _selectedVendorValues = [];
  final Map<String, String> _selectedVendors = {}; // Maps vendor_name to vendor_id


  final TextEditingController _locationController = TextEditingController();
  final List<Map<String, String>> _locationList = []; // Stores location data
  final List<String> _locationOptions = []; // Stores location_name for suggestions
  final List<String> _selectedLocationValues = [];
  final Map<String, String> _selectedLocations = {}; // Maps location_name to location_id

  final TextEditingController _organizationController = TextEditingController();
  final List<Map<String, String>> _organizationList = []; // Stores location data
  final List<String> _organizationOptions = []; // Stores location_name for suggestions
  late final List<String> _selectedorganizationValues = [];
  final Map<String, String> _selectedOrganization= {}; // Maps location_name to location_id

  String? selectedUserType;

  // Data for dropdowns
  Map<String, String> UserTypes = {
    '':'Select',
    'S': 'Super Admin',
    'A': 'Admin',
    'U': 'User'
  };



  // Controllers for the text fields
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailIdController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController uuIDController = TextEditingController();
  final employeeCodeController = TextEditingController();

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
  String uuid = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';


  @override
  void dispose() {
    super.dispose();
    emailIdController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    employeeCodeController.dispose();

  }


  @override
  void initState() {
    super.initState();


    print(widget.user.vendorId);
    print(widget.user.plantId);

    print('widget.user.userType');

    print(widget.user.userType);

    if(widget.user.userType != 'NA')
      selectedUserType = widget.user.userType??'';

    employeeCodeController.text = widget.user.empCode??'';
    fullNameController.text = widget.user.personName??'';
    emailIdController.text = widget.user.empEmail??'';
    usernameController.text = widget.user.username??'';
    passwordController.text = widget.user.cPass??'';
    uuIDController.text = widget.user.uuid??'';

     isActiveYes = widget.user.isActive == 'Y';
     isActiveNo = widget.user.isActive != 'Y';
     isMobileLoginYes = widget.user.isMobile == 'Y';
     isMobileLoginNo =  widget.user.isMobile != 'Y';
     hasAccessSaleOrderDataYes = widget.user.accesSaleOrder == 'Y';
     hasAccessSaleOrderDataNo = widget.user.accesSaleOrder != 'Y';
     isRefundYes = widget.user.accesRefund == 'Y';
     isRefundNo = widget.user.accesRefund != 'Y';
     isPaymentYes = widget.user.accesPayment == 'Y';
     isPaymentNo = widget.user.accesPayment != 'Y';
     isDispatchYes =widget.user.accesDispatch == 'Y';
     isDispatchNo = widget.user.accesDispatch != 'Y';




    checkLogin();
    _fetchOrganizations();
    _fetchVendors();

    // generateEmployeeCode();
    emailIdController.addListener(() {
      final email = emailIdController.text.trim();
      if (email.isNotEmpty && email.contains("@")) {
        generateUsernameAndPassword(email);
      }
    });

    print(widget.user.orgID);
    print('BHHARAT');

  }


  //Fetching user details from sharedpreferences
  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    uuid = prefs.getString("uuid")!;
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
    uuid = prefs.getString("uuid")!;
  }

  void generateUsernameAndPassword(String email) {
    final username = email.split('@').first;
    final password = generateRandomPassword();

    setState(() {
      usernameController.text = username;
      passwordController.text = password;
    });
  }


  String generateRandomPassword() {
    const length = 8; // Length of the password
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Function to generate a random employee code
  String generateEmployeeCode() {
    const prefix = "EMP"; // Prefix for employee codes
    final random = Random();
    final suffix = random.nextInt(9000) + 1000; // Generate a 4-digit random number
    final employeeCode = '$prefix$suffix';

    setState(() {
      employeeCodeController.text = employeeCode; // Set the employee code in the field
    });

    return employeeCode;
  }


  Future<void> _addUsers() async {
    final vendorIds = _selectedVendors.values.toList();  // Extract IDs
    final plantIds = _selectedLocations.values.toList();  // Extract IDs
    final organizationIds = _selectedOrganization.values.toList();  // Extract IDs
    final organizationIdsString = organizationIds.join(',');

    try {
      await checkLogin();

      final url = '${URL}edit_user';

      final response = await http.post(
        Uri.parse(url),
        body: {
          'user_id': username,
          'user_pass': password,
          'uuid': uuid,
          'emp_code': employeeCodeController.text ?? '',
          'user_type': userType.toString() ?? '',
          'uname': usernameController.text ?? '',
          'c_pass': passwordController.text ?? '',
          'is_active': isActiveYes ? 'Y' : 'N',
          'mob_login': isMobileLoginYes ? 'Y' : 'N',
          'acces_sale_order': hasAccessSaleOrderDataYes ? 'Y' : 'N',
          'acces_dispatch': isDispatchYes ? 'Y' : 'N',
          'acces_payment': isPaymentYes ? 'Y' : 'N',
          'acces_refund': isRefundYes ? 'Y' : 'N',
          'vendor_id': vendorIds.join(',')?? '',
          'plant_id': plantIds.join(','),
          'org_id': organizationIdsString,
          'person_name': fullNameController.text ?? '',
          'email': emailIdController.text ?? '',
          'uuiid': uuIDController.text ?? '',
          'person_id':widget.user.personId,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Show a toast message
        Fluttertoast.showToast(
          msg: "Employee saved successfully",
        );

        // Pop the current page from the navigation stack
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => view_user(currentPage: 0), // Ensure view_user is a widget
          ),
        );
      } else {
        // Handle error response
        Fluttertoast.showToast(
          msg: "Failed to save employee",
        );
      }
    } catch (e) {
      print("Error adding user: $e");
    }
  }


  Future<void> _fetchVendors() async {
    try {
      await checkLogin();
      final url = '${URL}get_dropdown';
      final response = await http.post(
        Uri.parse(url),
        body: {
          'user_id': username,
          'user_pass': password,
          'uuid': uuid,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if 'vendor_list' exists and is not null
        if (data != null) {
          final vendorList = data['vendor_list'] as List?;
          final locationList = data['location'] as List?;

          setState(() {
            // Process vendor list
            if (vendorList != null) {
              for (var vendor in vendorList) {
                final vendorName = vendor['vendor_name'];
                final vendorId = vendor['vendor_id'];
                _vendorList.add({"id": vendorId, "name": vendorName});
                _vendorOptions.add(vendorName);
              }
            }
            // if (widget.user.vendorId != null && widget.user.vendorId!.isNotEmpty && widget.user.vendorId != 'NA')
              _prefillSelectedVendors();

          });
        } else {
          print("Response data is null.");
        }
      } else {
        print("Failed to load vendors. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching vendors: $e");
    }
  }

  void _prefillSelectedVendors() {
    if (widget.user.vendorId!.isNotEmpty) {
      List<String> selectedVendorIds = widget.user.vendorId!.split(',');

      for (var id in selectedVendorIds) {
        final vendor = _vendorList.firstWhere(
              (vendor) => vendor['id'].toString() == id.trim(),
          orElse: () => {},
        );

        if (vendor.isNotEmpty) {
          // Avoid duplicates in selected vendors
          if (!_selectedVendorValues.contains(vendor['name'])) {
            _selectedVendorValues.add(vendor['name']!);
            _selectedVendors[vendor['name']!] = vendor['id']!;
          }
        }
      }

      print("Final Selected Vendors: $_selectedVendorValues");
      print("Selected Vendor Map: $_selectedVendors");
      _fetchPlants(_selectedVendors);

      // if (_selectedVendors.isNotEmpty) {
      //   _fetchPlants(_selectedVendors);
      // } else {
      //   print("No vendors selected. Skipping _fetchPlants call.");
      // }
      setState(() {}); // Update UI
    }
  }


  Future<void> _fetchPlants(Map<String, String> selectedVendors) async {

    print(_selectedVendors);
    print("POOJA");
    final vendorIds = selectedVendors.values.toList();  // Extract IDs

    // Debug: Print the vendor IDs being sent
    print("Sending vendor IDs: $vendorIds");
    final vendorIdsString = vendorIds.join(',');

    try {
      await checkLogin();
      final url = '${URL}fetch_plant';

      final response = await http.post(
        Uri.parse(url),
        body: {
          'user_id': username,
          'user_pass': password,
          'uuid': uuid,
          'vendor_id': vendorIdsString,
        },
      );

      // Debug: Log the status code and body of the response
      print("Response Status Code: ${response.statusCode}");

      setState(() {
        _locationList.clear();
        _locationOptions.clear();
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Debug: Log the response data for inspection
        print("Response Body1: $data");

        // Check if 'plants' data exists and process it
        if (data != null && data['plants'] != null) {
          final locationList = data['plants'] as List?;

          setState(() {
            // Process the location list
            if (locationList != null) {
              for (var location in locationList) {
                final locationName = location['branch_name'];
                final locationId = location['branch_id'];
                _locationList.add({"id": locationId, "name": locationName});
                _locationOptions.add(locationName);
              }
            }
          });

          // if (widget.user.plantId != null && widget.user.plantId!.isNotEmpty && widget.user.plantId != 'NA')
            _prefillSelectedLocations();

        } else {
          print("Response data is null or 'plants' not found.");
        }
      } else {
        print("Failed to fetch plants. Status code: ${response.statusCode}");
        // Debug: Log the full response body in case of failure
        print("Response Body2: ${response.body}");
      }
    } catch (e) {
      print("Error fetching plants: $e");
    }
  }

  bool isPrefilled = false; // Add this as a class-level variable


  void _prefillSelectedLocations() {
    if (isPrefilled) return; // Prevent re-execution
    isPrefilled = true; // Mark as executed

    if (widget.user.plantId!.isNotEmpty) {
      List<String> selectedVendorIds = widget.user.plantId!.split(',');

      for (var id in selectedVendorIds) {
        final vendor = _locationList.firstWhere(
              (vendor) => vendor['id'].toString() == id.trim(),
          orElse: () => {},
        );

        if (vendor.isNotEmpty) {
          if (!_selectedLocationValues.contains(vendor['name'])) {
            _selectedLocationValues.add(vendor['name']!);
            _selectedLocations[vendor['name']!] = vendor['id']!;
          }
        }
      }

      print("Final Selected Vendors: $_selectedLocationValues");
      print("Selected Vendor Map: $_selectedLocations");

      _fetchPlants(_selectedLocations);
      setState(() {}); // Update UI
    }
  }


  Future<void> _fetchOrganizations() async {
    try {
      await checkLogin();
      final url = '${URL}organiazation_list';
      final response = await http.post(
        Uri.parse(url),
        body: {
          'user_id': username,
          'user_pass': password,
          'uuid':uuid
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if response data is valid
        if (data != null && data is List) {
          setState(() {
            for (var org in data) {
              final orgName = org['OrgName'];
              final orgId = org['org_id'];

              _organizationList.add({"id": orgId, "name": orgName});
              _organizationOptions.add(orgName);

              // if (widget.user.orgID != null && widget.user.orgID!.isNotEmpty && widget.user.orgID != 'NA')
                _prefillSelectedOrganizations();

            }
          });
        } else {
          print("Invalid response format or empty data.");
        }
      } else {
        print("Failed to fetch organizations. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching organizations: $e");
    }
  }


  void _prefillSelectedOrganizations() {
    if (widget.user.orgID!.isNotEmpty) {
      List<String> selectedOrgIds = widget.user.orgID!.split(',');

      for (var id in selectedOrgIds) {
        final org = _organizationList.firstWhere(
              (org) => org['id'].toString() == id.trim(),
          orElse: () => {},
        );

        if (org.isNotEmpty) {

          // Avoid duplicates in selected organization
          if (!_selectedorganizationValues.contains(org['name'])) {
            _selectedorganizationValues.add(org['name']!);
            _selectedOrganization[org['name']!] = org['id']!;
          }
        }
      }
      setState(() {}); // Update UI
    }
  }


  // Function to build a reusable TypeAhead dropdown
  Widget buildTypeAheadDropdownVendor({
    required String label,
    required List<String> items,
    required TextEditingController controller,
    required List<String> selectedValues,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        TypeAheadField<String>(
          textFieldConfiguration: TextFieldConfiguration(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
            ),
          ),
          suggestionsCallback: (pattern) {
            return items
                .where((item) => item.toLowerCase().contains(pattern.toLowerCase()))
                .toList();
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              title: Text(suggestion),
            );
          },
          onSuggestionSelected: (suggestion) {
            if (!selectedValues.contains(suggestion)) {
              setState(() {

                selectedValues.add(suggestion);
                final vendorId = _vendorList
                    .firstWhere((vendor) => vendor['name'] == suggestion)['id'];
                _selectedVendors[suggestion] = vendorId!;

                _fetchPlants(_selectedVendors);
              });
            }
          },
        ),
        SizedBox(height: 10),
        InputDecorator(
          decoration: InputDecoration(
            labelText: "$label Selected",
            border: OutlineInputBorder(),
          ),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: selectedValues.map((value) {
              return Chip(
                label: Text(value),
                deleteIcon: Icon(Icons.close),
                onDeleted: () {
                  setState(() {
                    selectedValues.remove(value);
                    _selectedVendors.remove(value);
                    _fetchPlants(_selectedVendors);
                  });
                },
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildTypeAheadDropdownplant({
    required String label,
    required List<String> items,
    required TextEditingController controller,
    required List<String> selectedValues,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        TypeAheadField<String>(
          textFieldConfiguration: TextFieldConfiguration(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
            ),
          ),
          suggestionsCallback: (pattern) {
            return items
                .where((item) =>
                item.toLowerCase().contains(pattern.toLowerCase()))
                .toList();
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              title: Text(suggestion),
            );
          },
          onSuggestionSelected: (suggestion) {
            if (!selectedValues.contains(suggestion)) {
              setState(() {
                selectedValues.add(suggestion);
                final locationId = _locationList
                    .firstWhere((location) => location['name'] == suggestion)['id'];
                _selectedLocations[suggestion] = locationId!;
              });
            }
          },
        ),
        SizedBox(height: 10),
        InputDecorator(
          decoration: InputDecoration(
            labelText: "$label Selected",
            border: OutlineInputBorder(),
          ),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: selectedValues.map((value) {
              return Chip(
                label: Text(value),
                deleteIcon: Icon(Icons.close),
                onDeleted: () {
                  setState(() {
                    selectedValues.remove(value);
                    _selectedLocations.remove(value);
                  });
                },
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildTypeAheadDropdownorganization({
    required String label,
    required List<String> items,
    required TextEditingController controller,
    required List<String> selectedValues,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        TypeAheadField<String>(
          textFieldConfiguration: TextFieldConfiguration(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
            ),
          ),
          suggestionsCallback: (pattern) {
            return items
                .where((item) => item.toLowerCase().contains(pattern.toLowerCase()))
                .toList();
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              title: Text(suggestion),
            );
          },
          onSuggestionSelected: (suggestion) {
            if (!selectedValues.contains(suggestion)) {
              setState(() {
                selectedValues.add(suggestion);
                final organizationId = _organizationList
                    .firstWhere((organization) => organization['name'] == suggestion)['id'];
                _selectedOrganization[suggestion] = organizationId!;
              });
            }
          },
        ),
        SizedBox(height: 10),
        InputDecorator(
          decoration: InputDecoration(
            labelText: "$label Selected",
            border: OutlineInputBorder(),
          ),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: selectedValues.map((value) {
              return Chip(
                label: Text(value),
                deleteIcon: Icon(Icons.close),
                onDeleted: () {
                  setState(() {
                    selectedValues.remove(value);
                    _selectedOrganization.remove(value);
                  });
                },
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
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

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => view_user(currentPage: 0), // Ensure view_user is a widget
          ),
        );
        return false; // Prevents back navigation
      },

      child: Scaffold(
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
                      "Edit User",
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,// Fixed width for the label, adjust as needed
                      child: Text(
                        "Employee Code",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child:  TextField(
                        controller: employeeCodeController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
              ),
      
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
      
              buildTypeAheadDropdownorganization(
                label: "Organization",
                items: _organizationOptions,
                controller: _organizationController,
                selectedValues: _selectedorganizationValues,
              ),
      
              buildTypeAheadDropdownVendor(
                label: "Vendor",
                items: _vendorOptions,
                controller: _vendorController,
                selectedValues: _selectedVendorValues,
              ),
      
              buildTypeAheadDropdownplant(
                label: "Plant Name",
                items: _locationOptions,
                controller: _locationController,
                selectedValues: _selectedLocationValues,
              ),
      
              _buildTextField('UUID', uuIDController),
      
              const SizedBox(height: 10),
      
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _addUsers();
                    // print(_selectedVendors);
                    // print("_selectedVendors");
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
      ),
    );
  }








}
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import '../../AppClass/AppDrawer.dart';
import '../../AppClass/appBar.dart';
import '../../URL_CONSTANT.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:math'; // For Random
import 'dart:math';

class Add_user extends StatefulWidget {
  @override
  State<Add_user> createState() => _Add_userState();
}

class _Add_userState extends State<Add_user> {

  // Material Port Controllers & Lists
  final TextEditingController _materialPortController = TextEditingController();
  final List<Map<String, String>> _materialPortList = []; // Stores material_port data
  final List<String> _materialPortOptions = []; // Stores material_port_name for suggestions
  final List<String> _selectedMaterialPortValues = [];
  final Map<String, String> _selectedMaterialPorts = {}; // Maps material_port_name to material_port_id


  // Location Port Controllers & Lists
  final TextEditingController _locationPortController = TextEditingController();
  final List<Map<String, String>> _locationPortList = []; // Stores location_port data
  final List<String> _locationPortOptions = []; // Stores location_port_name for suggestions
  final List<String> _selectedLocationPortValues = [];
  final Map<String, String> _selectedLocationPorts = {}; // Maps location_port_name to location_port_id


  final TextEditingController _vendorController = TextEditingController();
  final List<Map<String, String>> _vendorList = []; // Stores vendor data
  final List<String> _vendorOptions = []; // Stores vendor_name for suggestions
  final List<String> _selectedVendorValues = [];
  final Map<String, String> _selectedVendors = {}; // Maps vendor_name to vendor_id

  final TextEditingController _locationController = TextEditingController();
  final List<Map<String, String>> _locationList = []; // Stores location data
  final List<String> _locationOptions =
  []; // Stores location_name for suggestions
  final List<String> _selectedLocationValues = [];
  final Map<String, String> _selectedLocations =
  {}; // Maps location_name to location_id

  final TextEditingController _organizationController = TextEditingController();
  final List<Map<String, String>> _organizationList = [];
  final List<String> _organizationOptions = [];
  final List<String> _selectedorganizationValues = [];
  final Map<String, String> _selectedOrganization = {};

  String? selectedUserType;

  // Data for dropdowns
  Map<String, String> UserTypes = {
    '': 'Select',
    'S': 'Super Admin',
    'A': 'Admin',
    'SA': 'Sub Admin',
    'U': 'User'
  };

  String selectedEmployeeId = '';
  List<Map<String, String>> employees = []; // List to store dropdown data
  Map<String, String>? employeeDetails;

  // Controllers for the text fields
  final TextEditingController _employeeController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController adharNumberController = TextEditingController();
  final TextEditingController emailIdController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController personID = TextEditingController();
  final TextEditingController uuIDController = TextEditingController();
  final employeeCodeController = TextEditingController();

  bool isActiveYes = false;
  bool isActiveNo = false;
  bool isMobileLoginYes = false;
  bool isMobileLoginNo = false;
  bool hasAccessSaleOrderDataYes = false;
  bool hasAccessSaleOrderDataNo = false;
  bool hasAccessSealDataYes = false;
  bool hasAccessSealDataNo = false;

  bool isRefundYes = false;
  bool isRefundNo = false;
  bool isReceiverYes = false;
  bool isReceiverNo = false;
  bool isPaymentYes = false;
  bool isPaymentNo = false;
  bool isDispatchYes = false;
  bool isDispatchNo = false;
  bool isReadOnlyYes = false;
  bool isReadOnlyNo = false;

  bool isOnlyAttendYes = false;
  bool isOnlyAttendNo = false;

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
    checkLogin();
    _fetchOrganizations();
    _fetchVendors();
    // generateEmployeeCode();
    // emailIdController.addListener(() {
    //   final email = emailIdController.text.trim();
    //   if (email.isNotEmpty && email.contains("@")) {
    //     generateUsernameAndPassword(email);
    //   }
    // });
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
    if (usernameController.text == "N/A" && passwordController.text == "N/A") {
      final username = generateUsername(email);
      final password = generatePassword(username);

      setState(() {
        usernameController.text = username;
        passwordController.text = password;
      });
    }
  }

  String generateUsername(String email) {
    String namePart = email.split('@').first; // Extract name before '@'
    namePart = namePart.length >= 4 ? namePart.substring(0, 4) : namePart;

    final Random random = Random();
    int randomNumber = random.nextInt(9000) + 1000; // 4-digit number (1000-9999)

    return '$namePart$randomNumber';
  }

  String generatePassword(String username) {
    String namePart = username.substring(0, 4); // Extract first 4 characters
    String numberPart = username.substring(4); // Extract last 4-digit number

    return '${capitalize(namePart)}@$numberPart';
  }

  String capitalize(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<bool> checkAadhar() async {
    try {
      await checkLogin(); // Ensure user is logged in

      final response = await http.post(
        Uri.parse('${URL}check_adhar'),
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'user_pass': password,
          'uuid': uuid,
          'adhaar_num': adharNumberController.text,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData["status"] == "success") {
          Fluttertoast.showToast(
              msg:
              "This aadhar card number is already registered"); // Show toast message
          return false; // Stop addUser() from executing
        } else {
          return true; // Continue to addUser()
        }
      } else {
        Fluttertoast.showToast(msg: "Server Error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Exception: $e");
      return false;
    }
  }

  Future<void> fetchEmployeeDetails(String personId) async {
    try {
      print("Fetching details for person ID: $personId");
      await checkLogin(); // Ensure user is logged in

      final response = await http.post(
        Uri.parse('${URL}fetchEmpDetails'),
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'user_pass': password,
          'uuid': uuid,
          "person_id": personId,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Response Data: $data"); // Debugging purpose

        if (data["details"] != null) {
          setState(() {
            employeeCodeController.text = data["details"]["emp_code"] ?? "N/A";
            emailIdController.text = data["details"]["emp_email"] ?? "N/A";
            adharNumberController.text =
                data["details"]["adhar_num"] ?? "N/A"; // Fixed key
            fullNameController.text = data["details"]["person_name"] ?? "N/A";
            usernameController.text = data["details"]["uname"] ?? "N/A";
            passwordController.text = data["details"]["c_pass"] ?? "N/A";
            personID.text = data["details"]["person_id"] ?? "N/A";

            generateUsernameAndPassword(emailIdController.text);
          });
        } else {
          print("No details found for the given person ID.");
        }
      } else {
        print("Failed to fetch details. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching employee details: $e");
    }
  }

  Future<void> _addUsers() async {
    // bool shouldProceed = await checkAadhar();
    // if (!shouldProceed) return;  // Stop execution if employee exists

    if (selectedUserType == null || selectedUserType.toString().isEmpty) {
      Fluttertoast.showToast(
        msg: "Please select a User Type",
      );
      return; // Stop execution if user type is not selected
    }
    final vendorIds = _selectedVendors.values.toList(); // Extract IDs
    final plantIds = _selectedLocations.values.toList(); // Extract IDs

    final locationportIds = _selectedLocationPorts.values.toList(); // Extract IDs
    final materialportIds = _selectedMaterialPorts.values.toList(); // Extract IDs

    final organizationIds =
    _selectedOrganization.values.toList(); // Extract IDs
    final organizationIdsString = organizationIds.join(',');

    print(_selectedorganizationValues);
    print("_selectedorganizationValues");

    print(_selectedVendors);
    print("_selectedVendors");

    // _selectedorganizationValues

    try {
      await checkLogin();

      // final url = '${URL}add_user';
      final url = '${URL}edit_user';

      // Debug: Print URL and the request body data before making the API call
      print("Making POST request to URL: $url");
      print("Request Body: ");
      print({
        'user_id': username,
        'user_pass': password,
        'uuid': uuid,
        'emp_code': employeeCodeController.text ?? '',
        'user_type': selectedUserType.toString() ?? '',
        'uname': usernameController.text ?? '',
        'c_pass': passwordController.text ?? '',
        'is_active': isActiveYes ? 'Y' : 'N',

        // 'is_active': isReadOnlyYes ? 'Y' : 'N',
        // 'is_active': isOnlyAttendYes ? 'Y' : 'N',

        'mob_login': isMobileLoginYes ? 'Y' : 'N',
        'acces_sale_order': hasAccessSaleOrderDataYes ? 'Y' : 'N',
        'access_seal': hasAccessSealDataYes ? 'Y' : 'N',
        'acces_dispatch': isDispatchYes ? 'Y' : 'N',
        'acces_payment': isPaymentYes ? 'Y' : 'N',
        'acces_refund': isRefundYes ? 'Y' : 'N',
        'vendor_ids': vendorIds.join(',') ?? '',
        'plant_id': plantIds.join(',') ?? '',

        'location_port_id': locationportIds.join(',') ?? '',
        'material_port_id': materialportIds.join(',') ?? '',


        // 'org_id': organizationIds.join('')?? '',
        'org_id': _selectedorganizationValues.join(',') ?? '',
        'person_name': fullNameController.text ?? '',
        'email': emailIdController.text ?? '',
        'uuid': uuIDController.text ?? '',

        'is_mobile': isMobileLoginYes ? 'Y' : 'N',

        // 'is_desktop': isActiveYes ? 'Y' : 'N',
        'is_desktop': (selectedUserType == 'S' || selectedUserType == 'A') ? 'Y' : 'N',

        // 'is_all': (isMobileLoginYes == 'N' && isActiveYes == 'N') ? 'Y' : 'N',
        'is_all': (isMobileLoginYes == 'N') ? 'Y' : 'N',

      });

      final response = await http.post(
        Uri.parse(url),
        body: {

          'user_id': username,
          'user_pass': password,
          'uuid': uuid,
          'emp_code': employeeCodeController.text ?? '',
          'user_type': selectedUserType.toString() ?? '',
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
          // 'org_id': _selectedorganizationValues.join(',')?? '',
          'person_name': fullNameController.text ?? '',
          'email': emailIdController.text ?? '',
          'uuiid': uuIDController.text ?? '',
          'person_id':personID.text??'',
          'adhar_num':adharNumberController.text ?? '',

          'is_mobile': isMobileLoginYes ? 'Y' : 'N',

          // 'is_desktop': isActiveYes ? 'Y' : 'N',
          'is_desktop': (selectedUserType == 'S' || selectedUserType == 'A') ? 'Y' : 'N',

          // 'is_all': (isMobileLoginYes == 'N' && isActiveYes == 'N') ? 'Y' : 'N',
          'is_all': (isMobileLoginYes == 'N') ? 'Y' : 'N',
          'read_only': isReadOnlyYes ? 'Y' : 'N',
          'attendance_only': isOnlyAttendYes ? 'Y' : 'N',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Show a toast message
        Fluttertoast.showToast(
          msg: "Employee saved successfully",
        );

        // Pop the current page from the navigation stack
        Navigator.pop(context);
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

          final locationList = data['vendor_list'] as List?;
          final vendorList = data['vendor_list'] as List?;
          final locationportList = data['location_port'] as List?;
          final materialportList = data['material_port'] as List?;

          setState(() {

            //materialport
            if (materialportList != null) {
              for (var materialport in materialportList) {
                final materialName = materialport['material_name'];
                final materialId = materialport['material_id'];
                _materialPortList.add({"id": materialId, "name": materialName});
                _materialPortOptions.add(materialName);
              }
            }

            //locationport
            if (locationportList != null) {
              for (var locationport in locationportList) {
                if (locationport['is_available_for_seal'] == "1") { // ✅ filter
                  final locationName = locationport['location_name'];
                  final locationId = locationport['location_id'];
                  _locationPortList.add({"id": locationId, "name": locationName});
                  _locationPortOptions.add(locationName);
                }
              }
            }


            // Process vendor list
            if (vendorList != null) {
              for (var vendor in vendorList) {
                final vendorName = vendor['vendor_name'];
                final vendorId = vendor['vendor_id'];
                _vendorList.add({"id": vendorId, "name": vendorName});
                _vendorOptions.add(vendorName);
              }
            }

            employees =
            List<Map<String, String>>.from(data['users'].map((x) => {
              'id': x['person_id']?.toString() ??
                  '', // Handle null safely
              'full_name': x['person_name']?.toString() ??
                  '', // Handle null safely
              'username': x['uname']?.toString() ??
                  '', // Use emp_code instead of uname
            }));

            // Process location list
            // if (locationList != null) {
            //   for (var location in locationList) {
            //     final locationName = location['location_name'];
            //     final locationId = location['id'];
            //     _locationList.add({"id": locationId, "name": locationName});
            //     _locationOptions.add(locationName);
            //   }
            // }
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

  Future<void> _fetchPlants(Map<String, String> selectedVendors) async {
    final vendorIds = selectedVendors.values.toList(); // Extract IDs

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
        print("Response Body: $data");

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
        } else {
          print("Response data is null or 'plants' not found.");
        }
      } else {
        print("Failed to fetch plants. Status code: ${response.statusCode}");
        // Debug: Log the full response body in case of failure
        print("Response Body: ${response.body}");
      }
    } catch (e) {
      print("Error fetching plants: $e");
    }
  }

  Future<void> _fetchOrganizations() async {
    try {
      await checkLogin();
      final url = '${URL}organiazation_list';
      final response = await http.post(
        Uri.parse(url),
        body: {'user_id': username, 'user_pass': password, 'uuid': uuid},
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
            }
          });
        } else {
          print("Invalid response format or empty data.");
        }
      } else {
        print(
            "Failed to fetch organizations. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching organizations: $e");
    }
  }

  // Function to build a reusable TypeAhead dropdown
  // Widget buildCheckboxDropdownVendor({
  //   required String label,
  //   required List<Map<String, String>> items,
  //   required Map<String, String> selectedVendors,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         label,
  //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //       ),
  //       SizedBox(height: 10),
  //       Container(
  //         decoration: BoxDecoration(
  //           border: Border.all(color: Colors.grey),
  //           borderRadius: BorderRadius.circular(5),
  //         ),
  //         child: Column(
  //           children: items.map((vendor) {
  //             final vendorName = vendor['name']!;
  //             final vendorId = vendor['id']!;
  //
  //             return CheckboxListTile(
  //               title: Text(vendorName),
  //               value: selectedVendors.isNotEmpty &&
  //                   selectedVendors.containsKey(vendorName),
  //               onChanged: (bool? value) {
  //                 setState(() {
  //                   selectedVendors.clear(); // Pehle se selected vendor remove karein
  //                   if (value == true) {
  //                     selectedVendors[vendorName] = vendorId;
  //                   }
  //                   _fetchPlants(selectedVendors);
  //                 });
  //               },
  //             );
  //           }).toList(),
  //         ),
  //       ),
  //       SizedBox(height: 20),
  //     ],
  //   );
  // }



  Widget buildCheckboxDropdownMaterialPort({
    required String label,
    required List<Map<String, String>> items,
    required Map<String, String> selectedMaterialPort,
  }) {
    bool allSelected = selectedMaterialPort.length == items.length;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: [
              // Select All Checkbox
              CheckboxListTile(
                title: Text("Select All"),
                value: allSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      // Select all vendors
                      for (var materialport in items) {
                        _selectedMaterialPorts[materialport['name']!] = materialport['id']!;
                      }
                    } else {
                      // Deselect all
                      _selectedMaterialPorts.clear();
                    }
                  });
                },
              ),
              Divider(height: 1),
              // Individual Vendor Checkboxes
              ...items.map((materialport) {
                final materialportName = materialport['name']!;
                final materialportId = materialport['id']!;
                return CheckboxListTile(
                  title: Text(materialportName),
                  value: _selectedMaterialPorts.containsKey(materialportName),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedMaterialPorts[materialportName] = materialportId;
                      } else {
                        _selectedMaterialPorts.remove(materialportName);
                      }
                    });
                  },
                );
              }).toList(),
            ],
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildCheckboxDropdownLocationPort({
    required String label,
    required List<Map<String, String>> items,
    required Map<String, String> selectedLocationPort,
  }) {
    bool allSelected = selectedLocationPort.length == items.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: [
              // Select All Checkbox
              CheckboxListTile(
                title: Text("Select All"),
                value: allSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      // Select all vendors
                      for (var locationport in items) {
                        _selectedLocationPorts[locationport['name']!] = locationport['id']!;
                      }
                    } else {
                      // Deselect all
                      _selectedLocationPorts.clear();
                    }
                  });
                },
              ),
              Divider(height: 1),
              // Individual Vendor Checkboxes
              ...items.map((locationport) {
                final locationPortName = locationport['name']!;
                final locationPortId = locationport['id']!;
                return CheckboxListTile(
                  title: Text(locationPortName),
                  value: _selectedLocationPorts.containsKey(locationPortName),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedLocationPorts[locationPortName] = locationPortId;
                      } else {
                        _selectedLocationPorts.remove(locationPortName);
                      }
                    });
                  },
                );
              }).toList(),
            ],
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildCheckboxDropdownVendor({
    required String label,
    required List<Map<String, String>> items,
    required Map<String, String> selectedVendors,
  }) {
    bool allSelected = selectedVendors.length == items.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: [
              // Select All Checkbox
              CheckboxListTile(
                title: Text("Select All"),
                value: allSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      // Select all vendors
                      for (var vendor in items) {
                        selectedVendors[vendor['name']!] = vendor['id']!;
                      }
                    } else {
                      // Deselect all
                      selectedVendors.clear();
                    }
                    _fetchPlants(selectedVendors);
                  });
                },
              ),
              Divider(height: 1),
              // Individual Vendor Checkboxes
              ...items.map((vendor) {
                final vendorName = vendor['name']!;
                final vendorId = vendor['id']!;
                return CheckboxListTile(
                  title: Text(vendorName),
                  value: selectedVendors.containsKey(vendorName),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedVendors[vendorName] = vendorId;
                      } else {
                        selectedVendors.remove(vendorName);
                      }
                      _fetchPlants(selectedVendors);
                    });
                  },
                );
              }).toList(),
            ],
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildPlantRowField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label on the left
          Flexible(
            flex: 3,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 100),
              child: const Text(
                "Plant Name",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Field on the right
          Flexible(
            flex: 7,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: const Text("Select Plant"),
                      content: SizedBox(
                        width: double.maxFinite,
                        height: 400,
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            child: StatefulBuilder(
                              builder: (BuildContext context, StateSetter setStateDialog) {
                                bool allSelected = _selectedLocations.length == _locationList.length;

                                // 🔹 Create a sorted copy of plant list
                                final sortedPlantList = _locationList
                                    .map((plant) => {'name': plant['name']!.trim(), 'id': plant['id']!})
                                    .toList();

                                sortedPlantList.sort((a, b) => a['name']!.toLowerCase().compareTo(b['name']!.toLowerCase()));


                                // Build checkboxes
                                final plantCheckboxes = sortedPlantList.map((plant) {
                                  final name = plant['name']!;
                                  final id = plant['id']!;
                                  return CheckboxListTile(
                                    title: Text(name.toUpperCase()),
                                    value: _selectedLocations.containsKey(name),
                                    onChanged: (bool? value) {
                                      setStateDialog(() {
                                        if (value == true) {
                                          _selectedLocations[name] = id;
                                        } else {
                                          _selectedLocations.remove(name);
                                        }
                                      });
                                    },
                                  );
                                }).toList();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Select All Checkbox
                                    CheckboxListTile(
                                      title: const Text(
                                        "Select All",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      value: allSelected,
                                      onChanged: (bool? value) {
                                        setStateDialog(() {
                                          if (value == true) {
                                            for (var plant in _locationList) {
                                              _selectedLocations[plant['name']!] = plant['id']!;
                                            }
                                          } else {
                                            _selectedLocations.clear();
                                          }
                                        });
                                      },
                                    ),
                                    const Divider(),

                                    // Sorted plant checkboxes
                                    ...plantCheckboxes,
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("CLOSE"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            setState(() {}); // refresh main screen TextField
                          },
                          child: const Text("DONE"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Select Plant",
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                  controller: TextEditingController(
                    text: _selectedLocations.keys.map((e) => e.toUpperCase()).join(", "),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget buildTypeAheadDropdownorganization({
    required String label,
    required List<String> items,
    required TextEditingController controller,
    required List<String> selectedValues,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1, // Label ke liye kam space
              child: Text(
                label,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                textAlign: TextAlign.left,
              ),
            ),
            Expanded(
              flex: 2, // Dropdown ke liye zyada space
              child: Padding(
                padding: EdgeInsets.only(
                    right: 8), // Adjust left padding to shift left
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TypeAheadField<String>(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: "Search...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding:
                          EdgeInsets.symmetric(vertical: 7, horizontal: 12),
                        ),
                      ),
                      suggestionsCallback: (pattern) {
                        return items
                            .where((item) => item
                            .toLowerCase()
                            .contains(pattern.toLowerCase()))
                            .toList();
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title:
                          Text(suggestion, style: TextStyle(fontSize: 14)),
                          dense: true,
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        if (!selectedValues.contains(suggestion)) {
                          setState(() {
                            selectedValues.add(suggestion);
                            final organizationId = _organizationList.firstWhere(
                                    (organization) =>
                                organization['name'] == suggestion)['id'];
                            _selectedOrganization[suggestion] = organizationId!;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 2.0,
                      children: selectedValues.map((value) {
                        return Chip(
                          label: Text(value, style: TextStyle(fontSize: 12)),
                          deleteIcon: Icon(Icons.close, size: 18),
                          visualDensity: VisualDensity.compact,
                          onDeleted: () {
                            setState(() {
                              selectedValues.remove(value);
                              _selectedOrganization.remove(value);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
      ],
    );
  }

  // Widget buildCheckboxDropdownOrganization({
  //   required String label,
  //   required List<Map<String, String>> items,
  //   required List<String> selectedValues,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         label,
  //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //       ),
  //       SizedBox(height: 10),
  //       Container(
  //         decoration: BoxDecoration(
  //           border: Border.all(color: Colors.grey),
  //           borderRadius: BorderRadius.circular(5),
  //         ),
  //         child: Column(
  //           children: items.map((org) {
  //             final orgName = org['name']!;
  //             final orgId = org['id']!;
  //             return CheckboxListTile(
  //               title: Text(orgName),
  //               value: selectedValues.contains(orgId),
  //               onChanged: (bool? value) {
  //                 setState(() {
  //                   if (value == true) {
  //                     selectedValues.add(orgId);
  //                   } else {
  //                     selectedValues.remove(orgId);
  //                   }
  //                 });
  //               },
  //             );
  //           }).toList(),
  //         ),
  //       ),
  //       SizedBox(height: 20),
  //     ],
  //   );
  // }

  Widget _buildTextField(String labelText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3, // Fixed width for the label, adjust as needed
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
              value: selectedUserType ??
                  options
                      .keys.first, // Use the selected value or the first option
              items: options.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value:
                  entry.key, // Set the correct value for each dropdown item
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

  Widget _buildCheckboxWithOptions(
      String label, bool yesValue, bool noValue, Function(bool?) onChanged,
      {bool isMandatory = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3, // Fixed width for the label, adjust as needed
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

  Widget buildSearchableDropdown(
      String label,
      String? value,
      Function(String) onChanged,
      List<Map<String, String>> employees,
      TextEditingController controller,
      ) {
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100, // Adjust width as needed
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black, // 🔹 Force black for label
              ),
            ),
          ),
          Expanded(
            child: TypeAheadFormField<Map<String, String>>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: controller,
                style: const TextStyle(
                  color: Colors.black, // 🔹 Force entered/selected text black
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Select an employee',
                  hintStyle: const TextStyle(color: Colors.black54), // subtle grey hint
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.grey),
                    onPressed: () {
                      controller.clear();
                      onChanged('');

                      // Clear other related fields
                      employeeCodeController.clear();
                      emailIdController.clear();
                      adharNumberController.clear();
                      fullNameController.clear();
                      usernameController.clear();
                      passwordController.clear();
                    },
                  ),
                ),
              ),
              suggestionsCallback: (pattern) {
                final suggestions = employees.where((employee) {
                  return employee['full_name']!
                      .toLowerCase()
                      .contains(pattern.toLowerCase()) ||
                      employee['username']!
                          .toLowerCase()
                          .contains(pattern.toLowerCase());
                }).toList();
                return suggestions;
              },
              itemBuilder: (context, Map<String, String> suggestion) {
                if (suggestion['id'] == 'cancel') {
                  return const ListTile(
                    leading: Icon(Icons.cancel, color: Colors.red),
                    title: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                }
                return ListTile(
                  title: Text(
                    '${suggestion['full_name']} - (${suggestion['username']})',
                    style: const TextStyle(color: Colors.black), // 🔹 Black suggestions
                  ),
                );
              },
              onSuggestionSelected: (Map<String, String> suggestion) {
                if (suggestion['id'] == 'cancel') {
                  controller.clear();
                  onChanged('');
                } else {
                  controller.text =
                  '${suggestion['full_name']} - (${suggestion['username']})';
                  onChanged(suggestion['id']!);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVendorRowField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label on the left
          Flexible(
            flex: 3,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 100),
              child: const Text(
                "Vendor",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // TextField on the right
          Flexible(
            flex: 7,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: const Text("Select Vendor"),
                      content: SizedBox(
                        width: double.maxFinite,
                        height: 400,
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            child: StatefulBuilder(
                              builder: (BuildContext context, StateSetter setStateDialog) {
                                bool allSelected = _selectedVendors.length == _vendorList.length;

                                final sortedVendorList = _vendorList
                                    .map((vendor) => {
                                  'name': vendor['name']!.trim(), // remove extra spaces
                                  'id': vendor['id']!
                                })
                                    .toList();

                                sortedVendorList.sort(
                                        (a, b) => a['name']!.toLowerCase().compareTo(b['name']!.toLowerCase())
                                );


                                // Build vendor checkboxes
                                final vendorCheckboxes = sortedVendorList.map((vendor) {
                                  final name = vendor['name']!;
                                  final id = vendor['id']!;
                                  return CheckboxListTile(
                                    title: Text(name.toUpperCase()),
                                    value: _selectedVendors.containsKey(name),
                                    onChanged: (bool? value) {
                                      setStateDialog(() {
                                        if (value == true) {
                                          _selectedVendors[name] = id;
                                        } else {
                                          _selectedVendors.remove(name);
                                        }
                                        _fetchPlants(_selectedVendors);
                                      });
                                    },
                                  );
                                }).toList();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Select All Checkbox
                                    CheckboxListTile(
                                      title: const Text(
                                        "Select All",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      value: allSelected,
                                      onChanged: (bool? value) {
                                        setStateDialog(() {
                                          if (value == true) {
                                            for (var vendor in _vendorList) {
                                              _selectedVendors[vendor['name']!] = vendor['id']!;
                                            }
                                          } else {
                                            _selectedVendors.clear();
                                          }
                                          _fetchPlants(_selectedVendors);
                                        });
                                      },
                                    ),
                                    const Divider(),

                                    // Sorted vendor checkboxes
                                    ...vendorCheckboxes,
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("CLOSE"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            setState(() {}); // refresh main screen TextField
                          },
                          child: const Text("DONE"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Select Vendor",
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                    controller: TextEditingController(
                      text: _selectedVendors.keys.map((e) => e.toUpperCase()).join(", "),
                    ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget buildMaterialRowField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label on the left
          Flexible(
            flex: 3,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 100),
              child: const Text(
                "Material",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // TextField on the right
          Flexible(
            flex: 7,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: const Text("Select Material"),
                      content: SizedBox(
                        width: double.maxFinite,
                        height: 400,
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            child: StatefulBuilder(
                              builder: (BuildContext context, StateSetter setStateDialog) {
                                bool allSelected = _selectedMaterialPorts.length == _materialPortList.length;

                                final sortedMaterialList = _materialPortList
                                    .map((material) => {
                                  'name': material['name']!.trim(), // remove extra spaces
                                  'id': material['id']!
                                })
                                    .toList();

                                sortedMaterialList.sort(
                                        (a, b) => a['name']!.toLowerCase().compareTo(b['name']!.toLowerCase())
                                );

                                // Build checkboxes
                                final materialCheckboxes = sortedMaterialList.map((material) {
                                  final name = material['name']!;
                                  final id = material['id']!;
                                  return CheckboxListTile(
                                    title: Text(name.toUpperCase()),
                                    value: _selectedMaterialPorts.containsKey(name),
                                    onChanged: (bool? value) {
                                      setStateDialog(() {
                                        if (value == true) {
                                          _selectedMaterialPorts[name] = id;
                                        } else {
                                          _selectedMaterialPorts.remove(name);
                                        }
                                      });
                                    },
                                  );
                                }).toList();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Select All Checkbox
                                    CheckboxListTile(
                                      title: const Text(
                                        "Select All",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      value: allSelected,
                                      onChanged: (bool? value) {
                                        setStateDialog(() {
                                          if (value == true) {
                                            for (var material in _materialPortList) {
                                              _selectedMaterialPorts[material['name']!] = material['id']!;
                                            }
                                          } else {
                                            _selectedMaterialPorts.clear();
                                          }
                                        });
                                      },
                                    ),
                                    const Divider(),

                                    // Sorted material checkboxes
                                    ...materialCheckboxes,
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("CLOSE"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            setState(() {}); // refresh main screen TextField
                          },
                          child: const Text("DONE"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Select Material",
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                  controller: TextEditingController(
                    text: _selectedMaterialPorts.keys.map((e) => e.toUpperCase()).join(", "),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget buildLocationRowField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label on the left
          Flexible(
            flex: 3,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 100),
              child: const Text(
                "Location Port",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // TextField on the right
          Flexible(
            flex: 7,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: const Text("Select Location Port"),
                      content: SizedBox(
                        width: double.maxFinite,
                        height: 400,
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            child: StatefulBuilder(
                              builder: (BuildContext context, StateSetter setStateDialog) {
                                bool allSelected = _selectedLocationPorts.length == _locationPortList.length;

                                final sortedLocationList = _locationPortList
                                    .map((loc) => {
                                  'name': loc['name']!.trim(), // remove extra spaces
                                  'id': loc['id']!
                                })
                                    .toList();

                                sortedLocationList.sort(
                                        (a, b) => a['name']!.toLowerCase().compareTo(b['name']!.toLowerCase())
                                );

                                // Build checkboxes
                                final locationCheckboxes = sortedLocationList.map((loc) {
                                  final name = loc['name']!;
                                  final id = loc['id']!;
                                  return CheckboxListTile(
                                    title: Text(name.toUpperCase()),
                                    value: _selectedLocationPorts.containsKey(name),
                                    onChanged: (bool? value) {
                                      setStateDialog(() {
                                        if (value == true) {
                                          _selectedLocationPorts[name] = id;
                                        } else {
                                          _selectedLocationPorts.remove(name);
                                        }
                                      });
                                    },
                                  );
                                }).toList();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Select All Checkbox
                                    CheckboxListTile(
                                      title: const Text(
                                        "Select All",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      value: allSelected,
                                      onChanged: (bool? value) {
                                        setStateDialog(() {
                                          if (value == true) {
                                            for (var loc in _locationPortList) {
                                              _selectedLocationPorts[loc['name']!] = loc['id']!;
                                            }
                                          } else {
                                            _selectedLocationPorts.clear();
                                          }
                                        });
                                      },
                                    ),
                                    const Divider(),

                                    // Sorted location checkboxes
                                    ...locationCheckboxes,
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("CLOSE"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            setState(() {}); // refresh main screen TextField
                          },
                          child: const Text("DONE"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Select Location Port",
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                  controller: TextEditingController(
                    text: _selectedLocationPorts.keys.map((e) => e.toUpperCase()).join(", "),
                  ),
                ),
              ),
            ),
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
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            //   child: Row(
            //     children: [
            //       Expanded(
            //         flex: 3,// Fixed width for the label, adjust as needed
            //         child: Text(
            //           "Employee Code",
            //           style: TextStyle(
            //             color: Colors.black,
            //             fontWeight: FontWeight.w500,
            //           ),
            //         ),
            //       ),
            //       Expanded(
            //         flex: 7,
            //         child:  TextField(
            //           controller: employeeCodeController,
            //           decoration: InputDecoration(
            //             contentPadding: const EdgeInsets.all(10),
            //             border: OutlineInputBorder(
            //               borderRadius: BorderRadius.circular(12),
            //             ),
            //           ),
            //           readOnly: true,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            buildDropdown("User Type", UserTypes, (value) {
              setState(() {
                selectedUserType = value;
              });
            }),

            buildSearchableDropdown(
              "Full Name",
              selectedEmployeeId,
                  (value) {
                setState(() {
                  selectedEmployeeId = value;
                  fetchEmployeeDetails(selectedEmployeeId);
                });
              },
              employees, // Pass the list of employees
              _employeeController, // Pass the controller to the widget.
            ),
            SizedBox(height: 6),
            buildTypeAheadDropdownorganization(
              label: "Organization",
              items: _organizationOptions,
              controller: _organizationController,
              selectedValues: _selectedorganizationValues,
            ),
            buildLocationRowField(),
            buildMaterialRowField(),


            buildVendorRowField(),

            buildPlantRowField(),

            // _buildTextField("Full Name", fullNameController),
            _buildTextField('Aadhaar Number', adharNumberController),

            // _buildTextField('Email ID', emailIdController),
            _buildTextField('Username', usernameController),
            _buildTextField('Password', passwordController),
            // _buildCheckboxWithOptions('Website Login?', isActiveYes, isActiveNo,
            //     (bool? yesChecked) {
            //   setState(() {
            //     isActiveYes = yesChecked ?? false;
            //     isActiveNo = !yesChecked! ?? true;
            //   });
            // }, isMandatory: true),
            _buildCheckboxWithOptions('Active?', isActiveYes, isActiveNo,
                    (bool? yesChecked) {
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
              'Access Seal Data?',
              hasAccessSealDataYes,
              hasAccessSealDataNo ,
                  (bool? yesChecked) {
                setState(() {
                  hasAccessSealDataYes = yesChecked ?? false;
                  hasAccessSealDataNo  = !(yesChecked ?? true);
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

            _buildCheckboxWithOptions(
              'Read Only User?',
              isReadOnlyYes,
              isReadOnlyNo,
                  (bool? yesChecked) {
                setState(() {
                  isReadOnlyYes = yesChecked ?? false;
                  isReadOnlyNo = !yesChecked! ?? true;
                });
              },
              isMandatory: true,
            ),

            _buildCheckboxWithOptions(
              'Only Attendance?',
              isOnlyAttendYes,
              isOnlyAttendNo,
                  (bool? yesChecked) {
                setState(() {
                  isOnlyAttendYes = yesChecked ?? false;
                  isOnlyAttendNo = !yesChecked! ?? true;
                });
              },
              isMandatory: true,
            ),

            // buildCheckboxDropdownOrganization(
            //   label: "Organization",
            //   items: _organizationList,
            //   selectedValues: _selectedorganizationValues,
            // ),

            // buildCheckboxListPlant(
            //   label: "Plant Name",
            //   items: _locationList,  // Yeh list API se aayege
            //   selectedValues: _selectedLocationValues,
            //   selectedLocations: _selectedLocations,
            // ),

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
                  padding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8), // Consistent padding
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

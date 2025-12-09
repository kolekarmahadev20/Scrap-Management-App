import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import '../../AppClass/AppDrawer.dart';
import '../../AppClass/appBar.dart';
import '../../URL_CONSTANT.dart';
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
    'SA': 'Sub Admin',
    'U': 'User'
  };



  // Controllers for the text fields
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController adharNumberController = TextEditingController();
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

  bool hasAccessSealDataYes = false;
  bool hasAccessSealDataNo = false;

  bool isRefundYes = false;
  bool isRefundNo = false;
  bool isReceiverYes = false;
  bool isReceiverNo = false;
  bool isPaymentYes = false;
  bool isPaymentNo = false;

  bool isReadOnlyYes = false;
  bool isReadOnlyNo = false;

  bool isOnlyAttendYes = false;
  bool isOnlyAttendNo = false;

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


    // print(widget.user.vendorId);
    // print(widget.user.plantId);
    print(widget.user.orgID!);
    print("asasvsa");

    print('widget.user.userType');

    print(widget.user.userType);

    if (widget.user.userType != 'NA') {
      selectedUserType = widget.user.userType ?? '';
    }


    adharNumberController.text = widget.user.adharNum??'';
    employeeCodeController.text = widget.user.empCode??'';
    fullNameController.text = widget.user.personName??'';
    emailIdController.text = widget.user.empEmail??'';
    usernameController.text = widget.user.username??'';
    passwordController.text = widget.user.cPass??'';
    uuIDController.text = widget.user.uuid??'';

    isOnlyAttendYes= widget.user.attendance_only == 'Y';
    isOnlyAttendNo = widget.user.attendance_only != 'Y';

    isReadOnlyYes = widget.user.read_only == 'Y';
    isReadOnlyNo = widget.user.read_only != 'Y';

    isActiveYes = widget.user.isActive == 'Y';
    isActiveNo = widget.user.isActive != 'Y';
    isMobileLoginYes = widget.user.isMobile == 'Y';
    isMobileLoginNo =  widget.user.isMobile != 'Y';
    hasAccessSaleOrderDataYes = widget.user.accesSaleOrder == 'Y';
    hasAccessSaleOrderDataNo = widget.user.accesSaleOrder != 'Y';

    hasAccessSealDataYes = widget.user.access_seal == 'Y';
    hasAccessSealDataNo = widget.user.access_seal != 'Y';

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

    // emailIdController.addListener(() {
    //   final email = emailIdController.text.trim();
    //   if (email.isNotEmpty && email.contains("@")) {
    //     generateUsernameAndPassword(email);
    //   }
    // });

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
      await checkLogin();  // Ensure user is logged in

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
          Fluttertoast.showToast(msg:"This aadhar card number is already registered"); // Show toast message
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


  Future<void> _addUsers() async {
    if (selectedUserType == null || selectedUserType.toString().isEmpty) {
      Fluttertoast.showToast(msg: "Please select a User Type");
      return;
    }

    final vendorIds = _selectedVendors.values.toList();
    final plantIds = _selectedLocations.values.toList();
    final locationportIds = _selectedLocationPorts.values.toList();
    final materialportIds = _selectedMaterialPorts.values.toList();
    final organizationIds = _selectedOrganization.values.toList();
    final organizationIdsString = organizationIds.join(',');

    try {
      await checkLogin();

      final url = '${URL}edit_user';

      // 🔹 Build request body with all values as String
      final Map<String, String> body = {
        'user_id': username.toString(),
        'user_pass': password.toString(),
        'uuid': uuid.toString(),
        'emp_code': (employeeCodeController.text ?? '').toString(),
        'user_type': selectedUserType.toString(),
        'uname': (usernameController.text ?? '').toString(),
        'c_pass': (passwordController.text ?? '').toString(),

        'read_only': (isReadOnlyYes ? 'Y' : 'N').toString(),
        'attendance_only': (isOnlyAttendYes ? 'Y' : 'N').toString(),
        'is_active': (isActiveYes ? 'Y' : 'N').toString(),
        'mob_login': (isMobileLoginYes ? 'Y' : 'N').toString(),
        'acces_sale_order': (hasAccessSaleOrderDataYes ? 'Y' : 'N').toString(),
        'acces_dispatch': (isDispatchYes ? 'Y' : 'N').toString(),
        'acces_payment': (isPaymentYes ? 'Y' : 'N').toString(),
        'acces_refund': (isRefundYes ? 'Y' : 'N').toString(),
        'vendor_id': vendorIds.join(',').toString(),
        'plant_id': plantIds.join(',').toString(),
        'location_port_id': locationportIds.join(',').toString(),
        'material_port_id': materialportIds.join(',').toString(),
        'access_seal': (hasAccessSealDataYes ? 'Y' : 'N').toString(),
        'org_id': organizationIdsString.toString(),
        'person_name': (fullNameController.text ?? '').toString(),
        'email': (emailIdController.text ?? '').toString(),
        'uuiid': (uuIDController.text ?? '').toString(),
        'person_id': widget.user.personId.toString(),
        'adhar_num': (adharNumberController.text ?? '').toString(),
        'is_mobile': (isMobileLoginYes ? 'Y' : 'N').toString(),
        'is_desktop': ((selectedUserType == 'S' || selectedUserType == 'A') ? 'Y' : 'N').toString(),
        'is_all': ((isMobileLoginYes == 'N') ? 'Y' : 'N').toString(),
      };

      // 🔹 Print all values (guaranteed, no skips)
      print("======== Request Fields ========");
      body.forEach((key, value) {
        print("$key: $value");
      });
      print("================================");

      // 🔹 Send request
      final response = await http.post(
        Uri.parse(url),
        body: body,
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Pretty print JSON
        print("======== Response JSON ========");
        const JsonEncoder encoder = JsonEncoder.withIndent('  ');
        print(encoder.convert(data));
        print("================================");

        Fluttertoast.showToast(msg: "Employee saved successfully");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => view_user(currentPage: 0)),
        );
      } else {
        Fluttertoast.showToast(msg: "Failed to save employee");
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
          final materialportList = data['material_port'] as List?;
          final locationportList = data['location_port'] as List?;

          setState(() {
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

            //materialport
            if (materialportList != null) {
              for (var materialport in materialportList) {
                final materialName = materialport['material_name'];
                final materialId = materialport['material_id'];
                _materialPortList.add({"id": materialId, "name": materialName});
                _materialPortOptions.add(materialName);
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
            // if (widget.user.vendorId != null && widget.user.vendorId!.isNotEmpty && widget.user.vendorId != 'NA')
            _prefillSelectedVendors();
            _prefillSelectedLocationPorts();
            _prefillSelectedMaterialPorts();
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

  void _prefillSelectedMaterialPorts() {
    if (widget.user.material_port_id != null && widget.user.material_port_id!.isNotEmpty) {
      List<String> selectedMaterialPortIds = widget.user.material_port_id!.split(',');

      for (var id in selectedMaterialPortIds) {
        final materialPort = _materialPortList.firstWhere(
              (mp) => mp['id'].toString() == id.trim(),
          orElse: () => {},
        );

        if (materialPort.isNotEmpty) {
          // Avoid duplicates in selected material ports
          if (!_selectedMaterialPortValues.contains(materialPort['name'])) {
            _selectedMaterialPortValues.add(materialPort['name']!);
            _selectedMaterialPorts[materialPort['name']!] = materialPort['id']!;
          }
        }
      }

      print("Final Selected Material Ports: $_selectedMaterialPortValues");
      print("Selected Material Port Map: $_selectedMaterialPorts");

      setState(() {}); // Update UI
    }
  }


  void _prefillSelectedLocationPorts() {
    if (widget.user.location_port_id != null && widget.user.location_port_id!.isNotEmpty) {
      List<String> selectedLocationPortIds = widget.user.location_port_id!.split(',');

      for (var id in selectedLocationPortIds) {
        final locationPort = _locationPortList.firstWhere(
              (lp) => lp['id'].toString() == id.trim(),
          orElse: () => {},
        );

        if (locationPort.isNotEmpty) {
          // Avoid duplicates in selected location ports
          if (!_selectedLocationPortValues.contains(locationPort['name'])) {
            _selectedLocationPortValues.add(locationPort['name']!);
            _selectedLocationPorts[locationPort['name']!] = locationPort['id']!;
          }
        }
      }

      print("Final Selected Location Ports: $_selectedLocationPortValues");
      print("Selected Location Port Map: $_selectedLocationPorts");

      setState(() {}); // Update UI
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
    print("Debug: _fetchPlants() called");
    print("Selected Vendors Map: $selectedVendors");

    final vendorIds = selectedVendors.values.toList();  // Extract IDs
    print("Debug: Extracted vendor IDs: $vendorIds");

    final vendorIdsString = vendorIds.join(',');
    print("Debug: Concatenated vendor IDs string: $vendorIdsString");

    try {
      await checkLogin();
      final url = '${URL}fetch_plant';

      final requestBody = {
        'user_id': username,
        'user_pass': password,
        'uuid': uuid,
        'vendor_id': vendorIdsString,
      };

      // Debug: Log the request body before sending
      print("Debug: Request Body being sent -> $requestBody");

      final response = await http.post(
        Uri.parse(url),
        body: requestBody,
      );

      // Debug: Log the status code and body of the response
      print("Debug: Response Status Code: ${response.statusCode}");

      setState(() {
        _locationList.clear();
        _locationOptions.clear();
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Debug: Log the response data for inspection
        print("Debug: Response Body (Success) -> $data");

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

          _prefillSelectedLocations();

        } else {
          print("Debug: Response data is null or 'plants' not found.");
        }
      } else {
        print("Debug: Failed to fetch plants. Status Code: ${response.statusCode}");
        print("Debug: Response Body (Failure) -> ${response.body}");
      }
    } catch (e) {
      print("Debug: Error fetching plants: $e");
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

      // _fetchPlants(_selectedLocations);
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

      print(widget.user.orgID!);
      print("asasvsa");

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

  //
  // void _prefillSelectedOrganizations() {
  //   if (widget.user.orgID != null && widget.user.orgID!.isNotEmpty) {
  //     List<String> selectedOrgIds = widget.user.orgID!.split(',');
  //
  //     print("🔹 Raw orgID from widget.user: ${widget.user.orgID}");
  //     print("🔹 Split selectedOrgIds: $selectedOrgIds");
  //
  //     for (var id in selectedOrgIds) {
  //       print("➡️ Checking org ID: $id");
  //
  //       final org = _organizationList.firstWhere(
  //             (org) => org['id'].toString().trim() == id.trim(),
  //         orElse: () => {},
  //       );
  //
  //       if (org.isNotEmpty) {
  //         print("✅ Found matching organization: ${org['name']} (ID: ${org['id']})");
  //
  //         // **Store IDs Instead of Names**
  //         if (!_selectedorganizationValues.contains(org['id'].toString())) {
  //           _selectedorganizationValues.add(org['id'].toString()); // ✅ Use ID instead of name
  //         } else {
  //           print("⚠️ Duplicate found, skipping: ${org['name']}");
  //         }
  //       } else {
  //         print("❌ No matching organization found for ID: $id");
  //       }
  //     }
  //
  //     setState(() {
  //       print("🔄 UI Updated with selected organizations: $_selectedorganizationValues");
  //     });
  //   } else {
  //     print("⚠️ widget.user.orgID is null or empty.");
  //   }
  // }




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

  //multiple selction
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
  //             return CheckboxListTile(
  //               title: Text(vendorName),
  //               value: selectedVendors.containsKey(vendorName),
  //               onChanged: (bool? value) {
  //                 setState(() {
  //                   if (value == true) {
  //                     selectedVendors[vendorName] = vendorId;
  //                   } else {
  //                     selectedVendors.remove(vendorName);
  //                   }
  //                   _fetchPlants(selectedVendors); // Map<String, String> pass karna hai
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
    bool allSelectedMaterialPort = selectedMaterialPort.length == items.length;

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
                value: allSelectedMaterialPort,
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
                                  'name': vendor['name']!.trim(),
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
                                  'name': loc['name']!.trim(),
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

  Widget buildCheckboxListPlant({
    required String label,
    required List<Map<String, String>> items, // Location list with name & id
    required List<String> selectedValues,
    required Map<String, String> selectedLocations,
  }) {
    bool allSelected = selectedValues.length == items.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
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
                      selectedValues.clear();
                      selectedLocations.clear();
                      for (var location in items) {
                        final name = location['name']!;
                        final id = location['id']!;
                        selectedValues.add(name);
                        selectedLocations[name] = id;
                      }
                    } else {
                      selectedValues.clear();
                      selectedLocations.clear();
                    }
                  });
                },
              ),
              Divider(height: 1),
              // Individual checkboxes
              ...items.map((location) {
                final locationName = location['name']!;
                final locationId = location['id']!;

                return CheckboxListTile(
                  title: Text(locationName),
                  value: selectedValues.contains(locationName),
                  onChanged: (bool? isChecked) {
                    setState(() {
                      if (isChecked == true) {
                        selectedValues.add(locationName);
                        selectedLocations[locationName] = locationId;
                      } else {
                        selectedValues.remove(locationName);
                        selectedLocations.remove(locationName);
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


  // Widget buildCheckboxListPlant({
  //   required String label,
  //   required List<Map<String, String>> items, // Location list with name & id
  //   required List<String> selectedValues,
  //   required Map<String, String> selectedLocations,
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
  //         padding: EdgeInsets.all(8.0),
  //         decoration: BoxDecoration(
  //           border: Border.all(color: Colors.grey),
  //           borderRadius: BorderRadius.circular(8.0),
  //         ),
  //         child: Column(
  //           children: items.map((location) {
  //             final locationName = location['name']!;
  //             final locationId = location['id']!;
  //
  //             return CheckboxListTile(
  //               title: Text(locationName),
  //               value: selectedValues.contains(locationName),
  //               onChanged: (bool? isChecked) {
  //                 setState(() {
  //                   if (isChecked == true) {
  //                     selectedValues.add(locationName);
  //                     selectedLocations[locationName] = locationId;
  //                   } else {
  //                     selectedValues.remove(locationName);
  //                     selectedLocations.remove(locationName);
  //                   }
  //                 });
  //               },
  //             );
  //           }).toList(),
  //         ),
  //       ),
  //       // SizedBox(height: 10),
  //       // InputDecorator(
  //       //   decoration: InputDecoration(
  //       //     labelText: "$label Selected",
  //       //     border: OutlineInputBorder(),
  //       //   ),
  //       //   child: Wrap(
  //       //     spacing: 8.0,
  //       //     runSpacing: 4.0,
  //       //     children: selectedValues.map((value) {
  //       //       return Chip(
  //       //         label: Text(value),
  //       //         deleteIcon: Icon(Icons.close),
  //       //         onDeleted: () {
  //       //           setState(() {
  //       //             selectedValues.remove(value);
  //       //             selectedLocations.remove(value);
  //       //           });
  //       //         },
  //       //       );
  //       //     }).toList(),
  //       //   ),
  //       // ),
  //       SizedBox(height: 20),
  //     ],
  //   );
  // }

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
                padding: EdgeInsets.only(right: 8), // Adjust left padding to shift left
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
                          contentPadding: EdgeInsets.symmetric(vertical: 7, horizontal: 12),
                        ),
                      ),
                      suggestionsCallback: (pattern) {
                        return items
                            .where((item) => item.toLowerCase().contains(pattern.toLowerCase()))
                            .toList();
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion, style: TextStyle(fontSize: 14)),
                          dense: true,
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
  //             final orgId = org['id']!; // ✅ Ensure ID is used
  //             return CheckboxListTile(
  //               title: Text(orgName),
  //               value: selectedValues.contains(orgId), // ✅ Now IDs will match correctly
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
              _buildTextField("Full Name", fullNameController),
              SizedBox(height:6),
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

              // if (_selectedVendors.isNotEmpty)
              //   _locationList.isNotEmpty
              //       ? buildCheckboxListPlant(
              //     label: "Plant Name",
              //     items: _locationList,
              //     selectedValues: _selectedLocationValues,
              //     selectedLocations: _selectedLocations,
              //   )
              //       : Padding(
              //     padding: const EdgeInsets.all(8.0),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text(
              //           "Plant Name",
              //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              //         ),
              //         Text(
              //           "No Plant Found",
              //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              //         ),
              //       ],
              //     ),
              //   ),

              _buildTextField('Aadhaar Number', adharNumberController),
              // _buildTextField('Email ID', emailIdController),
              _buildTextField('Username', usernameController),
              _buildTextField('Password', passwordController),
              // _buildCheckboxWithOptions('Website Login?', isActiveYes, isActiveNo, (bool? yesChecked) {
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
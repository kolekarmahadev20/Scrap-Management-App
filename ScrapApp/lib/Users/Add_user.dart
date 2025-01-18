
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

  // Add these variables to store original username and password
  String _originalUsername = '';
  String _originalPassword = '';

  Map<String, String> userTypeMap = {
    'S': 'Super Admin',
    'A': 'Admin',
    'U': 'User With Delete',
    'I': 'User Without Delete',
  };

  List<String> userTypes = ['Select User Type', 'Super Admin', 'Admin', 'User With Delete', 'User Without Delete'];

  String selectedUserType = 'Select User Type';

  bool isLoading = false;

  // Controllers for the text fields
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailIdController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController uuIDController = TextEditingController();

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

  bool isActiveYes = false;
  bool isActiveNo = false;
  bool isMobileLoginYes = false;
  bool isMobileLoginNo = false;
  bool hasAccessSealDataYes = false;
  bool hasAccessSealDataNo = false;
  bool isSenderYes = false;
  bool isSenderNo = false;
  bool isReceiverYes = false;
  bool isReceiverNo = false;
  bool isReadOnlyUserYes = false;
  bool isReadOnlyUserNo = false;
  bool hasAccessScrapDataYes = false;
  bool hasAccessScrapDataNo = false;
  bool hasAccessGPSYes = false;
  bool hasAccessGPSNo = false;

  Map<String, String> plantIdToName = {}; // Map to store plant IDs and names
  Map<String, String> materialIdToName = {}; // Map to store material IDs and names

  List<String> plantOptions = [];
  List<String> materialOptions = [];

  Set<String> selectedPlantIds = Set();
  Set<String> selectedMaterialIds = Set();

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the widget tree
    fullNameController.dispose();
    emailIdController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    uuIDController.dispose();
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

      // // Store the original username and password
      // _originalUsername = _username;
      // _originalPassword = _password;

    });

    if (_isloggedin == false) {
      // ignore: use_build_context_synchronously
    }
  }

  void updateSelectedUserType(String? newValue) {
    setState(() {
      selectedUserType = newValue ?? 'Select User Type';
    });
  }

  @override
  void initState() {
    super.initState();
    dropdown();
  }

  void _clearFields() {
    fullNameController.clear();
    emailIdController.clear();
    usernameController.clear();
    passwordController.clear();
    uuIDController.clear();
    setState(() {
      selectedUserType = 'Select User Type';
      isActiveYes = false;
      isActiveNo = false;
      isMobileLoginYes = false;
      isMobileLoginNo = false;
      hasAccessSealDataYes = false;
      hasAccessSealDataNo = false;
      isSenderYes = false;
      isSenderNo = false;
      isReceiverYes = false;
      isReceiverNo = false;
      isReadOnlyUserYes = false;
      isReadOnlyUserNo = false;
      hasAccessScrapDataYes = false;
      hasAccessScrapDataNo = false;
      hasAccessGPSYes = false;
      hasAccessGPSNo = false;
      selectedPlantIds.clear();
      selectedMaterialIds.clear();
    });
  }



  void dropdown() async {
    try {
      await _getUserDetails();

      // API endpoint URL
      var apiUrl = '$URL/Mobile_flutter_api/get_dropdown_data';
      // API request parameters
      var params = {
        'uuid': _uuid,
        'user_id': _username,
        'password': _password,
      };

      // Make POST request
      var response = await http.post(Uri.parse(apiUrl), body: params);

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Parse JSON response
        var jsonResponse = jsonDecode(response.body);

        // Check if status is 1 and data exists
        if (jsonResponse['status'] == "1") {
          var plantData = jsonResponse['plant'] as List<dynamic>;
          var materialData = jsonResponse['material'] as List<dynamic>;

          // Update plantOptions with plant names and map plant IDs to names
          setState(() {
            plantOptions = plantData.map((plant) {
              var id = plant['plant_id'].toString();
              var name = plant['plant_name'].toString();
              plantIdToName[id] = name;
              return name;
            }).toList();

            // Update materialOptions with material names and map material IDs to names
            materialOptions = materialData.map((material) {
              var id = material['material_id'].toString();
              var name = material['material_name'].toString();
              materialIdToName[id] = name;
              return name;
            }).toList();
          });
        } else {
          // Handle case when status is not 1
          print('Error: Status is not 1');
        }
      } else {
        // Handle other status codes here (e.g., show error message)
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions (e.g., network error)
      print('Exception occurred: $e');
    }
  }

  void _saveUserData() async {
    setState(() {
      isLoading = true; // Set loading to true before making the API call
    });

    try {
      await _getUserDetails();

      // Determine the user_type based on selectedUserType
      String userTypeKey = userTypeMap.entries.firstWhere((entry) => entry.value == selectedUserType,
          orElse: () => MapEntry('S', 'Super Admin')).key;

      // API endpoint URL
      var apiUrl = '$URL/Mobile_flutter_api/add_edit_user_data';

      // API request parameters
      var params = {
        'uuid': _uuid,
        'user_id': _username,
        'password': _password,
        'user_type': userTypeKey,
        'full_name': fullNameController.text,
        'email': emailIdController.text,
        'username': usernameController.text,
        'pass': passwordController.text,
        'active_user': isActiveYes ? '1' : '0',
        'allowed_mobile_login': isMobileLoginYes ? '1' : '0',
        'access_seal_data': hasAccessSealDataYes ? '1' : '0',
        'sender': isSenderYes ? '1' : '0',
        'receiver': isReceiverYes ? '1' : '0',
        'readonly': isReadOnlyUserYes ? '1' : '0',
        'access_scrap_data': hasAccessScrapDataYes ? '1' : '0',
        'access_gps_module': hasAccessGPSYes ? '1' : '0',
        'material': selectedMaterialIds.join(','),
        'plant': selectedPlantIds.join(','),
        'mid': uuIDController.text,
      };

      // Make POST request
      var response = await http.post(Uri.parse(apiUrl), body: params);

      // Log the entire response body for debugging
      print('Response body: ${response.body}');

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Parse JSON response
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == "success") {
          // Handle successful response
          Fluttertoast.showToast(
            msg: "User data saved successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );

          // // Check if username or password has changed
          // if (_originalUsername != _full_name || _originalPassword != _password) {
          //
          //     // Clear shared preferences and navigate to login screen
          //     SharedPreferences prefs = await SharedPreferences.getInstance();
          //     await prefs.clear();
          //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
          //     return;
          //
          // }

          Navigator.pop(context);

          // Navigator.push(
          //     context, MaterialPageRoute(builder: (context) => view_user()));

          // Show success message or navigate to another screen
        } else {
          // Handle API error response
          print('Failed to save user data: ${jsonResponse['message']}');
          Fluttertoast.showToast(
            msg: "Failed to save user data: ${jsonResponse['message']}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          // Show error message to the user
        }
      } else {
        // Handle other status codes
        print('Request failed with status: ${response.statusCode}');
        Fluttertoast.showToast(
          msg: "Failed to save user data. Status Code: ${response.statusCode}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        // Show error message to the user
      }
    } catch (e) {
      // Handle any exceptions
      print('Exception occurred: $e');
      Fluttertoast.showToast(
        msg: "Exception occurred: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      // Show error message to the user
    } finally {
      setState(() {
        isLoading = false; // Set loading to false after the API call
      });
    }
  }


  bool areMandatoryFieldsFilled() {
    // Check if all mandatory fields are filled
    return fullNameController.text.isNotEmpty &&
        emailIdController.text.isNotEmpty &&
        usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        selectedUserType != 'Select User Type' &&
        (isActiveYes || isActiveNo) &&
        (isMobileLoginYes || isMobileLoginNo) &&
        (hasAccessSealDataYes || hasAccessSealDataNo) &&
        (isSenderYes || isSenderNo) &&
        (isReceiverYes || isReceiverNo) &&
        (isReadOnlyUserYes || isReadOnlyUserNo) &&
        (hasAccessScrapDataYes || hasAccessScrapDataNo) &&
        (hasAccessGPSYes || hasAccessGPSNo) &&
        selectedPlantIds.isNotEmpty &&
        selectedMaterialIds.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    bool isEnabled = areMandatoryFieldsFilled(); // Determine if save button should be enabled

    return Scaffold(
      drawer: AppDrawer(currentPage: 0),
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildCreativeCard('Add User Details'),
            SizedBox(height: 12),
            _buildDropdownField('User Type', userTypes, selectedUserType, updateSelectedUserType, isMandatory: true),
            _buildTextField('Full Name', fullNameController, isMandatory: true),
            _buildTextField('Email ID', emailIdController, isMandatory: true),
            _buildTextField('Username', usernameController, isMandatory: true),
            _buildTextField('Password', passwordController, isMandatory: true),
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
              'Access Seal Data?',
              hasAccessSealDataYes,
              hasAccessSealDataNo,
                  (bool? yesChecked) {
                setState(() {
                  hasAccessSealDataYes = yesChecked ?? false;
                  hasAccessSealDataNo = !(yesChecked ?? true);
                });
              },
              isMandatory: true,
            ),
            _buildCheckboxWithOptions(
              'Sender?',
              isSenderYes,
              isSenderNo,
                  (bool? yesChecked) {
                setState(() {
                  isSenderYes = yesChecked ?? false;
                  isSenderNo = !yesChecked! ?? true;
                });
              },
              isMandatory: true,
            ),
            _buildCheckboxWithOptions(
              'Receiver?',
              isReceiverYes,
              isReceiverNo,
                  (bool? yesChecked) {
                setState(() {
                  isReceiverYes = yesChecked ?? false;
                  isReceiverNo = !yesChecked! ?? true;
                });
              },
              isMandatory: true,
            ),
            _buildCheckboxWithOptions(
              'Read Only User?',
              isReadOnlyUserYes,
              isReadOnlyUserNo,
                  (bool? yesChecked) {
                setState(() {
                  isReadOnlyUserYes = yesChecked ?? false;
                  isReadOnlyUserNo = !yesChecked! ?? true;
                });
              },
              isMandatory: true,
            ),
            _buildCheckboxWithOptions(
              'Access Scrap Data?',
              hasAccessScrapDataYes,
              hasAccessScrapDataNo,
                  (bool? yesChecked) {
                setState(() {
                  hasAccessScrapDataYes = yesChecked ?? false;
                  hasAccessScrapDataNo = !(yesChecked ?? true);
                });
              },
              isMandatory: true,
            ),
            _buildCheckboxWithOptions(
              'Access GPS?',
              hasAccessGPSYes,
              hasAccessGPSNo,
                  (bool? yesChecked) {
                setState(() {
                  hasAccessGPSYes = yesChecked ?? false;
                  hasAccessGPSNo = !(yesChecked ?? true);
                });
              },
              isMandatory: true,
            ),
            _buildDynamicCheckboxes('Material', materialIdToName, selectedMaterialIds, (selectedOptions) {
              setState(() {
                selectedMaterialIds = selectedOptions;
              });
            }, isMandatory: true),
            SizedBox(height: 12),
            _buildDynamicCheckboxes('Plant', plantIdToName, selectedPlantIds, (selectedOptions) {
              setState(() {
                selectedPlantIds = selectedOptions;
              });
            }, isMandatory: true),
            _buildTextField('UUID', uuIDController),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                isLoading
                    ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : _buildButton('Save', Colors.lightBlue.shade200, _saveUserData, isEnabled: isEnabled),
              ],
            ),
          ],
        ),
      ),
    );
  }




  Widget _buildCreativeCard(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1.0, color: Colors.grey),
          bottom: BorderSide(width: 1.0, color: Colors.grey),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              color: Colors.black,
              size: 30,
            ),
            SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isMandatory = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 150,
            child: RichText(
              text: TextSpan(
                text: label,
                style: TextStyle(color: Colors.black),
                children: isMandatory
                    ? [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ]
                    : [],
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 40,
              child: TextField(
                style: TextStyle(fontSize: 16),
                cursorWidth: 1.0,
                cursorHeight: 20.0,
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxWithOptions(String label, bool yesValue, bool noValue, Function(bool?) onChanged, {bool isMandatory = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(color: Colors.black),
              children: isMandatory
                  ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ]
                  : [],
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

  Widget _buildDynamicCheckboxes(String label, Map<String, String> idToNameMap, Set<String> selectedIds, void Function(Set<String>) onChanged, {bool isMandatory = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(color: Colors.black),
            children: isMandatory
                ? [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ]
                : [],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: idToNameMap.entries.map((entry) {
            var id = entry.key;
            var name = entry.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(name),
                SizedBox(width: 5),
                Checkbox(
                  value: selectedIds.contains(id),
                  onChanged: (value) {
                    setState(() {
                      if (value ?? false) {
                        selectedIds.add(id);
                      } else {
                        selectedIds.remove(id);
                      }
                      onChanged(selectedIds);
                    });
                  },
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String selectedValue, void Function(String?) onChanged, {bool isMandatory = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 150,
            child: RichText(
              text: TextSpan(
                text: label,
                style: TextStyle(color: Colors.black),
                children: isMandatory
                    ? [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ]
                    : [],
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedValue,
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.black),
                onChanged: onChanged,
                items: items.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed, {required bool isEnabled}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
      ),
      onPressed: isEnabled ? onPressed : null, // Enable or disable button based on isEnabled
      child: Text(text),
    );
  }

}
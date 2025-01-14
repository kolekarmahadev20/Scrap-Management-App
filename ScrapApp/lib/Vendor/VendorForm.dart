import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';
import '../URL_CONSTANT.dart';
import 'Vendor_list.dart';

class VendorForm extends StatefulWidget {
  @override
  _VendorFormState createState() => _VendorFormState();
}

class _VendorFormState extends State<VendorForm> {
  final TextEditingController vendorNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController gstNumberController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  List<TextEditingController> phoneControllers = [];
  List<TextEditingController> emailControllers = [];

  //Variables for user details
  String? username = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';

  bool isActive = false;

  @override
  void initState() {
    super.initState();
    checkLogin();
    phoneControllers.add(TextEditingController());
    emailControllers.add(TextEditingController());
    // Fetch data from API and populate controllers if needed
  }

  //Fetching user details from sharedpreferences
  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
  }

  Future<void> _addVendorDetails() async {

    // Check if the necessary fields are filled
    if (pinCodeController.text.isEmpty ||
        remarksController.text.isEmpty ||
        isActive == null ||
        phoneControllers.isEmpty ||
        emailControllers.isEmpty) {
      // Print an error message or show a toast to the user
      Fluttertoast.showToast(
        msg: "Please fill all required fields.",
        fontSize: 16.0,
      );
      return; // Exit the function without making the API call
    }

    await checkLogin();

    // Printing the values to be passed
    print('user_id: $username');
    print('user_pass: $password');
    print('auctioneer_name: ${vendorNameController.text ?? ""}');
    print('address: ${addressController.text ?? ""}');
    print('country: ${countryController.text ?? ""}');
    print('state: ${stateController.text ?? ""}');
    print('city: ${cityController.text ?? ""}');
    print('pin_code: ${pinCodeController.text ?? ""}');
    print('gst_no: ${gstNumberController.text ?? ""}');
    print('remarks: ${remarksController.text ?? ""}');
    print('is_active_hidden: ${isActive == true ? 'Y' : 'N'}');
    print('phone[]: ${phoneControllers.map((controller) => controller.text).join(',')}');
    print('email[]: ${emailControllers.map((controller) => controller.text).join(',')}');


    final url = '${URL}add_vendor';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'user_id': username,
        'user_pass': password,
        'auctioneer_name':vendorNameController.text??'',
        'address':addressController.text??'',
        'country':countryController.text??'',
        'state':stateController.text??'',
        'city':cityController.text ?? '',
        'pin_code':pinCodeController.text ?? '',
        'gst_no':gstNumberController.text ?? '',
        'remarks':remarksController.text ?? '',
        'is_active_hidden':isActive == true ? 'Y' : 'N',
        'phone[]]': phoneControllers.map((controller) => controller.text).join(','),
        'email[]': emailControllers.map((controller) => controller.text).join(','),
      },
    );

    if (response.statusCode == 200) {
      print('Response bharat body: ${response.body}');
      final data = json.decode(response.body);

      // Show the toast with the msg value, regardless of status
      Fluttertoast.showToast(
        msg: data['msg'], // Display the message from the response
        fontSize: 16.0,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Vendor_list(currentPage: 0),
        ),
      );

      setState(() {

      });

    } else {
      throw Exception('Failed to load dropdown data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentPage: 0),
      appBar: CustomAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Vendor",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      elevation: 2,
                      color: Colors.white,
                      shape: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueGrey[400]!)
                      ),
                      child: Container(
                        child: Column(
                          children: [
                            SizedBox(height: 8,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "ADD VENDOR DETAILS",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8,),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField("Vendor Name", vendorNameController),
                  _buildTextField("Address", addressController),
                  _buildTextField("Country", countryController),
                  _buildTextField("State", stateController),
                  _buildTextField("City", cityController),
                  _buildTextField("Pin Code", pinCodeController),
                  _buildTextField("GST Number", gstNumberController),
                  _buildTextField("Remarks", remarksController),
                  _buildPhoneSection(),
                  _buildEmailSection(),
                  CheckboxListTile(
                    value: isActive,
                    title: Text("Is Active",style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),),
                    onChanged: (value) {
                      setState(() => isActive = value!);
                    },
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _addVendorDetails(); // Wait for the async function to complete
                      },
                      child: Text("Submit",style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent, // Button background color
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Compact padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4), // Smaller rounded corners
                        ),
                        elevation: 1, // Minimal shadow
                        fixedSize: Size(100, 36), // Optional: fixed size for consistency
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          Container(
            width: 120, // Fixed width for the label, adjust as needed
            child: Text(
              labelText,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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


  Widget _buildPhoneSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...phoneControllers.map((controller) {
          int index = phoneControllers.indexOf(controller);
          return Row(
            children: [
              Expanded(child: _buildTextField("Phone", controller)),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    phoneControllers.removeAt(index);
                  });
                },
              ),

            ],
          );
        }),
        Align(
          alignment: Alignment.bottomRight,
          child: IconButton(
            onPressed: () {
              setState(() {
                phoneControllers.add(TextEditingController());
              });
            },
            icon: Icon(Icons.add, color: Colors.white, size: 18), // Icon with custom size and color
            style: IconButton.styleFrom(
              backgroundColor: Colors.blueAccent, // Button background color
              padding: EdgeInsets.all(8), // Compact padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50), // Rounded corners
              ),
              elevation: 1, // Minimal shadow
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...emailControllers.map((controller) {
          int index = emailControllers.indexOf(controller);
          return Row(
            children: [
              Expanded(child: _buildTextField("Email", controller)),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    emailControllers.removeAt(index);
                  });
                },
              ),
            ],

          );
        }),
        Align(alignment: Alignment.bottomRight,
        child:  IconButton(
          onPressed: () {
            setState(() {
              emailControllers.add(TextEditingController());
            });
          },
          icon: Icon(Icons.add, color: Colors.white, size: 18), // Icon with custom size and color
          style: IconButton.styleFrom(
            backgroundColor: Colors.blueAccent, // Button background color
            padding: EdgeInsets.all(8), // Compact padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50), // Rounded corners
            ),
            elevation: 1, // Minimal shadow
          ),
        ),)
      ],
    );
  }
  
}

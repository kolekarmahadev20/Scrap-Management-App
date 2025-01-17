import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';
import '../URL_CONSTANT.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'Buyer_DomInterForm.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class Buyer_EditForm extends StatefulWidget {

  final String buyerID;
  final String country;
  final String gstNumber;
  final String finYear;
  final String buyerName;
  final String contactPerson;
  final String address;
  final String state;
  final String city;
  final String isActive;
  final String pinCode;
  final String pan;
  final String companyType;
  final String natureActivity;
  final String phone;
  final String email;
  final String CPCB;
  final String CPCBdate;
  final String SPCB;
  final String SPCBdate;
  final String? details;


  // Constructor to accept all the values
  Buyer_EditForm({
    required this.details,
    required this.CPCB,
    required this.CPCBdate,
    required this.SPCB,
    required this.SPCBdate,
    required this.companyType,
    required this.natureActivity,
    required this.phone,
    required this.email,
    required this.buyerID,
    required this.country,
    required this.gstNumber,
    required this.finYear,
    required this.buyerName,
    required this.address,
    required this.state,
    required this.city,
    required this.isActive,
    required this.pinCode,
    required this.pan,
    required this.contactPerson,
  });

  @override
  _Buyer_EditFormState createState() => _Buyer_EditFormState();
}

class _Buyer_EditFormState extends State<Buyer_EditForm> {
  final TextEditingController countryController = TextEditingController();
  final TextEditingController gstNoController = TextEditingController();
  final TextEditingController buyerNameController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController panController = TextEditingController();
  final TextEditingController finYearController = TextEditingController();


  List<TextEditingController> phoneControllers = [];
  List<TextEditingController> emailControllers = [];

  //Variables for user details
  String? username = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';

  bool isActive = false;
  bool iscpcb = false;
  bool isspcb = false;

  PlatformFile? selectedFileCPCB;
  PlatformFile? selectedFileSPCB;

  DateTime? selectedCPCBDate;
  DateTime? selectedSPCBDate;


  @override
  void initState() {
    super.initState();
    checkLogin();

    if (widget.SPCB != null && widget.SPCB!.isNotEmpty) {
      file_name_SPCB = widget.SPCB!.split('/').last;
      _fetchFileBytesFromServer(widget.SPCB!, 'SPCB');
    }

    if (widget.CPCB != null && widget.CPCB!.isNotEmpty) {
      file_name_CPCB = widget.CPCB!.split('/').last;
      _fetchFileBytesFromServer(widget.CPCB!, 'CPCB');
    }



    countryController.text = widget.country ?? '';
    gstNoController.text = widget.gstNumber ?? '';
    buyerNameController.text = widget.buyerName ?? '';
    contactPersonController.text = widget.contactPerson ?? '';
    addressController.text = widget.address ?? '';
    stateController.text = widget.state ?? '';
    cityController.text = widget.city ?? '';
    pinCodeController.text = widget.pinCode ?? '';
    panController.text = widget.pan ?? '';
    finYearController.text = widget.finYear ?? '';


    if (widget.companyType != null && !companyTypes.contains(widget.companyType)) {
      companyTypes.add(widget.companyType!);
    }

    if (widget.natureActivity != null && !natureofactivityTypes.contains(widget.natureActivity)) {
      natureofactivityTypes.add(widget.natureActivity!);
    }

    // Assign the selected values
    selectedCompanyType = widget.companyType ?? 'Type of Company';
    selectedNatureofactivityType = widget.natureActivity ?? 'Nature of Company';


    iscpcb = widget.CPCBdate != null && widget.CPCBdate.isNotEmpty;
    isspcb = widget.SPCBdate != null && widget.SPCBdate.isNotEmpty;

    isActive = widget.isActive == 'Y' ? true : false;

    selectedCPCBDate = widget.CPCBdate != null
        ? DateTime.tryParse(widget.CPCBdate)
        : null;
    selectedSPCBDate = widget.SPCBdate != null
        ? DateTime.tryParse(widget.SPCBdate)
        : null;


    if (widget.phone.isNotEmpty) {
      phoneControllers = widget.phone
          .split('\n') // Split the string by newline
          .map((phone) => TextEditingController(text: phone.replaceAll('P - ', '').trim())) // Remove "P -" and initialize controllers
          .toList();
    }

    // Initialize the email controllers only when the email data is available
    if (widget.email.isNotEmpty) {
      emailControllers = widget.email
          .split('\n') // Split the string by newline
          .map((email) => TextEditingController(text: email.trim())) // Initialize email controllers
          .toList();
    }

    financialYears = generateFinancialYears();
    finYearController.text = financialYears[1];
  }

  //Fetching user details from sharedpreferences
  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
  }


  Future<void> fetchGstDetails() async {
    try {
      await checkLogin(); // Ensure login is valid
      final url = Uri.parse("${URL}gst_data");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'user_pass': password,
          'gstin':  gstNoController.text,
          'fy': finYearController.text ?? '',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Extract primary address and format it
        if (jsonData.containsKey('addresses') && jsonData['addresses'] is List) {
          final addresses = jsonData['addresses'] as List;
          if (addresses.isNotEmpty) {
            final primaryAddress = addresses[0]; // First address

            final formattedAddress = [
              primaryAddress['building'] ?? '',
              primaryAddress['buildingName'] ?? '',
              primaryAddress['floor'] ?? '',
              primaryAddress['street'] ?? '',
              primaryAddress['locality'] ?? '',
              primaryAddress['district'] ?? '',
              primaryAddress['state'] ?? '',
              primaryAddress['zip'] ?? ''
            ].where((element) => element.isNotEmpty).join(', ');


            // Update state variables
            setState(() {
              addressController.text = formattedAddress;
              stateController.text = primaryAddress['state'] ?? '';
              cityController.text = primaryAddress['locality'] ?? primaryAddress['district'] ?? '';
              pinCodeController.text = primaryAddress['zip'] ?? '';
            });
          }
        }

        // Print other details like PAN
        setState(() {
          panController.text = jsonData['pan'] ?? '';
        });
      } else {
        print("Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Exception: $e");
      Fluttertoast.showToast(
        msg: 'Server Exception: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.yellow,
      );
    }
  }

  Future<void> adddomesticDetails() async {

    if (countryController.text.isEmpty ||
        gstNoController.text.isEmpty ||
        finYearController.text.isEmpty ||
        buyerNameController.text.isEmpty ||
        contactPersonController.text.isEmpty ||
        addressController.text.isEmpty ||
        pinCodeController.text.isEmpty ||
        stateController.text.isEmpty ||
        cityController.text.isEmpty
    ) {
      // Print an error message or show a toast to the user
      Fluttertoast.showToast(
        msg: "Please fill all required fields.",
        fontSize: 16.0,
      );
      return; // Exit the function without making the API call
    }

    await checkLogin();
    final url = Uri.parse('${URL}bidder_update');

    final Map<String, String> body = {
      'user_id': username.toString(),
      'user_pass': password.toString(),
      'bidder_id': widget.buyerID,
      'bidder_name': buyerNameController.text ?? '',
      'con_person': contactPersonController.text ?? '',
      'address': addressController.text ?? '',
      'country': countryController.text ?? '',
      'state': stateController.text ?? '',
      'city': cityController.text ?? '',
      'pin_code': pinCodeController.text ?? '',
      'pan': panController.text ?? '',
      'tan': gstNoController.text ?? '',
      'type_of_company': selectedCompanyType,
      'nature_of_activity': selectedNatureofactivityType,
      'CPCB_SPCB': (iscpcb || isspcb).toString() == false ? 'no' :'yes',
      'cpcb_exp_date':selectedCPCBDate.toString() ?? '',
      'spcb_exp_date': selectedFileSPCB.toString() ?? '',
      'formType': widget.details.toString() ?? '',
      'is_active': isActive == true ? 'Y' : 'N',
      'tan':'',
      'phone': json.encode(phoneControllers.map((controller) => controller.text).toList()),
      'email': json.encode(emailControllers.map((controller) => controller.text).toList()),

    };

    final request = http.MultipartRequest('POST', url)..fields.addAll(body);

    if (selectedFileSPCB != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'spcb_files',
          selectedFileSPCB!.bytes!,
          filename: selectedFileSPCB!.name,
        ),
      );
    } else if (_fileBytesSPCB != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'spcb_files',
          _fileBytesSPCB!,
          filename: file_name_SPCB,
        ),
      );
    }

   if (selectedFileCPCB != null){
      request.files.add(
        http.MultipartFile.fromBytes(
          'cpcb_files',
          selectedFileCPCB!.bytes!,
          filename: selectedFileCPCB!.name,
        ),
      );

    } else if (_fileBytesCPCB != null) {
     request.files.add(
       http.MultipartFile.fromBytes(
         'cpcb_files',
         _fileBytesCPCB!,
         filename: file_name_CPCB,
       ),
     );
   }

   else {
      print('Invalid file selected or file properties are null.');
    }

    try {
      final response = await request.send();

      // Log status code and headers
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');

      final responseString = await response.stream.bytesToString();
      print('Response Body: $responseString');

      if (response.statusCode == 200) {
        // Decode the JSON response
        final responseData = json.decode(responseString);

        // Extract the message and display in a toast
        String message = responseData['msg'] ?? "Vendor saved successfully!";
        Fluttertoast.showToast(
          msg: message,
        );
      } else {
        // Log and display error details
        print('Request failed with status: ${response.statusCode}');
        Fluttertoast.showToast(
          msg: "Something went wrong: ${response.statusCode}",
        );
      }
    } catch (e) {
      print('An error occurred: $e');
      Fluttertoast.showToast(
        msg: "An error occurred: $e",
      );
    }

  }


  Future<void> _pickAttachment(String type) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        PlatformFile file = result.files.single;

        // Create a File object from PlatformFile path
        File pickedFile = File(file.path!);

        // Read file bytes
        Uint8List fileBytes = await pickedFile.readAsBytes();

        setState(() {
          if (type == 'SPCB') {
            selectedFileSPCB = PlatformFile(
              path: file.path,
              name: file.name,
              bytes: fileBytes,
              size: file.size,
            );
          } else if (type == 'CPCB') {
            selectedFileCPCB = PlatformFile(
              path: file.path,
              name: file.name,
              bytes: fileBytes,
              size: file.size,
            );
          }
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  void _removefile(String type) {
    setState(() {
      if (type == 'SPCB') {
        selectedFileSPCB = null;
        _fileBytesSPCB = null;
      } else if (type == 'CPCB') {
        selectedFileCPCB = null;
        _fileBytesCPCB = null;
      }
    });
  }

  Future<void> _fetchFileBytesFromServer(String fileUrl, String target) async {
    print('Fetching $target file from URL: $fileUrl');
    try {
      var response = await http.get(Uri.parse(fileUrl));
      print('Status Code for $target: ${response.statusCode}');
      if (response.statusCode == 200) {
        setState(() {
          if (target == 'SPCB') {
            _fileBytesSPCB = response.bodyBytes;
          } else if (target == 'CPCB') {
            _fileBytesCPCB = response.bodyBytes;
          }
        });
      } else {
        print('Failed to load file from server: $target, Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
    } catch (e) {
      print('Exception fetching $target file: $e');
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
                                Text("${widget.details == 'domestic' ? 'Edit Domestic Details' : 'Edit Internation Details'}",
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
                  _buildTextField("Country *", countryController),
                  _buildTextField("GST NO *", gstNoController),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed : (){
                        fetchGstDetails();
                      },
                      child : Text("Verify"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[800],
                        foregroundColor:  Colors.white,
                      ),
                    ),
                  ),
                  _buildDropdownField('Fin yr *', financialYears, finYearController.text, (newValue) {
                    setState(() {
                      finYearController.text = newValue!;
                    });
                  }),
                  _buildTextField("Buyer Name *", buyerNameController),
                  _buildTextField("Contact Person *", contactPersonController),
                  _buildTextField("Address *", addressController),
                  _buildTextField("State *", stateController),
                  _buildTextField("City *", cityController),
                  _buildTextField("Pin Code *", pinCodeController),
                  _buildTextField("PAN", panController),
                  _buildDropdownField('Type of Company', companyTypes, selectedCompanyType, updateSelectedCompanyType),
                  _buildDropdownField('Nature of Activity', natureofactivityTypes, selectedNatureofactivityType, updateSelectedNatureofactivityType),

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
                  CheckboxListTile(
                    value: iscpcb,
                    title: Text("CPCB",style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),),
                    onChanged: (value) {
                      setState(() => iscpcb = value!);
                    },
                  ),
                  if (iscpcb)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFilePickerField(
                          'CPCB Certificate',
                          selectedFileCPCB?.name ?? '',
                              () => _pickAttachment('CPCB'),
                              () => _removefile('CPCB'),
                        ),
                        SizedBox(height: 5,),
                        buildFieldWithDatePicker(
                          'CPCB Exp Date',
                          selectedCPCBDate,
                              (DateTime? selectedDate) {
                            setState(() {
                              selectedCPCBDate = selectedDate!;
                            });
                          },
                        ),

                      ],
                    ),
                  CheckboxListTile(
                    value: isspcb,
                    title: Text("SPCB",style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),),
                    onChanged: (value) {
                      setState(() => isspcb = value!);
                    },
                  ),
                  if (isspcb)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFilePickerField(
                          'SPCB Certificate',
                          selectedFileSPCB?.name ?? '',
                              () => _pickAttachment('SPCB'),
                              () => _removefile('SPCB'),
                        ),
                        buildFieldWithDatePicker(
                          'SPCB Exp Date',
                          selectedSPCBDate,
                              (DateTime? selectedDate) {
                            setState(() {
                              selectedSPCBDate = selectedDate!;
                            });
                          },
                        ),
                      ],
                    ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await adddomesticDetails(); // Wait for the async function to complete
                      },
                      child: Text("Submit",style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.indigo[800],
                        padding: EdgeInsets.symmetric(
                            horizontal: 50, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
              Expanded(child: _buildTextField("Email *", controller)),
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


  Widget _buildFilePickerField(
      String label,
      String? fileName,
      VoidCallback onUploadPressed,
      VoidCallback onDeletePressed,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 150,
            child: Text(
              '$label',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 40,
              child: ElevatedButton(
                onPressed: onUploadPressed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.upload_file,
                      size: 22.0,
                      color: Colors.black,
                    ),
                    Expanded(
                      child: Text(
                        fileName != null && fileName.isNotEmpty
                            ? fileName
                            : 'Upload File',
                      ),
                    ),

                    if(_fileBytesCPCB != null)
                      TextButton(onPressed: (){
                        downloadFile(widget.CPCB!,file_name_SPCB!);
                        }, child: Text("View")),

                    if(_fileBytesSPCB != null)
                      TextButton(onPressed: (){
                        downloadFile(widget.SPCB!,file_name_SPCB!);
                      }, child: Text("View")),


                    if (fileName != null && fileName.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: onDeletePressed,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> downloadFile(String url, String fileName) async {

    try {
      print('Fetching file from URL: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);

        await file.writeAsBytes(response.bodyBytes);
        print('File saved to: $filePath');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File downloaded: $fileName')),
        );

        // Open the file
        OpenFile.open(filePath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download file: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }


  Widget buildFieldWithDatePicker(String label, DateTime? selectedDate, Function(DateTime?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(width: 8.0),
        TextButton(
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(), // Default to today's date if null
              firstDate: DateTime(2000),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (picked != null && picked != selectedDate) {
              onChanged(picked);
            }
          },
          child: Text(
            selectedDate != null
                ? "${selectedDate.toLocal()}".split(' ')[0]
                : 'Select Date', // Show "Select Date" if no date is selected
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  // Generate financial years dynamically
  List<String> generateFinancialYears() {
    int currentYear = DateTime.now().year;
    int currentYears = DateTime.now().year % 100;

    List<String> years = [];
    for (int i = 0; i < 5; i++) {
      String yearLabel = '${currentYear - i}-${currentYears - i + 1}';
      years.add(yearLabel);
    }
    return years;
  }


  List<String> financialYears = [];

  String selectedCompanyType = 'Type of Company'; // Initial selected value
  List<String> companyTypes = [
    'Type of Company',
    'Individual',
    'Sole Proprietorship',
    'Partnership',
    'Private Ltd.',
    'Trust',
    'Public Ltd.',
  ];

  List<String> natureofactivityTypes = [
    'Nature of Company',
    'Trading',
    'Manufacturing',
    'Both',
  ];

  String selectedNatureofactivityType ='Nature of Company';

  void updateSelectedNatureofactivityType(String? newValue) {
    setState(() {
      selectedNatureofactivityType = newValue ?? 'Nature of Company';
    });
  }

  void updateSelectedCompanyType(String? newValue) {
    setState(() {
      selectedCompanyType = newValue ?? 'Type of Company';
    });
  }

  Widget _buildDropdownField(
      String label, List<String> items, String selectedValue, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          Container(
            width: 120, // Fixed width for the label, adjust as needed
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
        ],
      ),
    );
  }

  Uint8List? _fileBytesCPCB;
  Uint8List? _fileBytesSPCB;

  String? file_name_CPCB;
  String? file_name_SPCB;


}

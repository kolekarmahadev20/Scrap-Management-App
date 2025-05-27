import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../URL_CONSTANT.dart';
// imports for image uploader
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Import for File
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';

import 'View_dispatch_details.dart';

class addDispatchToSaleOrder extends StatefulWidget {
  final String sale_order_id;
  final String material_name;
  final String bidder_id;
  final String totalQty;
  final String balanceqty;
  final String branch_id_from_ids;
  final String vendor_id_from_ids;
  final String materialId;

  addDispatchToSaleOrder({
    required this.sale_order_id,
    required this.material_name,
    required this.bidder_id,
    required this.totalQty,
    required this.balanceqty,
    required this.branch_id_from_ids,
    required this.vendor_id_from_ids,
    required this.materialId,
  });

  @override
  addDispatchToSaleOrderState createState() => addDispatchToSaleOrderState();
}

class addDispatchToSaleOrderState extends State<addDispatchToSaleOrder> {
  final TextEditingController orderIdController = TextEditingController();
  final TextEditingController materialController = TextEditingController();
  final TextEditingController invoiceController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController truckNoController = TextEditingController();
  final TextEditingController firstWeightNoController = TextEditingController();
  final TextEditingController fullWeightController = TextEditingController();
  final TextEditingController moistureWeightController =
      TextEditingController();
  final TextEditingController netWeightController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String? username = '';
  String uuid = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';
  String advancePayment = '';
  String totalEmd = '';
  String totalCmd = '';
  String rate = '';
  bool isLoading = false;

  String? selectedOrderId;
  String? MaterialSelected;
  String? materialId;
  bool isDispatchCompleted = false;

  List<String> orderIDs = [
    'Select',
  ];
  List<File> vehicleFront = [];
  List<File> vehicleBack = [];
  List<File> Material = [];
  List<File> MaterialHalfLoad = [];
  List<File> MaterialFullLoad = [];
  List<File> other = [];

  void clearFields() {
    selectedOrderId = null;
    materialController.clear();
    invoiceController.clear();
    dateController.clear();
    truckNoController.clear();
    quantityController.clear();
    noteController.clear();
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await checkLogin().then((_) {
      setState(() {});
    }); // Rebuilds the widget after `userType` is updated.
    await materialNameId();
    fetchPaymentDetails();
    materialController.text = widget.material_name;

    // Add listeners for weight calculations
    firstWeightNoController.addListener(calculateNetWeight);
    fullWeightController.addListener(calculateNetWeight);
    moistureWeightController.addListener(calculateNetWeight);
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    uuid = prefs.getString("uuid")!;
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
  }

  void calculateNetWeight() {
    double firstWeight = double.tryParse(firstWeightNoController.text) ?? 0.0;
    String fullWeightText = fullWeightController.text.trim();

    // ✅ Ensure the user enters a full weight before processing
    if (fullWeightText.isEmpty) {
      print("Waiting for full weight input...");
      return;
    }

    double fullWeight = double.tryParse(fullWeightText) ?? 0.0;

    // ✅ Ensure fullWeight is greater than firstWeight before processing
    if (fullWeight <= firstWeight) {
      print("Full weight is not yet valid. Waiting...");
      return;
    }

    double moistureWeight = double.tryParse(moistureWeightController.text) ?? 0.0;

    print("First Weight: $firstWeight");
    print("Full Weight: $fullWeight");
    print("Moisture Weight: $moistureWeight");

    double netWeight = (fullWeight - firstWeight);
    netWeight = double.parse(netWeight.toStringAsFixed(3));

    print("Calculated Net Weight: $netWeight");

    double DMTWeight = ((fullWeight - firstWeight) * moistureWeight) / 100;
    DMTWeight = netWeight - DMTWeight;
    DMTWeight = double.parse(DMTWeight.toStringAsFixed(3));

    print("Calculated DMT Weight: $DMTWeight");

    double balanceqty = double.tryParse(widget.balanceqty) ?? 0.0;
    print("Total Quantity: $balanceqty");

    // ✅ Check if netWeight is greater than totalQty first
    if (netWeight > balanceqty) {
      print("Error: Net weight ($netWeight) exceeds total quantity ($balanceqty).");

      netWeightController.clear();
      quantityController.clear();
      fullWeightController.clear();

      Fluttertoast.showToast(
        msg: "Net weight ($netWeight) cannot exceed total quantity ($balanceqty)!",
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    // ✅ Check if netWeight is negative
    if (netWeight < 0) {
      print("Error: Net weight ($netWeight) is negative.");

      netWeightController.clear();
      quantityController.clear();
      fullWeightController.clear();

      Fluttertoast.showToast(
        msg: "Net weight ($netWeight) cannot be negative!",
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    // ✅ Update the controllers
    netWeightController.text = netWeight.toStringAsFixed(3);
    quantityController.text = DMTWeight.toStringAsFixed(3);

    print("Final Net Weight: ${netWeightController.text}");
    print("Final DMT Weight: ${quantityController.text}");
  }

  // void calculateNetWeight() {
  //   double firstWeight = double.tryParse(firstWeightNoController.text) ?? 0.0;
  //   double fullWeight = double.tryParse(fullWeightController.text) ?? 0.0;
  //   double moistureWeight = double.tryParse(moistureWeightController.text) ?? 0.0;
  //
  //   double netWeight = (fullWeight - firstWeight);
  //
  //   double DMTWeight = ((fullWeight - firstWeight) * moistureWeight)/100;
  //   DMTWeight = netWeight-DMTWeight;
  //
  //   // Update the net weight controller with the result
  //   netWeightController.text = netWeight.toStringAsFixed(2);
  //   quantityController.text = DMTWeight.toStringAsFixed(2);
  // }

  Future<void> materialNameId() async {
    try {
      await checkLogin();
      final url = Uri.parse("${URL}get_materialDesc");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'user_pass': password,
          'sale_order_id': widget.sale_order_id,
          'uuid': uuid
        },
      );
      //variable to send material value instead of name in backend.
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          materialId = jsonData['material_id'] ?? 'N/A';
        });
      } else {
        print("unable to load order ids.");
      }
    } catch (e) {
      print("Server Exception : $e");
    }
  }

  // Function to compress the image
  Future<File?> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        path.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
    return await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, targetPath,
        quality: 20);
  }

  Future<void> fetchPaymentDetails() async {
    try {
      setState(() {
        isLoading = true;
      });
      await checkLogin();
      final url = Uri.parse("${URL}EMD_CMD_details");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid': uuid,
          'user_pass': password,
          'sale_order_id': widget.sale_order_id,
          'branch_id':widget.branch_id_from_ids,
          'vendor_id':widget.vendor_id_from_ids,
        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          advancePayment = jsonData['Advance_payment'].toString() ?? 'N/A';
          totalEmd = jsonData['total_EMD'].toString() ?? 'N/A';
          totalCmd = jsonData['total_CMD'].toString() ?? 'N/A';
          rate = jsonData['rate'].toString();

          print(rate);
        });
      } else {
        Fluttertoast.showToast(
            msg: 'Unable to load data.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.yellow);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Server Exception : $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.yellow);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Future<void> addDispatchDetails() async {
  //   try {
  //     print("======= Start addDispatchDetails =======");
  //
  //     if (truckNoController.text.trim().length < 7) {
  //       Fluttertoast.showToast(
  //         msg: 'Truck Number must be at least 7 characters long.',
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //       );
  //       print("Validation failed: Truck Number is too short.");
  //       return; // Exit the function early
  //     }
  //
  //     setState(() {
  //       isLoading = true;
  //     });
  //
  //     print("Checking login...");
  //     await checkLogin();
  //     print("Login check complete.");
  //
  //     final url = Uri.parse("${URL}save_lifting");
  //     print("API URL: $url");
  //
  //     // Create a Multipart Request
  //     var request = http.MultipartRequest('POST', url);
  //
  //     // Add form data
  //     request.fields['user_id'] = username!;
  //     request.fields['user_pass'] = password!;
  //     request.fields['uuid'] = uuid!;
  //     request.fields['sale_order_id_lift'] = widget.sale_order_id ?? '';
  //     request.fields['rate'] = rate ?? '';
  //     request.fields['advance_payment'] = advancePayment ?? '';
  //     request.fields['lotno'] = materialId ?? '';
  //     request.fields['invoice_no'] = invoiceController.text ?? '';
  //     request.fields['date_time'] = dateController.text ?? '';
  //     request.fields['truck_no'] = truckNoController.text ?? '';
  //     request.fields['truck_weight'] = firstWeightNoController.text ?? '';
  //     request.fields['full_weight'] = fullWeightController.text ?? '';
  //     request.fields['mois_weight'] = moistureWeightController.text ?? '';
  //     request.fields['net_weight'] = netWeightController.text ?? '';
  //     request.fields['qty'] = quantityController.text ?? '';
  //     request.fields['note'] = noteController.text ?? '';
  //     request.fields['status'] = isDispatchCompleted ? 'c' : 'p';
  //
  //     print("======== Request Fields ========");
  //     request.fields.forEach((key, value) {
  //       print("$key: $value");
  //     });
  //
  //     // Function to add images to the request
  //     Future<void> addImages(List<File> images, String keyword,
  //         http.MultipartRequest request) async {
  //       Set<String> addedHashes = {}; // To track unique image hashes
  //
  //       for (var image in images) {
  //         print("Processing image: ${image.path}");
  //         File? compressedImage = await compressImage(image);
  //
  //         if (compressedImage != null) {
  //           String imageHash = await computeFileHash(compressedImage);
  //
  //           if (!addedHashes.contains(imageHash)) {
  //             String fileName =
  //                 '$keyword${compressedImage.path.split('/').last}';
  //
  //             print("Adding image: $fileName");
  //
  //             var stream = http.ByteStream(compressedImage.openRead());
  //             var length = await compressedImage.length();
  //             var multipartFile = http.MultipartFile(
  //               'certifications[]',
  //               stream,
  //               length,
  //               filename: fileName,
  //             );
  //
  //             request.files.add(multipartFile);
  //             addedHashes.add(imageHash); // Track added image hash
  //           } else {
  //             //print("Duplicate image detected, skipping: $fileName");
  //           }
  //         } else {
  //           print("Image compression failed for: ${image.path}");
  //         }
  //       }
  //     }
  //
  //     // Add images from different sources
  //     if (vehicleFront.isNotEmpty) {
  //       print("Adding Vehicle Front Images...");
  //       await addImages(vehicleFront, "Fr", request);
  //     }
  //     if (vehicleBack.isNotEmpty) {
  //       print("Adding Vehicle Back Images...");
  //       await addImages(vehicleBack, "Ba", request);
  //     }
  //     if (Material.isNotEmpty) {
  //       print("Adding Material Images...");
  //       await addImages(Material, "Ma", request);
  //     }
  //     if (MaterialHalfLoad.isNotEmpty) {
  //       print("Adding Material Half Load Images...");
  //       await addImages(MaterialHalfLoad, "Ha", request);
  //     }
  //     if (MaterialFullLoad.isNotEmpty) {
  //       print("Adding Material Full Load Images...");
  //       await addImages(MaterialFullLoad, "Fu", request);
  //     }
  //     if (other.isNotEmpty) {
  //       print("Adding Other Images...");
  //       await addImages(other, "ot", request);
  //     }
  //
  //     print("Final Request Fields:");
  //     request.fields.forEach((key, value) {
  //       print("$key: $value");
  //     });
  //
  //     print("Sending request...");
  //     var response = await request.send();
  //     print("Request sent. Response status code: ${response.statusCode}");
  //
  //     if (response.statusCode == 200) {
  //       final res = await http.Response.fromStream(response);
  //       final jsonData = json.decode(res.body);
  //       print("Response Data: $jsonData");
  //
  //       setState(() {
  //         Fluttertoast.showToast(
  //           msg: "${jsonData['msg']}",
  //         );
  //       });
  //
  //       if (jsonData['status'] == 'success') {
  //         print("Dispatch Details added successfully. Navigating...");
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) => View_dispatch_details(
  //                 sale_order_id: widget.sale_order_id,
  //                 bidder_id: widget.bidder_id,
  //               )),
  //         );
  //       } else {
  //         print("Server returned an error: ${jsonData['msg']}");
  //       }
  //     } else {
  //       print("Failed to insert data. Status code: ${response.statusCode}");
  //       Fluttertoast.showToast(
  //         msg: 'Unable to insert data.',
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //         backgroundColor: Colors.red,
  //         textColor: Colors.yellow,
  //       );
  //     }
  //   } catch (e, stackTrace) {
  //     print("Exception occurred: $e");
  //     print("StackTrace: $stackTrace");
  //     Fluttertoast.showToast(
  //       msg: 'Error occurred while adding dispatch details.',
  //       toastLength: Toast.LENGTH_LONG,
  //       gravity: ToastGravity.BOTTOM,
  //       backgroundColor: Colors.red,
  //       textColor: Colors.white,
  //     );
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     print("======= End addDispatchDetails =======");
  //   }
  // }

  Future<void> addDispatchDetails() async {
    try {
      if (truckNoController.text.trim().length < 7) {
        Fluttertoast.showToast(
          msg: 'Truck Number must be at least 7 characters long.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return; // Exit the function early
      }

      setState(() {
        isLoading = true;
      });
      await checkLogin();
      final url = Uri.parse("${URL}save_lifting");

      // Create a Multipart Request
      var request = http.MultipartRequest('POST', url);

      // Add form data
      request.fields['user_id'] = username!;
      request.fields['user_pass'] = password!;
      request.fields['uuid'] = uuid!;
      request.fields['sale_order_id_lift'] = widget.sale_order_id ?? '';
      request.fields['rate'] = rate ?? '';
      request.fields['advance_payment'] = advancePayment ?? '';
      request.fields['lotno'] = materialId ?? '';
      request.fields['invoice_no'] = invoiceController.text ?? '';
      request.fields['date_time'] = dateController.text ?? '';
      request.fields['truck_no'] = truckNoController.text ?? '';
      request.fields['truck_weight'] = firstWeightNoController.text ?? '';
      request.fields['full_weight'] = fullWeightController.text ?? '';
      request.fields['mois_weight'] = moistureWeightController.text ?? '';
      request.fields['net_weight'] = netWeightController.text ?? '';
      request.fields['qty'] = quantityController.text ?? '';
      request.fields['note'] = noteController.text ?? '';
      request.fields['status'] = isDispatchCompleted ? 'c' : 'p';

      print("======== Request Fields ========");
      request.fields.forEach((key, value) {
        print("$key: $value");
      });

      // Function to add images to the request
      Future<void> addImages(List<File> images, String keyword,
          http.MultipartRequest request) async {
        Set<String> addedHashes = {}; // To track unique image hashes

        for (var image in images) {
          File? compressedImage = await compressImage(image);

          if (compressedImage != null) {
            // Generate a unique hash for the image content
            String imageHash = await computeFileHash(compressedImage);

            if (!addedHashes.contains(imageHash)) {
              String fileName =
                  '$keyword${compressedImage.path.split('/').last}';

              print(fileName);
              print("fileName");

              var stream = http.ByteStream(compressedImage.openRead());
              var length = await compressedImage.length();
              var multipartFile = http.MultipartFile(
                'certifications[]',
                stream,
                length,
                filename: fileName,
              );

              request.files.add(multipartFile);
              addedHashes.add(imageHash); // Track added image hash
            }
          }
        }
      }

      // Add images from different sources
      if (vehicleFront.isNotEmpty) await addImages(vehicleFront, "Fr", request);
      if (vehicleBack.isNotEmpty) await addImages(vehicleBack, "Ba", request);
      if (Material.isNotEmpty) await addImages(Material, "Ma", request);
      if (MaterialHalfLoad.isNotEmpty)
        await addImages(MaterialHalfLoad, "Ha", request);
      if (MaterialFullLoad.isNotEmpty)
        await addImages(MaterialFullLoad, "Fu", request);
      if (other.isNotEmpty) await addImages(other, "ot", request);

      print('Fields sent:');
      request.fields.forEach((key, value) {
        print('$key: $value');
      });

      // print("**************************************************************");

      // print('Files sent:');
      // request.files.forEach((file) {
      //   print('File: ${file.filename}, length: ${file.length}');
      // });

      // Send the request
      print("Sending request...");
      var response = await request.send();
      print("Request sent. Response status code: ${response.statusCode}");

      // Handle response
      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        final jsonData = json.decode(res.body);
        print(jsonData);
        print("jsonData");

        setState(() {
          if (jsonData.containsKey('liftedTaxAmount')) {
            Fluttertoast.showToast(
              msg: "${jsonData['msg']}", // You can change the text color
            );
          } else {
            Fluttertoast.showToast(
              msg: "${jsonData['msg']} ",
            );
          }
        });
        if (jsonData['status'] == 'success') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => View_dispatch_details(
                      sale_order_id: widget.sale_order_id,
                      bidder_id: widget.bidder_id,
                      branch_id_from_ids:
                          widget.branch_id_from_ids, // Extracted from "Ids"
                      vendor_id_from_ids:
                          widget.vendor_id_from_ids, // Extracted from "Ids"
                      materialId: widget.materialId, // Extracted from "Ids"
                    )), // Navigate to the desired screen
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Unable to insert data.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.yellow,
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to compute the hash of a file's contents
  Future<String> computeFileHash(File file) async {
    var bytes = await file.readAsBytes();
    return md5.convert(bytes).toString(); // Using MD5 hash
  }

  showLoading() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.transparent,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isLoading,
      child: Scaffold(
        drawer: AppDrawer(currentPage: 5),
        appBar: CustomAppBar(),
        body: Stack(children: [
          isLoading
              ? showLoading()
              : Container(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  color: Colors.grey[100],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Dispatch",
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
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white, // Background color
                            border: Border.all(color: Colors.blueGrey[400]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26, // Shadow color
                                blurRadius: 4, // Softness of the shadow
                                offset: Offset(2, 2), // Position of the shadow
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "ADD MATERIAL LIFTING DETAIL",
                                    style: TextStyle(
                                      fontSize: 16, // Keep previous font size
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              buildTextField("Material", materialController,
                                  true, false, Colors.white, context),
                              buildTextField("Invoice No", invoiceController,
                                  false, false, Colors.white, context),
                              buildTextField("Date", dateController, false,
                                  true, Colors.white, context),
                              buildTextField("Truck No", truckNoController,
                                  false, false, Colors.white, context),
                              buildTextField(
                                  "First Weight",
                                  firstWeightNoController,
                                  false,
                                  false,
                                  Colors.white,
                                  context),
                              buildTextField(
                                  "Gross Weight",
                                  fullWeightController,
                                  false,
                                  false,
                                  Colors.white,
                                  context),
                              buildTextField("Net", netWeightController, true,
                                  false, Colors.grey[400]!, context),
                              buildTextField(
                                  "Moisture Weight",
                                  moistureWeightController,
                                  false,
                                  false,
                                  Colors.white,
                                  context),
                              buildTextField(
                                  "DMT/Quantity Weight",
                                  quantityController,
                                  true,
                                  false,
                                  Colors.white,
                                  context),
                              buildTextField("Note", noteController, false,
                                  false, Colors.white, context),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex:
                                            2, // Adjusts the label width proportionally
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              8.0), // Adds padding around the text
                                          child: Text(
                                            'Dispatch\nCompleted',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex:
                                            3, // Adjusts the radio buttons area proportionally
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: Radio<bool>(
                                                value: true,
                                                groupValue: isDispatchCompleted,
                                                onChanged: (bool? newValue) {
                                                  setState(() {
                                                    isDispatchCompleted =
                                                        newValue ?? false;
                                                  });
                                                },
                                              ),
                                            ),
                                            Text('Yes'),
                                            Flexible(
                                              child: Radio<bool>(
                                                value: false,
                                                groupValue: isDispatchCompleted,
                                                onChanged: (bool? newValue) {
                                                  setState(() {
                                                    isDispatchCompleted =
                                                        newValue ?? false;
                                                  });
                                                },
                                              ),
                                            ),
                                            Text('No'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(
                                        thickness: 1.5, color: Colors.black54),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Upload Images",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24),
                                      ),
                                    ),
                                    Divider(
                                        thickness: 1.5, color: Colors.black54),
                                    // ImageWidget(
                                    //     value: '1) Vehicle Front',
                                    //     cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                                    //     galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                                    //     onImagesSelected: (images) { // Handle selected images
                                    //       setState(() {
                                    //         vehicleFront.addAll(images); // Store uploaded images
                                    //       });
                                    //     }
                                    // ),
                                    // ImageWidget(
                                    //     value: '2) Vehicle Back',
                                    //     cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                                    //     galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                                    //     onImagesSelected: (images) { // Handle selected images
                                    //       setState(() {
                                    //         vehicleBack.addAll(images); // Store uploaded images
                                    //       });
                                    //     }
                                    // ),
                                    // ImageWidget(
                                    //     value: '3) Material',
                                    //     cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                                    //     galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                                    //     onImagesSelected: (images) { // Handle selected images
                                    //       setState(() {
                                    //         Material.addAll(images); // Store uploaded images
                                    //       });
                                    //     }
                                    // ),
                                    // ImageWidget(
                                    //     value: '4) Material Half Load',
                                    //     cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                                    //     galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                                    //     onImagesSelected: (images) { // Handle selected images
                                    //       setState(() {
                                    //         MaterialHalfLoad.addAll(images); // Store uploaded images
                                    //       });
                                    //     }
                                    // ),
                                    // ImageWidget(
                                    //     value: '5) Material Full Load',
                                    //     cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                                    //     galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                                    //     onImagesSelected: (images) { // Handle selected images
                                    //       setState(() {
                                    //         MaterialFullLoad.addAll(images); // Store uploaded images
                                    //       });
                                    //     }
                                    // ),
                                    ImageWidget(
                                        value: 'Add Images',
                                        cameraIcon: Icon(Icons.camera_alt,
                                            color: Colors.blue),
                                        galleryIcon: Icon(Icons.photo_library,
                                            color: Colors.green),
                                        onImagesSelected: (images) {
                                          // Handle selected images
                                          setState(() {
                                            other.addAll(
                                                images); // Store uploaded images
                                          });
                                        }),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 60,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // ElevatedButton(
                                    //   onPressed: () {
                                    //     clearFields();
                                    //     Navigator.of(context).pop();
                                    //   },
                                    //   child: Text("Back"),
                                    //   style: ElevatedButton.styleFrom(
                                    //     foregroundColor: Colors.white,
                                    //     backgroundColor: Colors.indigo[800],
                                    //     padding: EdgeInsets.symmetric(
                                    //         horizontal: 50, vertical: 12),
                                    //     shape: RoundedRectangleBorder(
                                    //       borderRadius: BorderRadius.circular(12),
                                    //     ),
                                    //   ),
                                    // ),
                                    ElevatedButton(
                                      onPressed: () {
                                        addDispatchDetails();
                                        // clearFields();
                                      },
                                      child: Text("Add"),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.indigo[800],
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 50, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ]),
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
      controller.text = formattedDate;
    }
  }

  Widget buildTextField(String label, TextEditingController controller,
      bool isReadOnly, bool isDateField, Color color, context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3, // Adjusts label width
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 5, // Adjusts text field width
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: color,
              ),
              child: TextField(
                onTap:
                    isDateField ? () => _selectDate(context, controller) : null,
                controller: controller,
                decoration: InputDecoration(
                  suffixIcon: isDateField
                      ? IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context, controller),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.indigo[800]!,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey[400]!,
                      width: 1.5,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                readOnly: isReadOnly,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
    );
  }
}

class ImageWidget extends StatefulWidget {
  final String value;
  final Icon cameraIcon;
  final Icon galleryIcon;
  final Function(List<File>) onImagesSelected;

  const ImageWidget({
    Key? key,
    required this.value,
    required this.cameraIcon,
    required this.galleryIcon,
    required this.onImagesSelected,
  }) : super(key: key);

  @override
  _ImageWidgetState createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  List<File> _images = [];

  // Function to pick multiple images from the gallery
  Future<void> _pickImagesFromGallery() async {
    final picker = ImagePicker();
    // final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery); // Pick only one image
    List<XFile>? pickedFile = await ImagePicker().pickMultiImage();

    if (pickedFile != null) {
      for (var pickedImage in pickedFile) {
        _images.add(
            File(pickedImage.path)); // Append images instead of overwriting
      }

      setState(() {
        // _images = [File(pickedFile.path)]; // Replace the list with the new image
      });
      widget.onImagesSelected(_images);
      // _showSingleImageNotification();
    }
  }

  // Function to capture a single image using the camera
  Future<void> _captureImageFromCamera() async {
    final picker = ImagePicker();
    final XFile? capturedFile =
        await picker.pickImage(source: ImageSource.camera);

    if (capturedFile != null) {
      setState(() {
        _images.add(File(capturedFile.path));
        // _images = [File(capturedFile.path)]; // Replace the list with the new captured image
      });
      widget.onImagesSelected(_images);
      // _showSingleImageNotification();
    }
  }

  void _showSingleImageNotification() {
    // Use Future to delay the snackbar to ensure widget is mounted
    Future.delayed(Duration.zero, () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("You can only upload one image at a time."),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  // Function to delete a selected image
  void _deleteImage(int index) {
    setState(() {
      _images.removeAt(index); // Remove the image at the specified index
      widget.onImagesSelected(_images); // Update parent with the new list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                widget.value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              IconButton(
                icon: widget.cameraIcon,
                onPressed: _captureImageFromCamera, // Calls the camera function
              ),
              IconButton(
                icon: widget.galleryIcon,
                onPressed:
                    _pickImagesFromGallery, // Calls the gallery picker function
              ),
            ],
          ),
        ),
        _images.isNotEmpty
            ? GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Display 3 images per row
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        height: 100, // Set fixed height for images
                        width: 100, // Set fixed width for images
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(8), // Rounded corners
                          child: Image.file(
                            _images[index],
                            fit: BoxFit
                                .cover, // Ensure the image fits within the container
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _deleteImage(index), // Delete the selected image
                        ),
                      ),
                    ],
                  );
                },
              )
            : Container(),
      ],
    );
  }
}

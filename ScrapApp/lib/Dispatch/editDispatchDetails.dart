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
import 'dart:typed_data';
import 'package:image/image.dart' as Img;
import 'View_dispatch_details.dart';
import 'package:crypto/crypto.dart';

class EditDispatchDetails extends StatefulWidget {
  final String sale_order_id;
  final String material_name;
  final String bidder_id;
  final String lift_id;
  final String date;
  final String truckNo;
  final String firstweight;
  final String netweight;
  final String moisweight;
  final String qty;
  final String note;
  final String invoiceNo;
  final String full_weight;
  final String? imagesUrl;
  final String totalQty;
  final String status;
  final String status_byuser;

  final String balanceqty;
  final String branch_id_from_ids;
  final String vendor_id_from_ids;
  final String materialId;
  final String balanceQtyUnit;
  final String balanceamount;


  EditDispatchDetails({
    required this.status,
    required this.totalQty,
    required this.lift_id,
    required this.full_weight,
    required this.invoiceNo,
    required this.sale_order_id,
    required this.material_name,
    required this.bidder_id,
    required this.date,
    required this.truckNo,
    required this.firstweight,
    required this.netweight,
    required this.moisweight,
    required this.qty,
    required this.note,
    required this.balanceqty,
    this.imagesUrl,
    required this.branch_id_from_ids,
    required this.vendor_id_from_ids,
    required this.materialId,
    required this.balanceamount,
    required this.balanceQtyUnit,
    required this.status_byuser,



  });

  @override
  EditDispatchDetailsState createState() => EditDispatchDetailsState();
}

class EditDispatchDetailsState extends State<EditDispatchDetails> {
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

  final TextEditingController balanceQtyController = TextEditingController();
  final TextEditingController balanceQtyUnitController = TextEditingController();
  final TextEditingController balanceAmountController = TextEditingController();


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
  bool isDispatchDone = false;

  List<String> orderIDs = [
    'Select',
  ];
  List<File> vehicleFront = [];
  List<File> vehicleBack = [];
  List<File> Material = [];
  List<File> MaterialHalfLoad = [];
  List<File> MaterialFullLoad = [];
  List<File> other = [];

  List<String> imgUrls = [];
  List<File> _images = [];



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
    fetchImageList();
    // print("Images URL: ${widget.imagesUrl ?? 'No images available'}");

  }

  Future<void> _initializeData() async {
    await checkLogin().then((_) {
      setState(() {});
    }); // Rebuilds the widget after `userType` is updated.
    await materialNameId();
    await getData();
    fetchPaymentDetails();

    balanceQtyController.text = widget.balanceqty;
    balanceQtyUnitController.text =  widget.balanceQtyUnit;
    balanceAmountController.text =  widget.balanceamount;

    // Add listeners for weight calculations
    firstWeightNoController.addListener(calculateNetWeight);
    fullWeightController.addListener(calculateNetWeight);
    moistureWeightController.addListener(calculateNetWeight);
  }

  getData(){

    // if (widget.imagesUrl != null && widget.imagesUrl!.isNotEmpty) {
    //   imgUrls = widget.imagesUrl!
    //       .split(',') // ✅ If it's a string, split by comma
    //       .map((img) => "http://scrap.systementerprises.in/${img.trim()}") // ✅ Add Base URL
    //       .toList();
    // }

    materialController.text = widget.material_name ?? '';
    invoiceController.text=widget.invoiceNo ?? 'N/A';
    dateController.text = formatDate(widget.date) ?? 'N/A';

    isDispatchCompleted = (widget.status == "p") ?  false:true ;
    isDispatchDone = (widget.status_byuser == "p") ?  false:true ;
    truckNoController.text=(widget.truckNo ?? 'N/A').toUpperCase();
    firstWeightNoController.text = widget.firstweight ?? "N/A";
    fullWeightController.text = widget.full_weight ?? "N/A";
    moistureWeightController.text = widget.moisweight ?? "N/A";
    netWeightController.text = widget.netweight ?? "N/A";
    quantityController.text=widget.qty ?? 'N/A';
    noteController.text=widget.note ?? 'N/A';
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

print(widget.sale_order_id);
print("widget.sale_order_id");

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

  List<String> imagesUrl = [];


  Future<void> fetchImageList() async {
    await checkLogin();
    final url = Uri.parse("${URL}check_url");

    print(widget.sale_order_id);
    print(widget.invoiceNo);

    var response = await http.post(
      url,
      headers: {"Accept": "application/json"},
      body: {
        'user_id': username,
        'uuid': uuid,
        'user_pass': password,
        'sale_order_id': widget.sale_order_id,
        'lift_id': widget.lift_id,
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      print("Fetched data: $decoded");

      List<String> imageUrls = [];
      String baseUrl = "${Image_URL}";

      // ✅ Check if response is a Map before using containsKey
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey("ot") && decoded["ot"] is Map<String, dynamic>) {
          Map<String, dynamic> otData = decoded["ot"];

          otData.forEach((key, value) {
            if (value is Map && value.containsKey("images") && value["images"] is List) {
              List<dynamic> images = value["images"];

              for (var path in images) {
                if (path is String && path.isNotEmpty) {
                  imageUrls.add(baseUrl + path);
                }
              }
            }
          });
        }
      } else {
        print("Response is not a Map (likely empty list): $decoded");
      }

      setState(() {
        imagesUrl = imageUrls;
        print("Updated Image URLs: $imagesUrl");
      });
    } else {
      print("Failed to load invoice data: ${response.statusCode}");
    }
  }

  Future<void> deleteImage(String image) async {
    print("Lift ID: ${widget.lift_id}");
    print("Sale Order ID: ${widget.sale_order_id}");
    print("Material ID: $materialId");
    print("Invoice No: ${widget.invoiceNo}");
    print("Image URL: $image");

    try {
      setState(() {
        isLoading = true;
      });

      await checkLogin();
      final url = Uri.parse("${URL}delete_image");

      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id':username,
          'uuid':uuid,
          'user_pass':password,
          'lift_id':widget.lift_id,
          'sale_order_id':widget.sale_order_id,
          'material_id':materialId,
          'invoice_no':widget.invoiceNo,
          'img_path':image,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print("Response: $jsonData");

        if (jsonData["status"] == "1") {
          Fluttertoast.showToast(
            msg:"Image deleted Successfully", // "Image deleted successfully."
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        } else {
          Fluttertoast.showToast(
            msg: "Failed to delete image: ${jsonData["msg"]}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Server Error: ${response.statusCode}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Server Exception: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.yellow,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }



  Future<void> editDispatchDetails() async {

    if (truckNoController.text.trim().length < 7) {
      Fluttertoast.showToast(
        msg: 'Truck Number must be at least 7 characters long.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return; // Exit the function early
    }


    try {
      setState(() {
        isLoading = true;
      });

      await checkLogin();
      final url = Uri.parse("${URL}save_lifting");

      var request = http.MultipartRequest('POST', url);

      request.fields['user_id'] = username!;
      request.fields['user_pass'] = password!;
      request.fields['uuid'] = uuid!;
      request.fields['sale_order_id_lift'] = widget.sale_order_id;
      request.fields['rate'] = rate ?? '';
      request.fields['advance_payment'] = advancePayment ?? '';
      request.fields['lift_id'] = widget.lift_id;
      request.fields['lotno'] = materialId ?? '';
      request.fields['material_id_lifted'] = materialId ?? '';
      request.fields['invoice_no_lift'] = invoiceController.text;
      request.fields['date_time'] = dateController.text;
      request.fields['truck_no'] = truckNoController.text;
      request.fields['truck_weight'] = firstWeightNoController.text;
      request.fields['full_weight'] = fullWeightController.text;
      request.fields['mois_weight'] = moistureWeightController.text;
      request.fields['net_weight'] = netWeightController.text;
      request.fields['qty'] = quantityController.text;
      request.fields['note'] = noteController.text;
      request.fields['status'] = isDispatchCompleted ? 'c' : 'p';
      request.fields['user_status'] = isDispatchDone ? 'c' : 'p';

      // Function to add images to the request
      Future<void> addImages(List<File> images, String keyword, http.MultipartRequest request) async {
        Set<String> addedHashes = {}; // Unique image tracking

        for (var image in images) {
          print('Processing image: ${image.path}');

          File? compressedImage = await compressImage(image);
          if (compressedImage != null) {
            print('Compressed image path: ${compressedImage.path}');

            String imageHash = await computeFileHash(compressedImage);
            print('Image Hash: $imageHash');

            if (!addedHashes.contains(imageHash)) {
              String fileName = '$keyword${compressedImage.path.split('/').last}';
              print('Generated File Name: $fileName');

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

              print('Generated File Name: $fileName');
              print('Adding image to request: $fileName');
              print('Total files in request: ${request.files.length}');


            } else {
              print('Skipping duplicate image');
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
      var response = await request.send();

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
                  branch_id_from_ids: widget.branch_id_from_ids, // Extracted from "Ids"
                  vendor_id_from_ids: widget.vendor_id_from_ids, // Extracted from "Ids"
                  materialId:  widget.materialId, // Extracted from "Ids"
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

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return 'No data';
    }
    try {
      DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return 'Invalid date';
    }
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
                              "EDIT MATERIAL LIFTING DETAIL",
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
                  child:SingleChildScrollView(
                  child: Column(
                    children: [
                      buildTextField("Material", materialController,true, false , Colors.white,context),
                      buildTextField("SO Balance Qty", balanceQtyController,
                          true, false, Colors.white, context),
                      buildTextField("SO Balance Amount", balanceAmountController,
                          true, false, Colors.white, context),
                      buildTextField("Invoice No", invoiceController , false,false ,Colors.white, context),
                      buildTextField("Date", dateController as TextEditingController, true,false , Colors.white,context),
                      buildTextField("Truck No", truckNoController, true,false ,Colors.white, context),
                      buildTextField("First Weight", firstWeightNoController, false,false ,Colors.white, context),
                      buildTextField("Gross Weight", fullWeightController, false,false , Colors.white,context),
                      buildTextField("Net", netWeightController, true,false ,Colors.grey[400]!, context),
                      buildTextField("Moisture Weight", moistureWeightController, false,false ,Colors.white, context),
                      buildTextField("DMT/Quantity Weight", quantityController, true,false , Colors.white,context),
                      buildTextField("Note", noteController, false,false , Colors.white,context),
                      if(userType != 'U')
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

                      if(userType == 'U')
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
                                    'Dispatch Done ?',
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
                                        groupValue: isDispatchDone,
                                        onChanged: (bool? newValue) {
                                          setState(() {
                                            isDispatchDone =
                                                newValue ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                    Text('Yes'),
                                    Flexible(
                                      child: Radio<bool>(
                                        value: false,
                                        groupValue: isDispatchDone,
                                        onChanged: (bool? newValue) {
                                          setState(() {
                                            isDispatchDone =
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


                      SizedBox(
                        height: 40,
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(), // Prevents scrolling inside a scrollable parent
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // Adjust based on UI needs
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 1, // Ensures square images
                        ),
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          final image = _images[index];

                          return Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10), // Rounded corners
                                child: Image.file(
                                  image,
                                  height: 150.0,
                                  width: 150.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: IconButton(
                                  icon: Icon(Icons.delete_forever, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _images.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      SizedBox(
                        height: 20,
                      ),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(), // Prevents GridView from scrolling inside a scrollable parent
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // Adjust columns per row
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 1, // Ensures square images
                        ),
                        itemCount: imagesUrl.length,
                        itemBuilder: (context, index) {
                          final image = imagesUrl[index];

                          return Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10), // Rounded corners
                                child: Image.network(
                                  image,
                                  height: 150.0,
                                  width: 150.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: IconButton(
                                  icon: Icon(Icons.delete_forever, color: Colors.red),
                                  onPressed: () async {
                                    bool deleteConfirmed = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Confirmation"),
                                          content: Text("Are you sure you want to delete this image?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false), // No
                                              child: Text("No"),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                 //await deleteImage(image); // Wait for deleteImage to complete
                                                Navigator.of(context).pop(true); // Then close the dialog
                                              },
                                              child: Text("Yes"),
                                            ),

                                          ],
                                        );
                                      },
                                    );

                                    if (deleteConfirmed == true) {
                                      setState(() {
                                        imagesUrl.removeAt(index);
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(
                        height: 60,
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
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
                                editDispatchDetails();
                                // clearFields();
                              },
                              child: Text("Add"),
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

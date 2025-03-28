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
  final String imagesUrl;


  EditDispatchDetails({
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
    required this.imagesUrl,

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

    print("Images URL: ${widget.imagesUrl ?? 'No images available'}");

  }

  Future<void> _initializeData() async {
    await checkLogin().then((_) {
      setState(() {});
    }); // Rebuilds the widget after `userType` is updated.
    await materialNameId();
    await getData();
    fetchPaymentDetails();
    // Add listeners for weight calculations
    firstWeightNoController.addListener(calculateNetWeight);
    fullWeightController.addListener(calculateNetWeight);
    moistureWeightController.addListener(calculateNetWeight);
  }

  getData(){

    if (widget.imagesUrl != null && widget.imagesUrl!.isNotEmpty) {
      imgUrls = widget.imagesUrl!
          .split(',') // ✅ If it's a string, split by comma
          .map((img) => "http://scrap.systementerprises.in/${img.trim()}") // ✅ Add Base URL
          .toList();
    }

    materialController.text = widget.material_name ?? '';
    invoiceController.text=widget.invoiceNo ?? 'N/A';
    dateController.text=widget.date ?? 'N/A';
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
    double fullWeight = double.tryParse(fullWeightController.text) ?? 0.0;
    double moistureWeight =
        double.tryParse(moistureWeightController.text) ?? 0.0;

    double netWeight = (fullWeight - firstWeight);
    netWeight = double.parse(
        netWeight.toStringAsFixed(3)); // Rounding to 3 decimal places

    double DMTWeight = ((fullWeight - firstWeight) * moistureWeight) / 100;
    DMTWeight = netWeight - DMTWeight;
    DMTWeight = double.parse(
        DMTWeight.toStringAsFixed(3)); // Rounding to 3 decimal places

    // Update the net weight controller with the result
    netWeightController.text = netWeight.toStringAsFixed(3);
    quantityController.text = DMTWeight.toStringAsFixed(3);
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

  Future<void> editDispatchDetails() async {

    print("⚠️ _images list is empty or null! $_images");

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
      request.fields['invoice_no'] = invoiceController.text;
      request.fields['date_time'] = dateController.text;
      request.fields['truck_no'] = truckNoController.text;
      request.fields['truck_weight'] = firstWeightNoController.text;
      request.fields['full_weight'] = fullWeightController.text;
      request.fields['mois_weight'] = moistureWeightController.text;
      request.fields['net_weight'] = netWeightController.text;
      request.fields['qty'] = quantityController.text;
      request.fields['note'] = noteController.text;

      if (_images != null) {
        print("📸 Total Images: ${_images.length}");


        for (var image in _images) {

          print("📸 Image Debug: ");
          print("   📂 Path: ${image.path}");
          print("   🏷 Name: ${image.path.split('/').last}");
          print("   📏 Size: ${await image.length()} bytes");

          try {
            request.files.add(
              await http.MultipartFile.fromPath(
                'certifications[]',
                image.path,
              ),
            );
            print("✅ Image added to request successfully!");
          } catch (e) {
            print("❌ Error adding image: $e");
          }
        }
      }

// Debug all fields being sent
      print('📤 Fields sent in the request:');
      request.fields.forEach((key, value) {
        print('   🔑 $key: $value');
      });


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

  String getImageData(String imageUrl) {
    return imageUrl;
  }

  // Function to pick images from the gallery
  Future<void> _pickImagesFromGallery() async {

    List<XFile>? pickedImages = await ImagePicker().pickMultiImage();

    if (pickedImages != null) {
      for (var pickedImage in pickedImages) {
        await _compressAndAddImage(pickedImage.path);
      }
    }

  }

// Function to pick images from the gallery _pickImageFromCamera
  Future<void> _pickImageFromCamera() async {

    final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      await _compressAndAddImage(pickedImage.path);
    }

  }

  Future<void> _compressAndAddImage(String imagePath) async {
    File imageFile = File(imagePath);

    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      Img.Image image = Img.decodeImage(Uint8List.fromList(imageBytes))!;
      Img.Image compressedImage = Img.copyResize(image, width: 1024);
      List<int> compressedImageBytes;
      String extension = imagePath.split('.').last.toLowerCase();
      if (extension == 'jpg' || extension == 'jpeg') {
        compressedImageBytes = Img.encodeJpg(compressedImage, quality: 70);
      } else if (extension == 'png') {
        compressedImageBytes = Img.encodePng(compressedImage);
      } else {
        throw UnsupportedError('Unsupported image format: $extension');
      }
      File compressedFile = File(imagePath.replaceAll(RegExp(r'\.\w+$'), '_compressed.$extension'));
      await compressedFile.writeAsBytes(compressedImageBytes);

      setState(() {
        _images.add(compressedFile);
      });
    } catch (e) {
      print('Error during image compression: $e');
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
                  child: ListView(
                    children: [
                      buildTextField("Material", materialController,true, false , Colors.white,context),
                      buildTextField("Invoice No", invoiceController , false,false ,Colors.white, context),
                      buildTextField("Date", dateController, true,false , Colors.white,context),
                      buildTextField("Truck No", truckNoController, true,false ,Colors.white, context),
                      buildTextField("First Weight", firstWeightNoController, false,false ,Colors.white, context),
                      buildTextField("Gross Weight", fullWeightController, false,false , Colors.white,context),
                      buildTextField("Net", netWeightController, true,false ,Colors.grey[400]!, context),
                      buildTextField("Moisture Weight", moistureWeightController, false,false ,Colors.white, context),
                      buildTextField("DMT/Quantity Weight", quantityController, true,false , Colors.white,context),
                      buildTextField("Note", noteController, true,false , Colors.white,context),
                      SizedBox(
                        height: 40,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left Label
                            Text(
                              "Add Images",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),

                            // Right Icons (Image & Camera)
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.image, color: Colors.blue),
                                  onPressed: _pickImagesFromGallery,
                                ),
                                IconButton(
                                  icon: Icon(Icons.camera_alt, color: Colors.green),
                                  onPressed: _pickImageFromCamera, // Use camera picker here if needed
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),


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
                        itemCount: imgUrls.length,
                        itemBuilder: (context, index) {
                          final image = imgUrls[index];

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
                                              onPressed: () => Navigator.of(context).pop(true), // Yes
                                              child: Text("Yes"),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (deleteConfirmed == true) {
                                      setState(() {
                                        imgUrls.removeAt(index);
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

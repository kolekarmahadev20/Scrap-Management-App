import 'dart:convert';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:http/http.dart' as http;
// imports for image uploader
import 'package:image_picker/image_picker.dart';
import 'package:scrapapp/Dispatch/View_dispatch_details.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../URL_CONSTANT.dart'; // Import for File


class Edit_dispatch_details extends StatefulWidget {
  final String sale_order_id;
  final String bidder_id;
  final String lift_id;
  final String? selectedOrderId;
  final String?  material;
  final String?  invoiceNo;
  final String?  date;
  final String?  truckNo;
  final String? firstWeight;
  final String? fullWeight;
  final String? moistureWeight;
  final String? netWeight;
  final String?  quantity;
  final String?  note;

  Edit_dispatch_details({
    required this.sale_order_id,
    required this.bidder_id,
    required this.lift_id,
    required this.selectedOrderId,
    required this.material,
    required this.invoiceNo,
    required this.date,
    required this.truckNo,
    required this.firstWeight,
    required this.fullWeight,
    required this.moistureWeight,
    required this.netWeight,
    required this.quantity,
    required this.note,
  });
  @override
  Edit_dispatch_detailState createState() => Edit_dispatch_detailState();
}

class Edit_dispatch_detailState extends State<Edit_dispatch_details> {
  final TextEditingController materialController = TextEditingController();
  final TextEditingController invoiceController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController truckNoController = TextEditingController();
  final TextEditingController firstWeightNoController = TextEditingController();
  final TextEditingController fullWeightController = TextEditingController();
  final TextEditingController moistureWeightController = TextEditingController();
  final TextEditingController netWeightController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String? username = '';
 String uuid = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';
  String firstWeight= '';
  String fullWeight = '';
  String moistureWeight = '';
  String netWeight = '';
  String? materialId ;
  bool isLoading = false;
  List<File> vehicleFront = [];
  List<File> vehicleBack = [];
  List<File> Material = [];
  List<File> MaterialHalfLoad = [];
  List<File> MaterialFullLoad = [];
  List<File> other = [];
  String? frontVehicle;
  String? backVehicle;
  String? materialImg;
  String? materialHalfLoad;
  String? materialFullLoad;
  String? otherImg;
  Uint8List? imageBytes;

  String advancePayment = '';
  String totalEmd = '';
  String totalCmd = '';
  String rate = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
    fetchImageList();
  }

  Future<void> _initializeData() async{
    await checkLogin().then((_){setState(() {});});
    await materialNameId();
    await getData();
    await fetchPaymentDetails();
    firstWeightNoController.addListener(calculateNetWeight);
    fullWeightController.addListener(calculateNetWeight);
    moistureWeightController.addListener(calculateNetWeight);
  }

  getData(){
      materialController.text=widget.material ?? 'N/A';
      invoiceController.text=widget.invoiceNo ?? 'N/A';
      dateController.text=widget.date ?? 'N/A';
      truckNoController.text=(widget.truckNo ?? 'N/A').toUpperCase();
      firstWeightNoController.text = widget.firstWeight ?? "N/A";
      fullWeightController.text = widget.fullWeight ?? "N/A";
      moistureWeightController.text = widget.moistureWeight ?? "N/A";
      netWeightController.text = widget.netWeight ?? "N/A";
      quantityController.text=widget.quantity ?? 'N/A';
      noteController.text=widget.note ?? 'N/A';
    }

  Future<void> checkLogin() async {
     final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    uuid = prefs.getString("uuid")!;
    uuid = prefs.getString("uuid")!;
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
  }

  void calculateNetWeight() {
    double firstWeight = double.tryParse(firstWeightNoController.text) ?? 0.0;
    double fullWeight = double.tryParse(fullWeightController.text) ?? 0.0;
    double moistureWeight = double.tryParse(moistureWeightController.text) ?? 0.0;

    double netWeight = (fullWeight - firstWeight);

    double DMTWeight = ((fullWeight - firstWeight) * moistureWeight)/100;
    DMTWeight = netWeight-DMTWeight;
    // Update the net weight controller with the result
    netWeightController.text = netWeight.toStringAsFixed(2);
    quantityController.text = DMTWeight.toStringAsFixed(2);
  }

  void clearFields(){
    materialController.clear();
    invoiceController.clear();
    dateController.clear();
    truckNoController.clear();
    quantityController.clear();
    noteController.clear();
  }


  Future<void> materialNameId() async {
    try {
      await checkLogin();
      final url = Uri.parse("${URL}get_materialDesc");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id':username,
          'user_pass':password,
          'sale_order_id':widget.sale_order_id,
          'uuid':uuid
        },
      );
      //variable to send material value instead of name in backend.
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          materialId = jsonData['material_id'];
        });
      } else {
        print("unable to load order ids.");
      }
    } catch (e) {
      print("Server Exception : $e");

    }
  }

  Future<File?> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
    return await FlutterImageCompress.compressAndGetFile(file.absolute.path, targetPath, quality: 20);
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
'uuid':uuid,
          'user_pass': password,
          'sale_order_id':widget.sale_order_id,
        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          advancePayment = jsonData['Advance_payment'].toString()?? 'N/A';
          totalEmd= jsonData['total_EMD'].toString() ?? 'N/A';
          totalCmd= jsonData['total_CMD'].toString()  ?? 'N/A';
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
            textColor: Colors.yellow
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Server Exception : $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.yellow
      );
    }
    finally{
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> editDispatchDetails() async {
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

      // Add images to the request
      Future<void> addImages(List<File> images, String keyword, http.MultipartRequest request) async {
        for (var image in images) {
          File? compressedImage = await compressImage(image);
          if (compressedImage != null) {
            var stream = http.ByteStream(compressedImage.openRead());
            var length = await compressedImage.length();
            var multipartFile = http.MultipartFile(
              'certifications[]',
              stream,
              length,
              filename: '$keyword${compressedImage.path.split('/').last}',
            );
            request.files.add(multipartFile);
          }
        }
      }

      Future<void> submitImage(String fileName, String? keyword, Uint8List? imageByte) async {
        if (imageByte != null) {  // Ensure imageBytes is valid
          var multipartFile = http.MultipartFile.fromBytes(
            'certification[]',
            imageByte,
            filename: '${keyword}${fileName.split('/').last}',
          );
          print(multipartFile.filename);
          request.files.add(multipartFile);
        }
      }

      // Add images from different sources
      if (vehicleFront.isNotEmpty) {
        await addImages(vehicleFront, "Fr", request);
      } else if (frontVehicle != null) {
        await _fetchFileBytesFromServer(frontVehicle!);
        if (imageBytes != null) {
          await submitImage(frontVehicle!, "Fr", imageBytes);
        }
      }

      if (vehicleBack.isNotEmpty) {
        await addImages(vehicleBack, "Ba", request);
      } else if (backVehicle != null) {
        await _fetchFileBytesFromServer(backVehicle!);
        if (imageBytes != null) {
          await submitImage(backVehicle!, "Ba", imageBytes);
        }
      }

      if (Material.isNotEmpty) {
        await addImages(Material, "Ma", request);
      } else if (materialImg != null) {
        await _fetchFileBytesFromServer(materialImg!);
        if (imageBytes != null) {
          await submitImage(materialImg!, "Ma", imageBytes);
        }
      }

      if (MaterialHalfLoad.isNotEmpty) {
        await addImages(MaterialHalfLoad, "Ha", request);
      } else if (materialHalfLoad != null) {
        await _fetchFileBytesFromServer(materialHalfLoad!);
        if (imageBytes != null) {
          await submitImage(materialHalfLoad!, "Ha", imageBytes);
        }
      }

      if (MaterialFullLoad.isNotEmpty) {
        await addImages(MaterialFullLoad, "Fu", request);
      } else if (materialFullLoad != null) {
        await _fetchFileBytesFromServer(materialFullLoad!);
        if (imageBytes != null) {
          await submitImage(materialFullLoad!, "Fu", imageBytes);
        }
      }

      if (other.isNotEmpty) {
        await addImages(other, "ot", request);
      } else if (otherImg != null) {
        await _fetchFileBytesFromServer(otherImg!);
        if (imageBytes != null) {
          await submitImage(otherImg!, "ot", imageBytes);
        }
      }

      // print('Fields sent:');
      // request.fields.forEach((key, value) {
      //   print('$key: $value');
      // });
      //
      // print("**************************************************************");
      //
      // print('Files sent:');
      // request.files.forEach((file) {
      //   print('File: ${file.filename}, length: ${file.length}');
      // });

      // Send the request
      var response = await request.send();


      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        final jsonData = json.decode(res.body);

        print(jsonData);
        print(res);

        if(jsonData.containsKey('liftedTaxAmount')){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${jsonData['msg']} ${jsonData['liftedTaxAmount']}")));
        }else{
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${jsonData['msg']}")));
        }
        if(jsonData['status'] == 'success'){
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => View_dispatch_details(sale_order_id: widget.sale_order_id , bidder_id: widget.bidder_id!),
            ),
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

  Future<void> fetchImageList() async {
    print("sale_order_id");
    print(widget.sale_order_id);
    print(widget.invoiceNo);
    try {


      setState(() {
        isLoading = true;
      });
      await checkLogin();
      final url = Uri.parse("${URL}check_url");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid':uuid,
          'user_pass': password,
          'sale_order_id': widget.sale_order_id,
          'invoice_no': widget.invoiceNo,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          var jsonData = json.decode(response.body);


          // Check if the response is empty
          if (jsonData.isEmpty) {
            print("No data returned from the API.");
            frontVehicle = "";
            backVehicle = "";
            materialImg = "";
            materialHalfLoad = "";
            materialFullLoad = "";
            otherImg = "N/A";
          } else if (jsonData is Map<String, dynamic>) {
            // Handle the valid map response
            frontVehicle = jsonData['Fr'] != null ? '${Image_URL}${jsonData['Fr']}' : "";
            backVehicle = jsonData['Ba'] != null ? '${Image_URL}${jsonData['Ba']}' : "";
            materialImg = jsonData['Ma'] != null ? '${Image_URL}${jsonData['Ma']}' : "";
            materialHalfLoad = jsonData['Ha'] != null ? '${Image_URL}${jsonData['Ha']}' : "";
            materialFullLoad = jsonData['Fu'] != null ? '${Image_URL}${jsonData['Fu']}' : "";
            otherImg = jsonData['ot'] != null ? '${Image_URL}${jsonData['ot']}' : "";
            print("otherImg");


            print(otherImg);

          } else if (jsonData is List) {
            // Handle the case if the response is a list (unexpected)
            print("API returned a list instead of a map. List: $jsonData");
            frontVehicle = "";
            backVehicle = "";
            materialImg = "";
            materialHalfLoad = "";
            materialFullLoad = "";
            otherImg = "";
          } else {
            print("Unexpected data structure: $jsonData");
          }
        });
      } else {
        print("Unable to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Server Exception: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchFileBytesFromServer(String fileUrl) async {
    try {
      var response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode == 200) {
        setState(() {
          imageBytes = response.bodyBytes; // Store image bytes
          print(imageBytes);
          print(fileUrl);
        });
      } else {
        print('Failed to load file from server');
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isLoading,
      child: Scaffold(
        drawer: AppDrawer(currentPage: 5),
        appBar: CustomAppBar(),
        body: Stack(
          children:[
            isLoading
            ?showLoading()
            :Container(
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
                      border:Border.all(color: Colors.blueGrey[400]!),
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
                        SizedBox(height: 8,),
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
                        SizedBox(height: 8,),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      buildTextField("Material", materialController,true, false , Colors.white,context),
                      buildTextField("Invoice No", invoiceController , true,false ,Colors.white, context),
                      buildTextField("Date", dateController, true,false , Colors.white,context),
                      buildTextField("Truck No", truckNoController, true,false ,Colors.white, context),
                      buildTextField("First Weight", firstWeightNoController, false,false ,Colors.white, context),
                      buildTextField("Gross Weight", fullWeightController, false,false , Colors.white,context),
                      buildTextField("Net", netWeightController, true,false ,Colors.grey[400]!, context),
                      buildTextField("Moisture Weight", moistureWeightController, true,false ,Colors.white, context),
                      buildTextField("DMT/Quantity Weight", quantityController, true,false , Colors.white,context),
                      buildTextField("Note", noteController, true,false , Colors.white,context),
                      SizedBox(height: 25,),
                      if( otherImg!= null ||  otherImg!.isNotEmpty)
                        Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Text(
                            //     "View Images",
                            //     style: TextStyle(
                            //         fontWeight: FontWeight.bold,
                            //         fontSize: 24),
                            //   ),
                            // ),
                            // ImageWidget(
                            //   value: '1) Vehicle Front',
                            //   filePath: frontVehicle!,
                            // ),
                            // ImageWidget(
                            //   value: '2) Vehicle Back',
                            //   filePath: backVehicle!,
                            // ),
                            // ImageWidget(
                            //   value: '3) Material',
                            //   filePath: materialImg!,
                            // ),
                            // ImageWidget(
                            //   value: '4) Material Half Load',
                            //   filePath: materialHalfLoad!,
                            // ),
                            // ImageWidget(
                            //   value: '5) Material Full Load',
                            //   filePath: materialFullLoad!,
                            // ),
                            ImageWidget(
                              value: 'View Images',
                              filePath: otherImg!,
                            ),
                          ],
                        ),
                      ),
                      // Container(
                      //
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Padding(
                      //         padding: const EdgeInsets.all(8.0),
                      //         child: Text("Edit Images" , style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                      //       ),
                      //       ImageWidget(
                      //           value: '1) Vehicle Front',
                      //           cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                      //           galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                      //           filePath: frontVehicle!,
                      //           onImagesSelected: (images) { // Handle selected images
                      //             setState(() {
                      //               vehicleFront.addAll(images); // Store uploaded images
                      //               print(vehicleFront);
                      //             });
                      //           }
                      //       ),
                      //       ImageWidget(
                      //           value: '2) Vehicle Back',
                      //           cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                      //           galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                      //           filePath: backVehicle!,
                      //           onImagesSelected: (images) { // Handle selected images
                      //             setState(() {
                      //               vehicleBack.addAll(images); // Store uploaded images
                      //             });
                      //           }
                      //       ),
                      //       ImageWidget(
                      //           value: '3) Material',
                      //           cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                      //           galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                      //           filePath: materialImg!,
                      //           onImagesSelected: (images) { // Handle selected images
                      //             setState(() {
                      //               Material.addAll(images); // Store uploaded images
                      //             });
                      //           }
                      //       ),
                      //       ImageWidget(
                      //           value: '4) Material Half Load',
                      //           cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                      //           galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                      //           filePath: materialHalfLoad!,
                      //           onImagesSelected: (images) { // Handle selected images
                      //             setState(() {
                      //               MaterialHalfLoad.addAll(images); // Store uploaded images
                      //             });
                      //           }
                      //       ),
                      //       ImageWidget(
                      //           value: '5) Material Full Load',
                      //           cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                      //           galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                      //           filePath: materialFullLoad!,
                      //           onImagesSelected: (images) { // Handle selected images
                      //             setState(() {
                      //               MaterialFullLoad.addAll(images); // Store uploaded images
                      //             });
                      //           }
                      //       ),
                      //       ImageWidget(
                      //           value: '6) Other',
                      //           cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                      //           galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                      //           filePath: otherImg!,
                      //           onImagesSelected: (images) { // Handle selected images
                      //             setState(() {
                      //               other.addAll(images); // Store uploaded images
                      //             });
                      //           }
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      SizedBox(height: 60,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                clearFields();
                                Navigator.of(context).pop();
                              },
                              child: Text("Back"),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.indigo[800],
                                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                editDispatchDetails();
                                // clearFields();
                              },
                              child: Text("Save"),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.indigo[800],
                                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
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

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
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

  Widget buildTextField(String label, TextEditingController controller, bool isReadOnly ,bool isDateField ,Color color,context) {
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
                  onTap: isDateField ? () => _selectDate(context, controller) : null,
                  controller: controller,
                  decoration: InputDecoration(
                    suffixIcon: isDateField
                        ? IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context, controller),
                    )
                        :null,
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
          SizedBox(width: 20,)
        ],
      ),
    );
  }
}

class ImageWidget extends StatefulWidget {
  final String value;
  final String? filePath;

  const ImageWidget({
    Key? key,
    required this.value,
    required this.filePath,
  }) : super(key: key);

  @override
  _ImageWidgetState createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  List<File> _images = [];

  Uint8List? imageBytes;


  void showNoImage() {
    Fluttertoast.showToast(
      msg: "No images Found",
      toastLength: Toast.LENGTH_SHORT, // Can be LENGTH_SHORT or LENGTH_LONG
      gravity: ToastGravity.BOTTOM,    // Position of the toast
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

// Function to show a dialog with all the saved images in a pageable view
  void _showImage() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.filePath!.split('/').last,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                imageBytes != null
                    ?Container(
                    height: 300,
                    width: 300,
                    child: Image.memory(imageBytes!, fit: BoxFit.contain))
                    : showLoading(),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Close"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchFileBytesFromServer(String fileUrl) async {
    try {
      var response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode == 200) {
        setState(() {
          imageBytes = response.bodyBytes; // Store image bytes
          _showImage();
        });
      }  else {
        if(imageBytes == null){
          showNoImage();
        }else{
          print("Unable to load the Image");
        }
      }
    } catch (e) {
      if(imageBytes == null){
        showNoImage();
      }else{
        print('Exception: $e');
      }

    } finally {
      setState(() {});
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
                icon: Icon(Icons.photo, color: Colors.blue, size: 30), // ✅ Camera Icon
                onPressed: () {
                  setState(() {
                    if (widget.filePath == null) {
                      showNoImage();
                    } else {
                      _fetchFileBytesFromServer(widget.filePath!);
                    }
                  });
                },
              ),

              // TextButton(
              //   child: Text(
              //     "View",
              //     style: TextStyle(
              //         fontSize: 18,
              //         fontWeight: FontWeight.bold,
              //         color: Colors.green),
              //   ),
              //   onPressed: () {
              //     setState(() {
              //       if(widget.filePath == null){
              //         showNoImage();
              //       }else{
              //         _fetchFileBytesFromServer(widget.filePath!);
              //       }
              //     });
              //   },
              // ),
            ],
          ),
        ),
        _images.isNotEmpty
            ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
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
                ],
              );
            },
          ),
        )
            : Container(),
      ],
    );
  }
}


// class ImageWidget extends StatefulWidget {
//   final String value;
//   final Icon cameraIcon;
//   final Icon galleryIcon;
//   final String? filePath;
//   final Function(List<File>) onImagesSelected;
//
//   const ImageWidget({
//     Key? key,
//     required this.value,
//     required this.cameraIcon,
//     required this.galleryIcon,
//     required this.filePath,
//     required this.onImagesSelected,
//   }) : super(key: key);
//
//   @override
//   _ImageWidgetState createState() => _ImageWidgetState();
// }
//
// class _ImageWidgetState extends State<ImageWidget> {
//
//   List<File> _images = [];
//
//   Uint8List? imageBytes;
//
//   // Function to pick multiple images from the gallery
//   Future<void> _pickImagesFromGallery() async {
//     final picker = ImagePicker();
//     final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery); // Pick only one image
//
//     if (pickedFile != null) {
//       setState(() {
//         _images = [File(pickedFile.path)]; // Replace the list with the new image
//       });
//       widget.onImagesSelected(_images);
//       _showSingleImageNotification();
//     }
//   }
//
//   // Function to capture a single image using the camera
//   Future<void> _captureImageFromCamera() async {
//     final picker = ImagePicker();
//     final XFile? capturedFile = await picker.pickImage(source: ImageSource.camera);
//
//     if (capturedFile  != null) {
//       setState(() {
//         _images = [File(capturedFile.path)]; // Replace the list with the new captured image
//       });
//       widget.onImagesSelected(_images);
//       _showSingleImageNotification();
//     }
//   }
//
//   // Function to show a SnackBar notifying the user
//   void _showSingleImageNotification() {
//     // Use Future to delay the snackbar to ensure widget is mounted
//     Future.delayed(Duration.zero, () {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("You can only upload one image at a time."),
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//     });
//   }
//   // Function to delete a selected image
//   void _deleteImage(int index) {
//     setState(() {
//       _images.removeAt(index); // Remove the image at the specified index
//       widget.onImagesSelected(_images); // Update parent with the new list
//       print(widget.onImagesSelected(_images));
//     });
//   }
//
//
//   Future<void> _fetchFileBytesFromServer(String fileUrl) async {
//     try {
//       var response = await http.get(Uri.parse(fileUrl));
//       if(response.statusCode == 200) {
//         setState(() {
//           imageBytes = response.bodyBytes;
//           _showImage();
//         });
//       } else {
//         if(imageBytes == null){
//           showNoImage();
//         }else{
//           print("Unable to load the Image");
//         }
//       }
//     } catch (e) {
//       if(imageBytes == null){
//         showNoImage();
//       }else{
//         print('Exception: $e');
//       }
//     } finally {
//       setState(() {});
//     }
//   }
//
//   void showNoImage() {
//     Fluttertoast.showToast(
//       msg: "No images Found",
//       toastLength: Toast.LENGTH_SHORT, // Can be LENGTH_SHORT or LENGTH_LONG
//       gravity: ToastGravity.BOTTOM,    // Position of the toast
//       backgroundColor: Colors.black,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//   }
//
//
//   void _showImage() {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return Container(
//           width: double.infinity,
//           padding: EdgeInsets.all(16.0),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   widget.filePath!.split('/').last,
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 10),
//                 imageBytes != null
//                     ?Container(
//                     height: 300,
//                     width: 300,
//                     child: Positioned.fill(
//                         child: Image.memory(imageBytes!, fit: BoxFit.contain)))
//                     : showLoading(),
//                 SizedBox(height: 10),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: Text("Close"),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   showLoading() {
//     return Container(
//       height: double.infinity,
//       width: double.infinity,
//       color: Colors.black.withOpacity(0.4),
//       child: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Text(
//                 widget.value,
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               Spacer(),
//               TextButton(
//                 child:Text("View",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold ,color: Colors.green),
//                 ),
//                 onPressed: (){
//                   if(widget.filePath == null){
//                     showNoImage();
//                   }else{
//                   _fetchFileBytesFromServer(widget.filePath!);
//                   }
//                 },
//               ),
//               IconButton(
//                 icon: widget.cameraIcon,
//                 onPressed: _captureImageFromCamera, // Calls the camera function
//               ),
//               IconButton(
//                 icon: widget.galleryIcon,
//                 onPressed: _pickImagesFromGallery, // Calls the gallery picker function
//               ),
//             ],
//           ),
//         ),
//         _images.isNotEmpty
//             ? Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: GridView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3, // Display 3 images per row
//               crossAxisSpacing: 4.0,
//               mainAxisSpacing: 4.0,
//             ),
//             itemCount: _images.length,
//             itemBuilder: (context, index) {
//               return Stack(
//                 children: [
//                   Container(
//                     height: 100, // Set fixed height for images
//                     width: 100, // Set fixed width for images
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(8), // Rounded corners
//                       child: Image.file(
//                         _images[index],
//                         fit: BoxFit.cover, // Ensure the image fits within the container
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     top: 0,
//                     right: 0,
//                     child: IconButton(
//                       icon: Icon(Icons.delete, color: Colors.red),
//                       onPressed: () => _deleteImage(index), // Delete the selected image
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         )
//         : Container(),
//       ],
//     );
//   }
// }



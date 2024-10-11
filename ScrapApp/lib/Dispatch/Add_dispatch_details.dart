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

class Add_dispatch_details extends StatefulWidget {
  @override
  _Add_dispatch_detailState createState() => _Add_dispatch_detailState();
}

class _Add_dispatch_detailState extends State<Add_dispatch_details> {
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
  String? password = '';
  String? selectedOrderId;
  bool isLoading = false;
  List<String> orderIDs = ['Select',];
  Map<String,String> dropDownMap= {
    'Select' : 'Select',
  };
  String? MaterialSelected;
  String? materialId ;
  List<File> vehicleFront = [];
  List<File> vehicleBack = [];
  List<File> Material = [];
  List<File> MaterialHalfLoad = [];
  List<File> MaterialFullLoad = [];
  List<File> other = [];


  void clearFields(){
    selectedOrderId = null;
    materialController.clear();
    invoiceController.clear();
    dateController.clear();
    truckNoController.clear();
    quantityController.clear();
    noteController.clear();
  }

  @override
  void initState(){
    super.initState();
    checkLogin();
    fetchDropDwonKeyValuePair();
    firstWeightNoController.addListener(calculateNetWeight);
    fullWeightController.addListener(calculateNetWeight);
    moistureWeightController.addListener(calculateNetWeight);
  }

  checkLogin()async{
    final login = await SharedPreferences.getInstance();
    username = await login.getString("username") ?? '';
    password = await login.getString("password") ?? '';
  }

  void calculateNetWeight() {
    double firstWeight = double.tryParse(firstWeightNoController.text) ?? 0.0;
    double fullWeight = double.tryParse(fullWeightController.text) ?? 0.0;
    double moistureWeight = double.tryParse(moistureWeightController.text) ?? 0.0;

    double netWeight = fullWeight - firstWeight - moistureWeight;

    // Update the net weight controller with the result
    netWeightController.text = netWeight.toStringAsFixed(2);
  }

  //fetching dropDowns of sale_order_list
  Future<void> fetchDropDwonKeyValuePair() async {
    try {
      setState(() {
        isLoading = true;
      });
      await checkLogin();
      final url = Uri.parse("${URL}fetch_payment_data");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'user_pass': password,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          var jsonData = json.decode(response.body);
          // Extract the relevant data
          List<Map<String, dynamic>> keyValuePair = List<Map<String, dynamic>>.from(jsonData['saleOrder_paymentList']);
          for (var keyValue in keyValuePair) {
            // Example key-value pairs of sale_order_code and vendor_name
            var saleOrderCode = keyValue['sale_order_code'] ?? "N/A";
            var saleOrderId = keyValue['sale_order_id']?? "N/A";

            // You can store these key-value pairs in a map if needed
            dropDownMap[saleOrderCode] = saleOrderId;
          }
          print(dropDownMap);
        });
      } else {
        print("Unable to fetch data.");
      }
    } catch (e) {
      print("Server Exception: $e");
    }finally{
      setState(() {
        isLoading = false;
      });
    }
  }


  //fetching the material of selected sale_order_id
  Future<void> orderIdMaterial() async {
    try {
      await checkLogin();
      final url = Uri.parse("${URL}fetch_material_lifting");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id':username,
          'user_pass':password,
          'sale_order_id': selectedOrderId ?? '',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          materialController.text = jsonData['sale_order_details'][0]['material_name'];
          print(materialController.text);
        });
      } else {
        print("unable to load order ids.");
      }
    } catch (e) {
      print("Server Exception : $e");

    }
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
          'sale_order_id':selectedOrderId,
        },
      );
      //variable to send material value instead of name in backend.
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          materialId = jsonData['material_id'];
          print(materialId);
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
    final targetPath = path.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
    return await FlutterImageCompress.compressAndGetFile(file.absolute.path, targetPath, quality: 20);
  }

  Future<void> addDispatchDetails() async {
    try {
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
      request.fields['sale_order_id_lift'] = selectedOrderId ?? '';
      request.fields['material_id_lifting'] = materialId ?? '';
      request.fields['invoice_no'] = invoiceController.text;
      request.fields['date_time'] = dateController.text;
      request.fields['truck_no'] = truckNoController.text;
      request.fields['truck_weight'] = firstWeightNoController.text;
      request.fields['full_weight'] = fullWeightController.text;
      request.fields['mois_weight'] = moistureWeightController.text;
      request.fields['net_weight'] = netWeightController.text;
      request.fields['qty'] = quantityController.text;
      request.fields['note'] = noteController.text;

      // Print fields before adding images
      // print('Fields sent:');
      // request.fields.forEach((key, value) {
      //   print('$key: $value');
      // });
      //
      // print("**************************************************************");

      // Function to add images to the request
      Future<void> addImages(List<File> images, String keyword, http.MultipartRequest request) async {
        for (var image in images) {
          // Compress the image before uploading
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
            request.files.add(multipartFile);  // Add compressed file
          }
        }
      }

      // Add images from different sources
      if (vehicleFront.isNotEmpty) {
        await addImages(vehicleFront, "Fr", request);
      }
      if (vehicleBack.isNotEmpty) {
        await addImages(vehicleBack, "Ba", request);
      }
      if (Material.isNotEmpty) {
        await addImages(Material, "Ma", request);
      }
      if (MaterialHalfLoad.isNotEmpty) {
        await addImages(MaterialHalfLoad, "Ha", request);
      }
      if (MaterialFullLoad.isNotEmpty) {
        await addImages(MaterialFullLoad, "Fu", request);
      }
      if (other.isNotEmpty) {
        await addImages(other, "ot", request);
      }

      // Log the files being sent after adding images
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
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${jsonData['msg']}")));
        });
        Navigator.pop(context);
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
      print("Error: $e");
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

  showLoading(){
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.transparent,
      child: Center(child: CircularProgressIndicator(),),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isLoading,
      child: Scaffold(
        drawer: AppDrawer(),
        appBar: CustomAppBar(),
        body: Stack(
          children: [
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
                              "ADD MATERIAL LIFTING DETAIL",
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
                      buildDropdown("Order ID", dropDownMap, (value) {
                        setState(() {
                          selectedOrderId = value;
                          materialController.clear();
                          orderIdMaterial();
                          materialNameId();
                        });
                      }),
                      buildTextField("Material", materialController,true, false , context),
                      buildTextField("Invoice No", invoiceController , false,false , context),
                      buildTextField("Date", dateController, false,true , context),
                      buildTextField("Truck No", truckNoController, false,false , context),
                      buildTextField("First Weight", firstWeightNoController, false,false , context),
                      buildTextField("Full Weight", fullWeightController, false,false , context),
                      buildTextField("Moisture Weight", moistureWeightController, false,false , context),
                      buildTextField("Net Weight", netWeightController, true,false , context),
                      buildTextField("Quantity", quantityController, false,false , context),
                      buildTextField("Note", noteController, false,false , context),
                      SizedBox(height: 40,),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(thickness: 1.5,color: Colors.black54),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Upload Images" , style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                            ),
                            Divider(thickness: 1.5,color: Colors.black54),
                            ImageWidget(
                              value: '1) Vehicle Front',
                              cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                              galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                              onImagesSelected: (images) { // Handle selected images
                              setState(() {
                                vehicleFront.addAll(images); // Store uploaded images
                              });
                              }
                            ),
                            ImageWidget(
                              value: '2) Vehicle Back',
                              cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                              galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                                onImagesSelected: (images) { // Handle selected images
                                  setState(() {
                                    vehicleBack.addAll(images); // Store uploaded images
                                  });
                                }
                            ),
                            ImageWidget(
                              value: '3) Material',
                              cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                              galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                                onImagesSelected: (images) { // Handle selected images
                                  setState(() {
                                    Material.addAll(images); // Store uploaded images
                                  });
                                }
                            ),
                            ImageWidget(
                              value: '4) Material Half Load',
                              cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                              galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                                onImagesSelected: (images) { // Handle selected images
                                  setState(() {
                                    MaterialHalfLoad.addAll(images); // Store uploaded images
                                  });
                                }
                            ),
                            ImageWidget(
                              value: '5) Material Full Load',
                              cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                              galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                                onImagesSelected: (images) { // Handle selected images
                                  setState(() {
                                    MaterialFullLoad.addAll(images); // Store uploaded images
                                  });
                                }
                            ),
                            ImageWidget(
                              value: '6) Other',
                              cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                              galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                                onImagesSelected: (images) { // Handle selected images
                                  setState(() {
                                    other.addAll(images); // Store uploaded images
                                  });
                                }
                            ),
                          ],
                        ),
                      ),
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
                                addDispatchDetails();
                                // clearFields();
                              },
                              child: Text("Add"),
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

  Widget buildDropdown(String label, Map<String,String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0 , horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
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
              value: selectedOrderId ?? options.keys.first,
              items: options.entries.map((option) {
                return DropdownMenuItem<String>(
                  value: option.value,
                  child: Text(option.key),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
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


  Widget buildTextField(
      String label, TextEditingController controller, bool isReadOnly ,bool isDateField ,context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3, // Adjusts label width
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 7, // Adjusts text field width
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
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery); // Pick only one image

    if (pickedFile != null) {
      setState(() {
        _images = [File(pickedFile.path)]; // Replace the list with the new image
      });
      widget.onImagesSelected(_images);
      _showSingleImageNotification();
    }
  }

  // Function to capture a single image using the camera
  Future<void> _captureImageFromCamera() async {
    final picker = ImagePicker();
    final XFile? capturedFile = await picker.pickImage(source: ImageSource.camera);

    if (capturedFile  != null) {
      setState(() {
        _images = [File(capturedFile.path)]; // Replace the list with the new captured image
      });
      widget.onImagesSelected(_images);
      _showSingleImageNotification();
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
                onPressed: _pickImagesFromGallery, // Calls the gallery picker function
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
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                    child: Image.file(
                      _images[index],
                      fit: BoxFit.cover, // Ensure the image fits within the container
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteImage(index), // Delete the selected image
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


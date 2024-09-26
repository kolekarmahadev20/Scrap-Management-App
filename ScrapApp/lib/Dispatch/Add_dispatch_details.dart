import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../URL_CONSTANT.dart';
// imports for image uploader
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Import for File


class Add_dispatch_details extends StatefulWidget {
  @override
  _Add_dispatch_detailState createState() => _Add_dispatch_detailState();
}

class _Add_dispatch_detailState extends State<Add_dispatch_details> {
  final TextEditingController materialController = TextEditingController();
  final TextEditingController invoiceController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController truckNoController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController noteController = TextEditingController();



  String? username = '';
  String? password = '';
  String? selectedOrderId;
  bool isLoading = false;
  List<String> orderIDs = ['Select',];
  String? MaterialSelected;
  String? materialId ;
  List<File> _uploadedImages = [];




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
    orderIdDropDowns();

  }

  checkLogin()async{
    final login = await SharedPreferences.getInstance();
    username = await login.getString("username") ?? '';
    password = await login.getString("password") ?? '';
  }

  //fetching dropDowns of sale_order_list
  Future<void> orderIdDropDowns() async {
    try {
      await checkLogin();
      final url = Uri.parse("${URL}saleOrder_list");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id':username,
          'user_pass':password,
        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          for(var entry in jsonData){
            if (entry['id'] != null) {
              orderIDs.add(entry['id']);
            }else{
              orderIDs.add("N/A");
            }
          }
        });
      } else {
        print("unable to load order ids.");
      }
    } catch (e) {
      print("Server Exception : $e");

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
      request.fields['user_pass'] = password! ;
      request.fields['sale_order_id_lift'] = selectedOrderId ?? '';
      request.fields['material_id_lifting'] = materialId ?? ''; // sending material Id instead of material Name
      request.fields['invoice_no'] = invoiceController.text;
      request.fields['date_time'] = dateController.text;
      request.fields['truck_no'] = truckNoController.text;
      request.fields['qty'] = quantityController.text;
      request.fields['note'] = noteController.text;


      print('Form Data: ${request.fields}');

      // Add images to the request
      for (var image in _uploadedImages) {
        var stream = http.ByteStream(image.openRead());
        var length = await image.length();
        var multipartFile = http.MultipartFile('certifications[]', stream, length, filename: image.path.split('/').last);
        request.files.add(multipartFile);
      }

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
      print("print");

      Fluttertoast.showToast(
        msg: 'Server Exception: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.yellow,
      );
    }finally{
      setState(() {
        isLoading = false;
      });
    }
  }

  showLoading(){
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.black.withOpacity(0.4),
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
                Divider(
                  thickness: 1.5,
                  color: Colors.black54,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Add",
                      style: TextStyle(
                        fontSize: 16, // Keep previous font size
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Divider(
                  thickness: 1.5,
                  color: Colors.black54,
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      buildDropdown("Order ID", orderIDs, (value) {
                        setState(() {
                          selectedOrderId = value;
                          materialController.clear();
                          orderIdMaterial();
                          materialNameId();
                          print(value);

                        });
                      }),
                      buildTextField("Material", materialController,true, false , context),
                      buildTextField("Invoice No", invoiceController , false,false , context),
                      buildTextField("Date", dateController, false,true , context),
                      buildTextField("Truck No", truckNoController, false,false , context),
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
                              _uploadedImages.addAll(images); // Store uploaded images
                              });
                              }
                            ),
                            ImageWidget(
                              value: '2) Vehicle Back',
                              cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                              galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                                onImagesSelected: (images) { // Handle selected images
                                  setState(() {
                                    _uploadedImages.addAll(images); // Store uploaded images
                                  });
                                }
                            ),
                            ImageWidget(
                              value: '3) Material',
                              cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                              galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                                onImagesSelected: (images) { // Handle selected images
                                  setState(() {
                                    _uploadedImages.addAll(images); // Store uploaded images
                                  });
                                }
                            ),
                            ImageWidget(
                              value: '4) Material Half Load',
                              cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                              galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                                onImagesSelected: (images) { // Handle selected images
                                  setState(() {
                                    _uploadedImages.addAll(images); // Store uploaded images
                                  });
                                }
                            ),
                            ImageWidget(
                              value: '5) Material Full Load',
                              cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                              galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                                onImagesSelected: (images) { // Handle selected images
                                  setState(() {
                                    _uploadedImages.addAll(images); // Store uploaded images
                                  });
                                }
                            ),
                            ImageWidget(
                              value: '6) Other',
                              cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                              galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                                onImagesSelected: (images) { // Handle selected images
                                  setState(() {
                                    _uploadedImages.addAll(images); // Store uploaded images
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

  Widget buildDropdown(String label, List<String> options, ValueChanged<String?> onChanged) {
    return StatefulBuilder(builder: (BuildContext context , StateSetter setState)
    {
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
              flex: 7, // Adjusts dropdown width
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: selectedOrderId ?? options.first,
                items: options.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                    enabled: option != 'Select',
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      );
    });
  }


  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
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
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
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
    final List<XFile>? pickedFiles = await picker.pickMultiImage(); // For multiple image selection

    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
      widget.onImagesSelected(_images);
      print(widget.onImagesSelected(_images));
    }
  }

  // Function to capture a single image using the camera
  Future<void> _captureImageFromCamera() async {
    final picker = ImagePicker();
    final XFile? capturedFile = await picker.pickImage(source: ImageSource.camera);

    if (capturedFile != null) {
      setState(() {
        _images.add(File(capturedFile.path)); // Add the captured image to the list
      });
      widget.onImagesSelected(_images);
      print(widget.onImagesSelected(_images));
    }
  }

  // Function to delete a selected image
  void _deleteImage(int index) {
    setState(() {
      _images.removeAt(index); // Remove the image at the specified index
      widget.onImagesSelected(_images); // Update parent with the new list
      print(widget.onImagesSelected(_images));

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


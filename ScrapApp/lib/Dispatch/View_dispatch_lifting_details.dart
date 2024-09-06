import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Dispatch/Edit_dispatch_details.dart';

// imports for image uploader
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Import for File

class View_dispatch_lifting_details extends StatelessWidget {
  String selectedOrderId ='';
  String material='';
  String invoiceNo='';
  String date='';
  String truckNo='';
  String quantity='';
  String note='';



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: CustomAppBar(),
      body: Container(
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
                Spacer(),
                Text(
                  "View",
                  style: TextStyle(
                    fontSize: 16, // Keep previous font size
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: 30, // Keep previous icon size
                    color: Colors.indigo[800],
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Edit_dispatch_details()));
                  },
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
                  buildDisplayField("Order ID", selectedOrderId),
                  buildDisplayField("Material", material),
                  buildDisplayField("Invoice No", invoiceNo),
                  buildDisplayField("Date", date),
                  buildDisplayField("Truck No", truckNo),
                  buildDisplayField("Quantity", quantity),
                  buildDisplayField("Note", note),
                  SizedBox(height: 100,),
                  Container(

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("View Images" , style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                        ),
                        ImageWidget(
                          value: '1) Vehicle Front',
                          cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                          galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                        ),
                        ImageWidget(
                          value: '2) Vehicle Back',
                          cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                          galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                        ),
                        ImageWidget(
                          value: '3) Material',
                          cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                          galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                        ),
                        ImageWidget(
                          value: '4) Material Half Load',
                          cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                          galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                        ),
                        ImageWidget(
                          value: '5) Material Full Load',
                          cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                          galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                        ),
                        ImageWidget(
                          value: '6) Other',
                          cameraIcon: Icon(Icons.camera_alt, color: Colors.blue),
                          galleryIcon: Icon(Icons.photo_library, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 60,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
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
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDisplayField(String label, String value) {
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
            flex: 7, // Adjusts text display width
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.black87,
                  ),
                ),
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

  const ImageWidget({
    Key? key,
    required this.value,
    required this.cameraIcon,
    required this.galleryIcon,
  }) : super(key: key);

  @override
  _ImageWidgetState createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  List<File> _images = [];
  int _currentPage = 0;
  // Function to pick multiple images from the gallery
  Future<void> _pickImagesFromGallery() async {
    final picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage(); // For multiple image selection

    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
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
    }
  }

  // Function to delete a selected image
  void _deleteImage(int index) {
    setState(() {
      _images.removeAt(index); // Remove the image at the specified index
    });
  }

// Function to show a dialog with all the saved images in a pageable view
  void _showImagesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("View Images"),
              content: _images.isEmpty ? Center(child: Text("No images to be found ")):
              Container(
                width: double.maxFinite,
                height: 300,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: _images.length,
                      controller: PageController(initialPage: _currentPage),
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _images[index],
                                fit: BoxFit.cover,
                                height: 250, // Adjust height as needed
                                width: double.infinity,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${index + 1} of ${_images.length}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        );
                      },
                    ),
                    // Left arrow to navigate to the previous image

                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      },
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
              TextButton(
                child:Text("View",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold ,color: Colors.green),
                ),
                onPressed: (){
                  _showImagesDialog();
                },
              ),
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
                      ),
            )
            : Container(),
      ],
    );
  }
}
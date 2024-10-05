import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Dispatch/Edit_dispatch_details.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../URL_CONSTANT.dart'; // Import for File

class View_dispatch_lifting_details extends StatefulWidget {
  final String sale_order_id;
  final String lift_id;
  final String? selectedOrderId;
  final String? material;
  final String? invoiceNo;
  final String? date;
  final String? truckNo;
  final String? quantity;
  final String? note;

  View_dispatch_lifting_details({
    required this.sale_order_id,
    required this.lift_id,
    required this.selectedOrderId,
    required this.material,
    required this.invoiceNo,
    required this.date,
    required this.truckNo,
    required this.quantity,
    required this.note,
  });

  @override
  State<View_dispatch_lifting_details> createState() =>
      _View_dispatch_lifting_detailsState();
}

class _View_dispatch_lifting_detailsState
    extends State<View_dispatch_lifting_details> {
  String? username = '';

  String? password = '';

  String selectedOrderId = '';

  String material = '';

  String invoiceNo = '';

  String date = '';

  String truckNo = '';

  String quantity = '';

  String note = '';

  bool isLoading = false;

  String? frontVehicle;
  String? backVehicle;
  String? materialImg;
  String? materialHalfLoad;
  String? materialFullLoad;
  String? otherImg;

  @override
  void initState() {
    super.initState();
    checkLogin();
    fetchImageList();
    selectedOrderId = widget.selectedOrderId ?? "N/A";
    material = widget.material ?? 'N/A';
    invoiceNo = widget.invoiceNo ?? 'N/A';
    date = widget.date ?? 'N/A';
    truckNo = widget.truckNo ?? 'N/A';
    quantity = widget.quantity ?? 'N/A';
    note = widget.note ?? 'N/A';
  }

  checkLogin() async {
    final login = await SharedPreferences.getInstance();
    username = await login.getString("username") ?? '';
    password = await login.getString("password") ?? '';
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

  Future<void> fetchImageList() async {
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
          'user_pass': password,
          'sale_order_id': widget.sale_order_id,
          'invoice_no': widget.invoiceNo,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          var jsonData = json.decode(response.body);
          print(jsonData);
          frontVehicle = '${Image_URL}${jsonData['Fr']}';
          backVehicle = '${Image_URL}${jsonData['Ba']}';
          materialImg = '${Image_URL}${jsonData['Ma']}';
          materialHalfLoad = '${Image_URL}${jsonData['Ha']}';
          materialFullLoad = '${Image_URL}${jsonData['Fu']}';
          otherImg = '${Image_URL}${jsonData['ot']}';
        });
      } else {
        print("Unable to fetch data.");
      }
    } catch (e) {
      print("Server Exception: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Future<void> downloadFile(String url, String fileName) async {
  //
  //   try {
  //     print('Fetching file from URL: $url');
  //     final response = await http.get(Uri.parse(url));
  //
  //     if (response.statusCode == 200) {
  //       final directory = await getTemporaryDirectory();
  //       final filePath = '${directory.path}/$fileName';
  //       final file = File(filePath);
  //
  //       await file.writeAsBytes(response.bodyBytes);
  //       print('File saved to: $filePath');
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('File downloaded: $fileName')),
  //       );
  //       // Open the file
  //       OpenFile.open(filePath);
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to download file: ${response.statusCode}')),
  //       );
  //     }
  //   } catch (e) {
  //     print('Exception: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: $e')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: CustomAppBar(),
      body: isLoading
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
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Edit_dispatch_details(
                                        sale_order_id: widget.sale_order_id,
                                        lift_id: widget.lift_id,
                                        material: material,
                                        invoiceNo: invoiceNo,
                                        truckNo: truckNo,
                                        note: note,
                                        quantity: quantity,
                                        selectedOrderId: selectedOrderId,
                                        date: date,
                                      )));
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
                        SizedBox(
                          height: 100,
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "View Images",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24),
                                ),
                              ),
                              ImageWidget(
                                value: '1) Vehicle Front',
                                filePath: frontVehicle!,
                              ),
                              ImageWidget(
                                value: '2) Vehicle Back',
                                filePath: backVehicle!,
                              ),
                              ImageWidget(
                                value: '3) Material',
                                filePath: materialImg!,
                              ),
                              ImageWidget(
                                value: '4) Material Half Load',
                                filePath: materialHalfLoad!,
                              ),
                              ImageWidget(
                                value: '5) Material Full Load',
                                filePath: materialFullLoad!,
                              ),
                              ImageWidget(
                                value: '6) Other',
                                filePath: otherImg!,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 60,
                        ),
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 12),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
  final String filePath;

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

// Function to show a dialog with all the saved images in a pageable view
  _showImage() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("${widget.filePath.split('/').last}"),
            content: imageBytes != null
                ? Image.memory(imageBytes!, fit: BoxFit.fill)
                : showLoading(),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK"))
            ],
          );
        });
  }

  Future<void> _fetchFileBytesFromServer(String fileUrl) async {
    try {
      var response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode == 200) {
        setState(() {
          imageBytes = response.bodyBytes; // Store image bytes
          _showImage();
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
                child: Text(
                  "View",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                onPressed: () {
                  setState(() {
                    _fetchFileBytesFromServer(widget.filePath);
                  });
                },
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

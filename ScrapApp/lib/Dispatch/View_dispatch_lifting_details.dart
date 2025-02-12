import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
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
  final String bidder_id;
  final String lift_id;
  final String? selectedOrderId;
  final String? material;
  final String? invoiceNo;
  final String? date;
  final String? truckNo;
  final String? firstWeight;
  final String? fullWeight;
  final String? moistureWeight;
  final String? netWeight;
  final String? quantity;
  final String? note;

  View_dispatch_lifting_details({
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
  State<View_dispatch_lifting_details> createState() => _View_dispatch_lifting_detailsState();
}

class _View_dispatch_lifting_detailsState
    extends State<View_dispatch_lifting_details> {
  String? username = '';
 String uuid = '';

  String? password = '';
  String? loginType = '';
  String? userType = '';


  String selectedOrderId = '';

  String material = '';

  String invoiceNo = '';

  String date = '';

  String truckNo = '';

  String firstWeight= '';

  String fullWeight = '';

  String moistureWeight = '';

  String netWeight = '';

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
    checkLogin().then((_){
      setState(() {});
    });
    fetchImageList();
    getData();
    print("Hello");
    print(widget.bidder_id);
    print("Hello");

  }


  getData(){
    selectedOrderId = widget.selectedOrderId ?? "N/A";
    material = widget.material ?? 'N/A';
    invoiceNo = widget.invoiceNo ?? 'N/A';
    date = widget.date ?? 'N/A';
    truckNo = widget.truckNo ?? 'N/A';
    firstWeight = widget.firstWeight ?? "N/A";
    fullWeight = widget.fullWeight ?? "N/A";
    moistureWeight = widget.moistureWeight ?? "N/A";
    netWeight = widget.netWeight ?? "N/A";
    quantity = widget.quantity ?? 'N/A';
    note = widget.note ?? 'N/A';

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
'uuid':uuid,
          'user_pass': password,
          'sale_order_id': widget.sale_order_id,
          'invoice_no': widget.invoiceNo,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          var jsonData = json.decode(response.body);

          print("Response Data: $jsonData");

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
      drawer: AppDrawer(currentPage: 5),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Spacer(),
                          Text(
                            "VIEW MATERIAL LIFTING DETAIL",
                            style: TextStyle(
                              fontSize: 16, // Keep previous font size
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                          Opacity(
                            // opacity: (userType == 'S' || userType == 'A') ? 1.0 : 0.0,
                            opacity: 1.0,
                            child: IconButton(
                              icon: Icon(
                                Icons.edit,
                                size: 30, // Keep previous icon size
                                color: Colors.indigo[800],
                              ),
                              onPressed: (userType == 'S' || userType == 'A' || userType == 'U')
                                  ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Edit_dispatch_details(
                                      sale_order_id: widget.sale_order_id,
                                      bidder_id: widget.bidder_id,
                                      lift_id: widget.lift_id,
                                      material: material,
                                      invoiceNo: invoiceNo,
                                      truckNo: truckNo,
                                      firstWeight: firstWeight,
                                      fullWeight: fullWeight,
                                      moistureWeight: moistureWeight,
                                      netWeight: netWeight,
                                      note: note,
                                      quantity: quantity,
                                      selectedOrderId: selectedOrderId,
                                      date: date,
                                    ),
                                  ),
                                );
                              }
                                  : null, // Disable the onPressed when opacity is 0
                            ),
                          ),
                        ],
                      ),
                    ),
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
                        buildDisplayField("First Weight", firstWeight),
                        buildDisplayField("Full Weight", fullWeight),
                        buildDisplayField("Moisture Weight",moistureWeight),
                        buildDisplayField("Net Weight",netWeight),
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
                    if(widget.filePath == null){
                      showNoImage();
                    }else{
                      _fetchFileBytesFromServer(widget.filePath!);
                    }
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

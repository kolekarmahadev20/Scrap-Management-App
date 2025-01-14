import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';
import '../Model/VendorData.dart';
import '../Pages/StartPage.dart';
import '../URL_CONSTANT.dart';

class Vendor_list extends StatefulWidget {
  final int currentPage;
  Vendor_list({required this.currentPage});

  @override
  _Vendor_listState createState() => _Vendor_listState();
}

class _Vendor_listState extends State<Vendor_list> {
  List<VendorData> vendorsData = [];

  Future<List<VendorData>> _vendorDataFuture =
      Future<List<VendorData>>.value([]);

  TextEditingController _searchController = TextEditingController();

  //Variables for user details
  String? username = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';

  @override
  void initState() {
    super.initState();
    _vendorDataFuture = _getVendorData();
    checkLogin();
  }

  //Fetching user details from sharedpreferences
  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
  }

  void _updateSealList(String query) {
    setState(() {
      // Update the Future with the filtered data based on the search query
      // _sealDataFuture = _getSealData(query: query);
    });
  }

  Future<List<VendorData>> _getVendorData() async {
    await checkLogin();

    try {
      // Prepare the request body with user credentials
      Map<String, dynamic> requestBody = {
        'user_id': username,
        'user_pass': password,
      };

      // Make an HTTP POST request to the API endpoint
      final response = await http.post(
        Uri.parse('${URL}ajax_auctioneer_list'),
        headers: {"Accept": "application/json"},
        body: requestBody,
      );

      // Check if the response status code is 200 (OK)
      if (response.statusCode == 200) {
        // Parse the response body as JSON
        final data = json.decode(response.body);
        print(data);
        print("sfdefe");

        // Check if the API response contains the vendor list
        if (data["vendor_list"] != null) {
          // Create a list to store the fetched vendor data
          List<VendorData> fetchedVendorsData = [];

          // Iterate through each vendor in the response data
          for (var vendor in data["vendor_list"]) {
            // Initialize a new VendorData object based on the response data
            VendorData vendorData = VendorData(
              srNo: vendor[0]?.toString() ?? "",
              name: vendor[1] ?? "",
              email: vendor[2]?.replaceAll('<br>', '\n') ?? "",
              phone: vendor[3]?.replaceAll('<br>', '\n') ?? "",
              addressLine1: vendor[4] ?? "",
              addressLine2: vendor[5] ?? "",
              state: vendor[6] ?? "",
              country: vendor[7] ?? "",
              postalCode: vendor[8] ?? "",
              gstNumber: vendor[9] ?? "",
              remarks: vendor[10] ?? "",
              contactPerson: vendor[11] ?? "",
            );

            // Add the VendorData object to the list
            fetchedVendorsData.add(vendorData);
          }

          setState(() {
            vendorsData = List.from(fetchedVendorsData);
          });

          // Return the fetched vendor data
          return fetchedVendorsData;
        }
      }
    } catch (e) {
      // Print and rethrow the error to be handled by FutureBuilder
      print('Error: $e');
      throw e;
    }

    // Return an empty list if data fetching fails
    return [];
  }

  Future<void> deleteVendor(String Vendor_id) async {
    try {
      print(Vendor_id);
      final response = await http.post(
        Uri.parse('${URL}auctioneer_delete'),
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'user_pass': password,
          'object_id': Vendor_id,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["status"] == "1") {
          print('Seal record deleted successfully');
          setState(() {
            // _sealDataFuture = _getSealData(); // Refresh the seal data
          });
        } else {
          print('Failed to delete seal record: ${data["msg"]}');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<bool> _onWillPop() async {
    bool exit = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    );

    if (exit != null && exit) {
      SystemNavigator.pop(); // Exit the app
    }

    return exit ?? false;
  }

  Future<void> _refreshData() async {
    setState(() {
      // _sealDataFuture = _getSealData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        drawer: AppDrawer(currentPage: widget.currentPage),
        appBar: CustomAppBar(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => VendorForm()),
            // );
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.blueGrey[200], // FAB background color
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await _refreshData();
          },
          child: FutureBuilder<List<VendorData>>(
            future: _vendorDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No data available'));
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Display the "View Seals" card at the top
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Vendor",
                                style: TextStyle(
                                  fontSize:
                                      24, // Slightly larger font size for prominence
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (query) {
                                if (query.isEmpty) {
                                  _updateSealList(query);
                                }
                              },
                              onEditingComplete: () {
                                // Hide the keyboard and update the search list
                                FocusScope.of(context).unfocus();
                                _updateSealList(_searchController.text);
                              },
                              decoration: InputDecoration(
                                hintText: 'Search by username',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12), // Rounded corners
                                ),
                                filled: true, // Enable filled background
                                fillColor: Colors.white, // Background color
                                prefixIcon: IconButton(
                                  icon: Icon(Icons.search),
                                  onPressed: () {
                                    // Hide the keyboard and update the search list
                                    FocusScope.of(context).unfocus();
                                    _updateSealList(_searchController.text);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: _buildSealsList(snapshot.data ?? []),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSealDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUserDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Table(
        columnWidths: {
          0: FixedColumnWidth(150),
        },
        children: [
          TableRow(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Text(value),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<VendorData> _filterData(List<VendorData> data, String query) {
    // Trim white spaces from the query
    query = query.trim();

    if (query.isEmpty) {
      // If the query is empty, return the original data
      return data;
    }

    // Filter data based on the search query (case insensitive)
    return data
        .where((vendor) =>
            vendor.srNo!.toLowerCase().contains(query.toLowerCase()) ||
            vendor.name!.toLowerCase().contains(query.toLowerCase()) ||
            // vendor.vehicle_no!.toLowerCase().contains(query.toLowerCase()) ||
            // vendor.rejected_seal_no!.toLowerCase().contains(query.toLowerCase()) ||
            // vendor.new_seal_no!.toLowerCase().contains(query.toLowerCase()) ||
            // vendor.start_seal_no!.toLowerCase().contains(query.toLowerCase()) ||
            vendor.country!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Widget _buildSealsList(List<VendorData> vendorsData) {
    List<VendorData> filteredData =
        _filterData(vendorsData, _searchController.text);

    return ListView.builder(
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        VendorData vendor = filteredData[index];

        return Column(
          children: [
            Card(
              color: Colors.blueGrey[500],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Text(
                        '${vendor.srNo ?? 'N/A'}.   ${vendor.name ?? 'N/A'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => EditSeals(seal: seal),
                            //   ),
                            // );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_forever,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            // deleteVendor(vendor.Vendor_id ?? '');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Table(
                // border: TableBorder.all(color: Colors.black),
                columnWidths: {
                  0: FixedColumnWidth(150),
                },
                children: [
                  buildTableRows(
                    ['Name', 'Email'],
                    [vendor.name, vendor.email],
                    0,
                  ),

                  // buildTableRow('Location', seal.location_name,0),
                  buildTableRow('Phone', vendor.phone, 1),

                  buildTableRows(
                    ['Address', ''],
                    [vendor.addressLine1, vendor.addressLine2],
                    0,
                  ),

                  // buildTableRow('Material', seal.material_name,1),
                  // buildTableRow('Vessel', seal.vessel_name,0),

                  buildTableRows(
                    ['State', 'Country'],
                    [vendor.state, vendor.country],
                    1,
                  ),

                  buildTableRows(
                    ['Postal Code', 'GST Number'],
                    [vendor.postalCode, vendor.gstNumber.toString()],
                    0,
                  ),

                  // buildTableRows(
                  //   ['No of Seals', 'No of Extra Seals'],
                  //   [vendor.no_of_seal, vendor.extra_no_of_seal.toString()],
                  //   0,
                  // ),
                  //
                  // buildTableRows(
                  //   ['Rejected Seal', 'New Seal'],
                  //   [vendor.rejected_seal_no, vendor.new_seal_no],
                  //   1,
                  // ),
                  //
                  // buildTableRows(
                  //   ['Net weight', 'Seal Color'],
                  //   [vendor.net_weight, vendor.seal_color],
                  //   0,
                  // ),
                  //
                  // buildTableRows(
                  //   ['Vehicle No', 'Allow Slip No'],
                  //   [vendor.vehicle_no, vendor.allow_slip_no],
                  //   1,
                  // ),
                  //
                  // buildTableRow('Seal Date', vendor.seal_date,0),
                  // buildTableRow('Vehicle Reached Date', vendor.seal_unloading_date,1),

                  // buildTableRow('Net weight', seal.net_weight,0),
                  // buildTableRow('Seal Color', seal.seal_color,0),

                  // buildTableRow('Rejected Seal', seal.rejected_seal_no,0),
                  // buildTableRow('New Seal', seal.new_seal_no,0),

                  // buildTableRow('No of Seals', seal.no_of_seal,1),
                  // buildTableRow('No of Extra Seals', seal.extra_no_of_seal,1),

                  // buildTableRow('Extra Start Seal No', seal.extra_start_seal_no,0),
                  // buildTableRow('Extra End Seal No', seal.extra_end_seal_no,0),

                  // buildTableRow('Start Seal No', seal.start_seal_no,0),
                  // buildTableRow('End Seal No', seal.end_seal_no,0),

                  // buildTableRow('GPS Seal No', vendor.gps_seal_no,0),
                  // buildTableRow('Allow Slip No', seal.allow_slip_no,0),
                  // buildTableRow('Vehicle No', seal.vehicle_no,1),

                  // buildTableRow('No of Seals', seal.no_of_seal,1),

                  // buildTableRow('No of Extra Seals', seal.extra_no_of_seal,1),

                  buildTableRow('Remarks', vendor.remarks, 1),
                  buildTableRow('Contact Person', vendor.contactPerson, 0),

                  // buildTableRow('Transaction ID', seal.seal_transaction_id,1),

                  // Add more rows for other details here
                ],
              ),
            ),
            // Display a button to view images
            // ElevatedButton(
            //   onPressed: () {
            //     // Open a new screen or dialog to display the images
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => ImageViewer(imgUrls: seal.pics),
            //       ),
            //     );
            //   },
            //   child: Text('View Images'),
            // ),
          ],
        );
      },
    );
  }

  TableRow buildTableRows(
      List<String> labels, List<String?> values, int index) {
    assert(labels.length == values.length);

    return TableRow(
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : Colors.grey[200],
      ),
      children: List.generate(labels.length, (idx) {
        return TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labels[idx],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(values[idx] ?? ''),
              ],
            ),
          ),
        );
      }),
    );
  }

  TableRow buildTableRow(String label, String? value, int index) {
    return TableRow(
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : Colors.grey[200],
      ),
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(value.toString()),
          ),
        ),
      ],
    );
  }
}

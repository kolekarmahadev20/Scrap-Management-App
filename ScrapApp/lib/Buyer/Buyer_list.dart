import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';
import '../Pages/StartPage.dart';
import '../URL_CONSTANT.dart';


class Buyer_list extends StatefulWidget {

  final int currentPage;
  Buyer_list({required this.currentPage});

  @override
  _Buyer_listState createState() => _Buyer_listState();
}

class _Buyer_listState extends State<Buyer_list> {
  // List<SealData> sealsData = [];
  //
  // Future<List<SealData>> _sealDataFuture = Future<List<SealData>>.value([]);
  TextEditingController _searchController = TextEditingController();

  //Variables for user details
  bool _isloggedin = true;
  String _id = '';
  String _username = '';
  String _full_name = '';
  String _email = '';
  String userImageUrl = '';
  String _user_type = '';
  String _password = '';
  String _uuid = '';

  @override
  void initState() {
    super.initState();
    // _sealDataFuture = _getSealData();
    _getUserDetails();
  }

  //Fetching user details from sharedpreferences
  _getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isloggedin = prefs.getBool("loggedin")!;
      _id = prefs.getString('id')!;
      _username = prefs.getString('username')!;
      _full_name = prefs.getString('full_name')!;
      _email = prefs.getString('email')!;
      _user_type = prefs.getString('user_type') ?? '';
      _password = prefs.getString('password')??'';
      _uuid= prefs.getString('uuid')??'';

    });

    if (kDebugMode) {
      //print("is logged in$_isloggedin");
    }
    if (_isloggedin == false) {
      // ignore: use_build_context_synchronously
      Navigator.push(
          context, MaterialPageRoute(builder: (context) =>  StartPage()));
    }
  }

  void _updateSealList(String query) {
    setState(() {
      // Update the Future with the filtered data based on the search query
      // _sealDataFuture = _getSealData(query: query);
    });
  }


  // Future<List<SealData>> _getSealData({String? query}) async {
  //   try {
  //     // Fetch user details if not fetched already
  //     await _getUserDetails();
  //
  //     // Add the query parameter to the request body
  //     Map<String, dynamic> requestBody = {
  //       'uuid': _uuid,
  //       'user_id': _username,
  //       'password': _password,
  //       'user_type': _user_type,
  //     };
  //
  //     if (query != null && query.isNotEmpty) {
  //       requestBody['query'] = query;
  //     }
  //
  //     // Make an HTTP POST request to the API endpoint
  //     final response = await http.post(
  //       Uri.parse('$URL/Mobile_flutter_api/get_seal_data'),
  //       headers: {"Accept": "application/json"},
  //       body: requestBody,
  //     );
  //
  //     // Check if the response status code is 200 (OK)
  //     if (response.statusCode == 200) {
  //       // Parse the response body as JSON
  //       final data = json.decode(response.body);
  //
  //       // Check if the API response indicates success and contains seal data
  //       if (data["status"] == "1" && data["seal_data"] != null) {
  //         // Create a list to store the fetched seal data
  //         List<SealData> fetchedSealsData = [];
  //
  //         // Iterate through each seal in the response data
  //         for (var seal in data["seal_data"] ?? []) {
  //           // Initialize a new SealData object based on the response data
  //           SealData sealData = SealData(
  //             sr_no: seal["sr_no"]?.toString() ?? "",
  //             location_name: seal["location_name"] ?? "",
  //             seal_transaction_id: seal["seal_transaction_id"] ?? "",
  //             seal_date: seal["seal_date"] ?? "",
  //             seal_unloading_date: seal["seal_unloading_date"] ?? "",
  //             seal_unloading_time: seal["seal_unloading_time"] ?? "",
  //             vehicle_no: seal["vehicle_no"] ?? "",
  //             allow_slip_no: seal["allow_slip_no"] ?? "",
  //             plant_name: seal["plant_name"] ?? "",
  //             material_name: seal["material_name"] ?? "",
  //             vessel_name: seal["vessel_name"] ?? "",
  //             net_weight: seal["net_weight"] ?? "",
  //             start_seal_no: seal["start_seal_no"] ?? "",
  //             end_seal_no: seal["end_seal_no"] ?? "",
  //             seal_color: seal["seal_color"] ?? "",
  //             no_of_seal: seal["no_of_seal"] ?? "",
  //             gps_seal_no: seal["gps_seal_no"] ?? "",
  //             extra_start_seal_no: seal["extra_start_seal_no"] ?? "",
  //             extra_no_of_seal: seal["extra_no_of_seal"] ?? "",
  //             rejected_seal_no: seal["rejected_seal_no"] ?? "",
  //             new_seal_no: seal["new_seal_no"] ?? "",
  //             remarks: seal["remarks"] ?? "",
  //             rev_remarks: seal["rev_remarks"] ?? "",
  //             img_cnt: seal["img_cnt"] ?? "",
  //             extra_end_seal_no: seal["extra_end_seal_no"] ?? "",
  //             first_weight: seal["first_weight"] ?? "",
  //             second_weight: seal["second_weight"] ?? "",
  //             tarpaulin_condition: seal["tarpaulin_condition"] ?? "",
  //             sender_remarks: seal["sender_remarks"] ?? "",
  //             pics: List<String>.from(seal["pics"] ?? []),
  //           );
  //
  //
  //           // Add the SealData object to the list
  //           fetchedSealsData.add(sealData);
  //         }
  //
  //
  //         setState(() {
  //           sealsData = List.from(fetchedSealsData);
  //         });
  //
  //
  //         // Return the fetched seal data
  //         return fetchedSealsData;
  //       }
  //     }
  //   } catch (e) {
  //     // Print and rethrow the error to be handled by FutureBuilder
  //     print('Error: $e');
  //     throw e;
  //   }
  //
  //   // Return an empty list if data fetching fails
  //   return [];
  // }


  // Add this function in your _ViewSealState class
  Future<void> deleteSealRecord(String seal_transaction_id) async {
    try {
      print(seal_transaction_id);
      final response = await http.post(
        Uri.parse('$URL/Mobile_flutter_api/delete_seal_record'),
        headers: {"Accept": "application/json"},
        body: {
          'uuid': _uuid,
          'user_id': _username,
          'password': _password,
          'id': seal_transaction_id,
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
          print('Failed to delete seal record: ${data["message"]}');
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
            //   MaterialPageRoute(builder: (context) => AddSealData()),
            // );
          },
          child: Icon(Icons.add),
        ),
        // body: RefreshIndicator(
        //   onRefresh: () async {
        //     await _refreshData();
        //   },
        //   child: FutureBuilder<List<SealData>>(
        //     future: _sealDataFuture,
        //     builder: (context, snapshot) {
        //       if (snapshot.connectionState == ConnectionState.waiting) {
        //         return Center(child: CircularProgressIndicator());
        //       } else if (snapshot.hasError) {
        //         return Center(child: Text('Error: ${snapshot.error}'));
        //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        //         return Center(child: Text('No data available'));
        //       } else {
        //         return Column(
        //           crossAxisAlignment: CrossAxisAlignment.stretch,
        //           children: [
        //             // Display the "View Seals" card at the top
        //             Center(
        //               child: Card(
        //                 child: Column(
        //                   children: [
        //                     Row(
        //                       mainAxisAlignment: MainAxisAlignment.center,
        //                       children: [
        //                         Icon(
        //                           Icons.circle_notifications,
        //                           color: Colors.blue.shade900,
        //                           size: 35,
        //                         ),
        //                         SizedBox(width: 10),
        //                         Text(
        //                           'View Seals',
        //                           style: TextStyle(
        //                             fontSize: 20,
        //                             fontWeight: FontWeight.bold,
        //                             color: Colors.blue.shade900,
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                     Padding(
        //                       padding: const EdgeInsets.all(8.0),
        //                       child: Row(
        //                         mainAxisAlignment: MainAxisAlignment.center,
        //                         children: [
        //                           Expanded(
        //                             child: TextField(
        //                               controller: _searchController,
        //                               onChanged: (query) {
        //                                 if (query.isEmpty) {
        //                                   _updateSealList(query);
        //                                 }
        //                               },
        //                               onEditingComplete: () {
        //                                 _updateSealList(_searchController.text);
        //                               },
        //                               decoration: InputDecoration(
        //                                 hintText: 'Search by username',
        //                                 suffixIcon: IconButton(
        //                                   icon: Icon(Icons.search),
        //                                   onPressed: () {
        //                                     _updateSealList(_searchController.text);
        //                                   },
        //                                 ),
        //                               ),
        //                             ),
        //                           ),
        //                         ],
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //             ),
        //             Expanded(
        //               child: _buildSealsList(snapshot.data ?? []),
        //             ),
        //           ],
        //         );
        //       }
        //     },
        //   ),
        // ),
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

  // List<SealData> _filterData(List<SealData> data, String query) {
  //   // Trim white spaces from the query
  //   query = query.trim();
  //
  //   if (query.isEmpty) {
  //     // If the query is empty, return the original data
  //     return data;
  //   }
  //
  //   // Filter data based on the search query (case insensitive)
  //   return data.where((seal) =>
  //   seal.sr_no!.toLowerCase().contains(query.toLowerCase()) ||
  //       seal.seal_transaction_id!.toLowerCase().contains(query.toLowerCase()) ||
  //       seal.vehicle_no!.toLowerCase().contains(query.toLowerCase()) ||
  //       seal.rejected_seal_no!.toLowerCase().contains(query.toLowerCase()) ||
  //       seal.new_seal_no!.toLowerCase().contains(query.toLowerCase()) ||
  //       seal.start_seal_no!.toLowerCase().contains(query.toLowerCase()) ||
  //       seal.end_seal_no!.toLowerCase().contains(query.toLowerCase())
  //   ).toList();
  // }


  // Widget _buildSealsList(List<SealData> sealsData) {
  //   List<SealData> filteredData = _filterData(sealsData, _searchController.text);
  //
  //   return ListView.builder(
  //     itemCount: filteredData.length,
  //     itemBuilder: (context, index) {
  //       SealData seal = filteredData[index];
  //
  //       return Column(
  //         children: [
  //           Card(
  //             color: Colors.grey.shade200,
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: Text(
  //                     '${seal.sr_no ?? 'N/A'}',
  //                     style: TextStyle(
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 17,
  //                       color: Colors.blue,
  //                     ),
  //                   ),
  //                 ),
  //                 Expanded(
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.end,
  //                     children: [
  //                       IconButton(
  //                         icon: Icon(Icons.edit),
  //                         onPressed: () {
  //                           Navigator.push(
  //                             context,
  //                             // MaterialPageRoute(
  //                             //   builder: (context) => EditSeals(seal: seal),
  //                             // ),
  //                           );
  //                         },
  //                       ),
  //                       IconButton(
  //                         icon: Icon(Icons.delete, color: Colors.red),
  //                         onPressed: () {
  //                           deleteSealRecord(seal.seal_transaction_id ?? '');
  //                         },
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Card(
  //             elevation: 5.0,
  //             margin: EdgeInsets.all(16.0),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(15.0),
  //             ),
  //             child: Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: Table(
  //                 // border: TableBorder.all(color: Colors.black),
  //                 columnWidths: {
  //                   0: FixedColumnWidth(150),
  //                 },
  //                 children: [
  //                   buildTableRows(
  //                     ['Location', 'Plant'],
  //                     [seal.location_name, seal.plant_name],
  //                     0,
  //                   ),
  //
  //                   // buildTableRow('Location', seal.location_name,0),
  //                   // buildTableRow('Plant', seal.plant_name,1),
  //
  //                   buildTableRows(
  //                     ['Material', 'Vessel'],
  //                     [seal.material_name, seal.vessel_name],
  //                     1,
  //                   ),
  //
  //                   // buildTableRow('Material', seal.material_name,1),
  //                   // buildTableRow('Vessel', seal.vessel_name,0),
  //
  //                   buildTableRows(
  //                     ['Start Seal No', 'End Seal No'],
  //                     [seal.start_seal_no, seal.end_seal_no],
  //                     0,
  //                   ),
  //
  //                   buildTableRows(
  //                     ['Extra Start Seal No', 'Extra End Seal No'],
  //                     [seal.extra_start_seal_no, seal.extra_end_seal_no.toString()],
  //                     1,
  //                   ),
  //
  //                   buildTableRows(
  //                     ['No of Seals', 'No of Extra Seals'],
  //                     [seal.no_of_seal, seal.extra_no_of_seal.toString()],
  //                     0,
  //                   ),
  //
  //                   buildTableRows(
  //                     ['Rejected Seal', 'New Seal'],
  //                     [seal.rejected_seal_no, seal.new_seal_no],
  //                     1,
  //                   ),
  //
  //                   buildTableRows(
  //                     ['Net weight', 'Seal Color'],
  //                     [seal.net_weight, seal.seal_color],
  //                     0,
  //                   ),
  //
  //                   buildTableRows(
  //                     ['Vehicle No', 'Allow Slip No'],
  //                     [seal.vehicle_no, seal.allow_slip_no],
  //                     1,
  //                   ),
  //
  //                   buildTableRow('Seal Date', seal.seal_date,0),
  //                   buildTableRow('Vehicle Reached Date', seal.seal_unloading_date,1),
  //
  //                   // buildTableRow('Net weight', seal.net_weight,0),
  //                   // buildTableRow('Seal Color', seal.seal_color,0),
  //
  //                   // buildTableRow('Rejected Seal', seal.rejected_seal_no,0),
  //                   // buildTableRow('New Seal', seal.new_seal_no,0),
  //
  //                   // buildTableRow('No of Seals', seal.no_of_seal,1),
  //                   // buildTableRow('No of Extra Seals', seal.extra_no_of_seal,1),
  //
  //                   // buildTableRow('Extra Start Seal No', seal.extra_start_seal_no,0),
  //                   // buildTableRow('Extra End Seal No', seal.extra_end_seal_no,0),
  //
  //                   // buildTableRow('Start Seal No', seal.start_seal_no,0),
  //                   // buildTableRow('End Seal No', seal.end_seal_no,0),
  //
  //                   buildTableRow('GPS Seal No', seal.gps_seal_no,0),
  //                   // buildTableRow('Allow Slip No', seal.allow_slip_no,0),
  //                   // buildTableRow('Vehicle No', seal.vehicle_no,1),
  //
  //
  //
  //                   // buildTableRow('No of Seals', seal.no_of_seal,1),
  //
  //                   // buildTableRow('No of Extra Seals', seal.extra_no_of_seal,1),
  //
  //
  //
  //
  //
  //                   buildTableRow('Sender Remarks', seal.remarks,1),
  //                   buildTableRow('Receiver Remarks', seal.rev_remarks,0),
  //
  //                   // buildTableRow('Transaction ID', seal.seal_transaction_id,1),
  //
  //
  //                   // Add more rows for other details here
  //
  //
  //
  //
  //                 ],
  //               ),
  //             ),
  //           ),
  //           // Display a button to view images
  //           ElevatedButton(
  //             onPressed: () {
  //               // Open a new screen or dialog to display the images
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => ImageViewer(imgUrls: seal.pics),
  //                 ),
  //               );
  //             },
  //             child: Text('View Images'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  TableRow buildTableRows(List<String> labels, List<String?> values, int index) {
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

  TableRow buildTableRow(String label, String? value,int index) {
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

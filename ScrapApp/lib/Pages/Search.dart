import 'package:flutter/material.dart';
import 'package:scrapapp/URL_CONSTANT.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class Search extends StatefulWidget {

  final int currentPage;
  Search({required this.currentPage});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {

  //Variables for user details
  String? username = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';


  final _vehicleNoFocusNode = FocusNode();

  //Variables for user selected values
  String? selectedLocation;
  String? selectedPlantName;
  String? selectedMaterial;
  String? selectedName;
  String? vehicleNumber;
  DateTime? fromDate;
  DateTime? toDate;

  // List to store location names,plant names & material name
  List<String> locations = [];
  List<String> plants = [];
  List<String> materials = [];

  // List to store plant_id,location_id & material_id
  List<String> locationIds = [];
  List<String> plantIds = [];
  List<String> materialIds = [];
  // List<SealData> sealsData = [];

  @override
  void initState() {
    super.initState();
    checkLogin();
    fetchdropdownData();
  }


  @override
  void dispose() {
    super.dispose();
  }


  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
  }

  fetchdropdownData() async {
    await checkLogin();
    try {
      final response = await http.post(
        Uri.parse('$URL/Mobile_flutter_api/get_dropdown_data'),
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'user_pass': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["status"] == "1") {
          updateData(data, "location", locations, locationIds);
          updateData(data, "plant", plants, plantIds);
          updateData(data, "material", materials, materialIds);

          setState(() {
            selectedLocation;
            selectedPlantName;
            selectedMaterial;
          });
        }
        else {
          print('Status is not 1 in the response');
        }
      } else {
        print('Failed to fetch Dropdown API. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void updateData(Map<String, dynamic> data, String key, List<String> itemList, List<String> itemIdList) {
    itemList.clear();
    itemIdList.clear();

    if (data.containsKey(key)) {
      for (var itemData in data[key]) {
        String itemName = itemData["${key}_name"].toString();
        String itemId = itemData["${key}_id"].toString();

        itemList.add(itemName);
        itemIdList.add(itemId);
      }
    } else {
      print('No "$key" data found in the response');
    }
  }

  String? getSelectedId(String? selectedItem, List<String> itemList, List<String> itemIdList) {
    if (selectedItem != null) {
      int selectedIndex = itemList.indexOf(selectedItem);
      return (selectedIndex != -1 && selectedIndex < itemIdList.length) ? itemIdList[selectedIndex] : null;
    }
    return null;
  }

  // Define functions to get the plant_id, location_id, and material_id for the selected names
  String? getSelectedPlantId() => getSelectedId(selectedPlantName, plants, plantIds);
  String? getSelectedLocationId() => getSelectedId(selectedLocation, locations, locationIds);
  String? getSelectedMaterialId() => getSelectedId(selectedMaterial, materials, materialIds);


  //Fetching API for Search Seal Data
  // Future<void> fetch_search_seal_data({String? plantId, String? locationId,String? materialId, String? vehicleNumber })
  // async {
  //   try {
  //     await _getUserDetails();
  //     final response = await http.post(
  //       Uri.parse('$API_URL/Mobile_flutter_api/search_seal_data'),
  //       headers: {"Accept": "application/json"},
  //       body: {
  //         'uuid': _uuid,
  //         'user_id': _username,
  //         'password': _password,
  //         'plant_id': plantId,
  //         'from_date':fromDate != null ? fromDate?.toLocal().toString() : '',
  //         // '2019-08-18',
  //         'material_id': materialId,
  //         'location_id':locationId,
  //         'vehicle_no': vehicleNumber,
  //         // 'RJ27GD5098',
  //         'to_date': toDate != null ? toDate?.toLocal().toString() : '',
  //         // '2019-08-18',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //
  //       final data = json.decode(response.body);
  //
  //       if (data["status"] == "1" && data["seal_data"] != null)
  //       {
  //         List<SealData> fetchedUsersData = [];
  //
  //         for (var seal in data["seal_data"]) {
  //           SealData sealData = SealData(
  //             sr_no: seal["sr_no"].toString(),
  //             location_name: seal["location_name"],
  //             seal_transaction_id: seal["seal_transaction_id"],
  //             seal_date: seal["seal_date"],
  //             seal_unloading_date: seal["seal_unloading_date"],
  //             seal_unloading_time: seal["seal_unloading_time"],
  //             vehicle_no: seal["vehicle_no"],
  //             allow_slip_no: seal["allow_slip_no"],
  //             plant_name: seal["plant_name"],
  //             material_name: seal["material_name"],
  //             vessel_name: seal["vessel_name"],
  //             net_weight: seal["net_weight"],
  //             start_seal_no: seal["start_seal_no"],
  //             end_seal_no: seal["end_seal_no"],
  //             seal_color: seal["seal_color"],
  //             no_of_seal: seal["no_of_seal"],
  //             gps_seal_no: seal["gps_seal_no"],
  //             extra_start_seal_no: seal["extra_start_seal_no"],
  //             extra_no_of_seal: seal["extra_no_of_seal"],
  //             rejected_seal_no: seal["rejected_seal_no"],
  //             new_seal_no: seal["new_seal_no"],
  //             remarks: seal["remarks"],
  //             rev_remarks: seal["rev_remarks"],
  //             img_cnt: seal["img_cnt"],
  //             extra_end_seal_no:seal["extra_end_seal_no"],
  //             first_weight:seal["first_weight"],
  //             second_weight: seal["second_weight"],
  //             tarpaulin_condition:seal["tarpaulin_condition"],
  //             sender_remarks: seal["sender_remarks"],
  //             pics: List<String>.from(seal["pics"]),
  //           );
  //
  //           fetchedUsersData.add(sealData);
  //         }
  //
  //         setState(() {
  //           sealsData = fetchedUsersData;
  //         });
  //
  //       }
  //
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }


  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        drawer: AppDrawer(currentPage: 0),
        appBar: CustomAppBar(),
        // body: SingleChildScrollView(
        //     child: Padding(
        //         padding: EdgeInsets.all(screenWidth * 0.02),
        //         child: Center(
        //
        //             child: Column(
        //               crossAxisAlignment: CrossAxisAlignment.center,
        //               children: [
        //                 SizedBox(height: 10,),
        //                 Row(
        //                   mainAxisAlignment: MainAxisAlignment.center,
        //                   children: [
        //                     Icon(
        //                       Icons.search,
        //                       color: Colors.blue.shade900,
        //                       size: 20,
        //                     ),
        //                     SizedBox(width: screenWidth * 0.02),
        //                     Text(
        //                       'Search Seals',
        //                       style: TextStyle(
        //                         fontSize: 20,
        //                         fontWeight: FontWeight.bold,
        //                         color: Colors.blue.shade900,
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //                 SizedBox(height: 10,),
        //                 Card(
        //                   elevation: 4.0,
        //                   shape: RoundedRectangleBorder(
        //                     borderRadius: BorderRadius.circular(screenWidth * 0.02),
        //                   ),
        //                   child: Padding(
        //                     padding: EdgeInsets.all(screenWidth * 0.02),
        //                     child: Column(
        //                       crossAxisAlignment: CrossAxisAlignment.start,
        //                       children: [
        //                         const SizedBox(height: 13),
        //                         buildDropdown(" All Location", "Location", locations,
        //                           selectedLocation,
        //                               (value) {
        //                             setState(() {
        //                               selectedLocation = value;
        //                             });
        //                           },
        //                         ),
        //                         const SizedBox(height: 13),
        //                         buildDropdown(" Select Plant", "Plant Name", plants,
        //                           selectedPlantName,
        //                               (value) {
        //                             setState(() {
        //                               selectedPlantName = value;
        //                             });
        //                           },
        //                         ),
        //                         const SizedBox(height: 13),
        //                         buildDropdown(" Select Material", "Material", materials,
        //                           selectedMaterial,
        //                               (value) {
        //                             setState(() {
        //                               selectedMaterial = value;
        //                             });
        //                           },
        //                         ),
        //                         const SizedBox(height: 13),
        //                         buildFieldWithDatePicker('From Date',
        //                           fromDate,
        //                               (selectedDate) {
        //                             setState(() {
        //                               fromDate = selectedDate;
        //                             });
        //                           },
        //                         ),
        //                         const SizedBox(height: 13),
        //                         buildFieldWithDatePicker('To Date',
        //                           toDate,
        //                               (selectedEndDate) {
        //                             setState(() {
        //                               toDate = selectedEndDate;
        //                             });
        //                           },
        //                         ),
        //                         const SizedBox(height: 13),
        //                         buildTextField("Vehicle No",
        //                           vehicleNumber,
        //                               (value) {
        //                             setState(() {
        //                               vehicleNumber = value;
        //                             });
        //                           },
        //                         ),
        //                         const SizedBox(height: 20),
        //                         Center(
        //                           child: ElevatedButton(
        //                             onPressed: () {
        //                               fetch_search_seal_data(
        //                                 plantId: getSelectedPlantId(),
        //                                 locationId: getSelectedLocationId(),
        //                                 materialId: getSelectedMaterialId(),
        //                                 vehicleNumber: vehicleNumber,
        //                               );
        //                             },
        //                             child: Text('Get Data'),
        //                           ),
        //                         ),
        //
        //                         // Inside your build method, update the part where you display the search results
        //                         if(sealsData.isNotEmpty)
        //                           const SizedBox(width: 16.0),
        //                         Column(
        //                           children: sealsData.map((seal) =>
        //                               Column(
        //                                 children: [
        //                                   Column(
        //                                     children: [
        //                                       Card(
        //                                         color: Colors.grey.shade200,
        //                                         child: Row(
        //                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                                           children: [
        //                                             Padding(
        //                                               padding: const EdgeInsets.all(8.0),
        //                                               child: Text(
        //                                                 '${seal.sr_no?? 'N/A'}',
        //                                                 style: TextStyle(
        //                                                   fontWeight: FontWeight.bold,
        //                                                   fontSize: 19,
        //                                                   color: Colors.blue,
        //                                                 ),
        //                                               ),
        //                                             ),
        //                                           ],
        //                                         ),
        //                                       ),
        //                                       buildUserDataRow('Location ', seal.location_name ?? 'N/A'),
        //                                       // buildUserDataRow('Seal Transaction_id', seal.seal_transaction_id ?? 'N/A'),
        //                                       buildUserDataRow('Seal Date', seal.seal_date ?? 'N/A'),
        //                                       buildUserDataRow('Seal Unloading_date', seal.seal_unloading_date ?? 'N/A'),
        //                                       buildUserDataRow('Seal Unloading_time', seal.seal_unloading_time ?? 'N/A'),
        //                                       buildUserDataRow('Vehicle No', seal.vehicle_no ?? 'N/A'),
        //                                       // buildUserDataRow('Allow Slip No', seal.allow_slip_no ?? 'N/A'),
        //                                       buildUserDataRow('Plant Name', seal.plant_name ?? 'N/A'),
        //                                       buildUserDataRow('Material', seal.material_name ?? 'N/A'),
        //                                       buildUserDataRow('Vessel', seal.vessel_name ?? 'N/A'),
        //                                       buildUserDataRow('Net Weight',seal.net_weight ?? 'N/A'),
        //                                       buildUserDataRow('Start Seal No', seal.start_seal_no ?? 'N/A'),
        //                                       buildUserDataRow('End Seal No', seal.end_seal_no ?? 'N/A'),
        //                                       buildUserDataRow('Seal Color', seal.seal_color ?? 'N/A'),
        //                                       buildUserDataRow('No of Seals', seal.no_of_seal ?? 'N/A'),
        //                                       buildUserDataRow('GPS Seal No', seal.gps_seal_no ?? 'N/A'),
        //                                       buildUserDataRow('Extra Start Seal No', seal.extra_start_seal_no ?? 'N/A'),
        //                                       buildUserDataRow('Extra End Seal No', seal.extra_end_seal_no ?? 'N/A'),
        //                                       buildUserDataRow('No of Extra Seals', (seal.extra_no_of_seal ?? 0).toString()),
        //                                       buildUserDataRow('Rejected Seal no', seal.rejected_seal_no ?? 'N/A'),
        //                                       buildUserDataRow('New Seal no', seal.new_seal_no ?? 'N/A'),
        //                                       // buildUserDataRow('Sender Remarks', seal.remarks ?? 'N/A'),
        //                                       buildUserDataRow('Receiver Remarks', seal.rev_remarks ?? 'N/A'),
        //                                       Row(
        //                                         children: [
        //                                           Text("View Image", style: TextStyle(fontWeight: FontWeight.bold)),
        //                                           SizedBox(width: 10),
        //                                           ElevatedButton(
        //                                             onPressed: () {
        //                                               Navigator.push(
        //                                                 context,
        //                                                 MaterialPageRoute(
        //                                                   builder: (context) => ImageViewer(imgUrls: seal.pics),
        //                                                 ),
        //                                               );
        //                                             },
        //                                             child: Text("Click to view Image"),
        //                                           ),
        //                                         ],
        //                                       ),
        //                                       const SizedBox(height: 20),
        //                                     ],
        //                                   ),
        //                                 ],
        //                               )).toList(),
        //                         ),
        //                       ],
        //                     ),
        //                   ),
        //                 ),
        //               ],
        //             )
        //         )
        //     )
        // )
    );
  }


  void showImageDialog(String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Image'),
                const SizedBox(width: 16.0),
                (imagePath != '0')
                    ? Image.network(
                  imagePath,
                  width: 200.0, // Adjust the width as needed
                  height: 200.0, // Adjust the height as needed
                )
                    : Text('No Image'),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildUserDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Table(
        columnWidths: {
          0: FixedColumnWidth(126),
        },
        children: [
          TableRow(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.grey.shade300,
                    ),
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
                child: value == 'N/A'
                    ? Text(value)
                    : (label == 'Image')
                    ? Container(
                  width: 100, // Adjust the width as needed
                  child: ElevatedButton(
                    onPressed: () {
                      showImageDialog(value);
                    },
                    child: Text('View Image'),
                  ),
                )
                    : Text(value),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget buildDropdown(String hint, String labelText, List<String> items, String? selectedItem,
      void Function(String?) onChanged,
      ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            labelText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Container(
            height: 30,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border.all(
                color: Colors.grey.shade600,
                width: 1.0,
              ),
            ),
            child: Center(
              child: DropdownButtonFormField<String>(
                value: selectedItem,
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: SizedBox(
                      height: 40,
                      child: Center(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
                isExpanded: true,
                decoration: InputDecoration.collapsed(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.black),
                ),
                selectedItemBuilder: (BuildContext context) {
                  return items.map<Widget>((String item) {
                    return Center(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList();
                },
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget buildFieldWithDatePicker(String label, DateTime? selectedDate,
      void Function(DateTime?) onDateChanged,) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 15.0),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final newSelectedDate = await showDatePicker(
                      context: context, // Make sure you have access to the context
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (newSelectedDate != null) {
                      onDateChanged(newSelectedDate);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedDate != null
                              ? '${selectedDate.toLocal()}'.split(' ')[0]
                              : 'Select Date',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          size: 19.0, // Adjust the size as needed
                        ), // Calendar icon
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget buildTextField(String labelText, String? text,
      void Function(String?) onChanged,
      ) {
    return Row(
      children: [
        Icon(
          Icons.directions_car,
          color: Colors.blue.shade900,
          size: 22.0,
        ),
        SizedBox(width: 1.0),
        Expanded(
          child: Text(
            labelText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            height: 35.0,
            child: TextFormField(
              onChanged: onChanged,
              autofocus: false, // Disable autofocus
              decoration: InputDecoration(
                hintText: ' Enter Vehicle No',
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 9.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0.0)),
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0.0)),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400, // Light grey color
                  ),
                ),
              ),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
            ),
          ),
        ),
      ],
    );
  }



}


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';
import 'package:flutter/services.dart';

import '../URL_CONSTANT.dart';
import 'StartPage.dart';

class EmployeeTrackers extends StatefulWidget {

  final int currentPage;
  EmployeeTrackers({required this.currentPage});

  @override
  State<EmployeeTrackers> createState() => EmployeeTrackersState();
}

class EmployeeTrackersState extends State<EmployeeTrackers> {
  late GoogleMapController mapController;

  LatLng _center = const LatLng(19.0829358, 73.000453); // Default center
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // Variables for user input
  String selectedEmployeeId = '';
  DateTime selectedDate = DateTime.now();
  List<Map<String, String>> employees = []; // List to store dropdown data

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
    _fetchDropdownData();

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

    if (_isloggedin == false) {
      // ignore: use_build_context_synchronously
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => StartPage()));
    }
  }

  Future<void> _fetchDropdownData() async {
    await _getUserDetails();
    final url = '$URL/Mobile_flutter_api/get_dropdown_data';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'uuid': _uuid,
        'user_id': _username,
        'password': _password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == '1') {
        setState(() {
          employees = List<Map<String, String>>.from(data['allusers'].map((x) => {
            'id': x['id'] as String,
            'full_name': x['full_name'] as String,
            'username': x['username'] as String,
          }));
        });
      } else {
        throw Exception('Failed to load dropdown data');
      }
    } else {
      throw Exception('Failed to load dropdown data');
    }
  }

  Future<void> _fetchUserData() async {
    await _getUserDetails();

    if (selectedEmployeeId.isEmpty) {
      // If no employee is selected, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an employee.')),
      );
      return;
    }

    final url = '$URL/Mobile_flutter_api/get_user_lat_long';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'uuid': _uuid,
        'user_id': _username,
        'password': _password,
        'date': selectedDate.toIso8601String().split('T')[0],
        'id': selectedEmployeeId,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == '1') {
        final userData = data['user_data'];
        final List<LatLng> latLngList = [];
        _markers.clear();
        _polylines.clear();

        for (var item in userData) {
          final lat = double.parse(item['lat']);
          final lon = double.parse(item['lon']);
          final latLng = LatLng(lat, lon);

          latLngList.add(latLng);

          _markers.add(
            Marker(
              markerId: MarkerId(latLng.toString()),
              position: latLng,
              infoWindow: InfoWindow(
                title: item['full_name'],
                snippet: item['dt'],
              ),
              icon: BitmapDescriptor.defaultMarker,
            ),
          );
        }

        // Update the camera position to the first LatLng in the list
        if (latLngList.isNotEmpty) {
          _center = latLngList.first;
        }

        setState(() {
          _polylines.add(
            Polyline(
              polylineId: PolylineId('polyline'),
              visible: true,
              points: latLngList,
              color: Colors.blue,
              width: 4,
            ),
          );
        });

        // Move the camera to the new position
        mapController.animateCamera(
          CameraUpdate.newLatLng(_center),
        );
      } else {
        // If status is not '1', show an alert indicating no data found
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('No Data Found'),
              content: Text('No tracking data found for the selected employee on the selected date.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      throw Exception('Failed to load user data');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentPage: widget.currentPage),
      appBar: CustomAppBar(),
      body: Column(
        children: [

          SizedBox(height: 20,),
          buildDropdown(
            "Employee Name:",
            selectedEmployeeId,
                (value) {
              setState(() {
                selectedEmployeeId = value!;
              });
            },
            employees, // Pass the list of employees here
          ),
          SizedBox(height: 8.0),
          // Date picker
          buildFieldWithDatePicker(
            'Date:',
            selectedDate,
                (DateTime selectedDate) {
              setState(() {
                this.selectedDate = selectedDate;
              });
            },
          ),
          SizedBox(height: 16.0),
          // Get Data button
          ElevatedButton(
            onPressed: _fetchUserData,
            child: Text('Get Data'),
          ),
          SizedBox(height: 16.0),
          // Google Map
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              markers: _markers,
              polylines: _polylines,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDropdown(String label, String? value, void Function(String?)? onChanged, List<Map<String, String>> employees) {
    // Prepare dropdown items
    List<DropdownMenuItem<String>> dropdownItems = [
      DropdownMenuItem(
        value: '', // Use an empty string as the default value
        child: Text('Select username'), // Displayed text for the default item
      ),
      ...employees.map((employee) {
        return DropdownMenuItem<String>(
          value: employee['id']!,
          child: Text('${employee['full_name']} - (${employee['username']})'),
        );
      }).toList(),
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          SizedBox(width: 8.0),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200], // Background color of dropdown field
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: DropdownButton<String>(
                  isExpanded: true, // Ensures the dropdown button expands to fill its container
                  hint: Text('Select an employee'), // Hint text
                  value: value!.isEmpty ? null : value, // Ensure value is null for default
                  onChanged: onChanged,
                  items: dropdownItems,
                  underline: Container(), // Removes the default underline
                  style: TextStyle(fontSize: 16.0, color: Colors.black87),
                  icon: Icon(Icons.arrow_drop_down),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFieldWithDatePicker(String label, DateTime selectedDate, Function(DateTime) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label),
        SizedBox(width: 8.0),
        TextButton(
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (picked != null && picked != selectedDate) {
              onChanged(picked);
            }
          },
          child: Text(
            "${selectedDate.toLocal()}".split(' ')[0],
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }
}

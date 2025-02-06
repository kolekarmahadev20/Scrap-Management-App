import 'dart:convert'; // Import this for JSON decoding
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../AppClass/appBar.dart';
import '../DashBoard/DashBoard.dart';
import '../URL_CONSTANT.dart';

// OrganizationList widget displays a list of organizations along with financial years.
class OrganizationList extends StatefulWidget {
  @override
  State<OrganizationList> createState() => _OrganizationListState();
}

class _OrganizationListState extends State<OrganizationList> {
  String? username = '';
 String uuid = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';

  bool _isLoading = true;
  List<Map<String, dynamic>> _organization = [];
  List<Map<String, dynamic>> _finYears = [];
  Map<int, int?> _selectedFinYearForOrg = {};

  @override
  void initState() {
    super.initState();
    checkLogin();
    _fetchorganizationData();
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

  // State variables
  String? selectedFYId = '0'; // Default value for "All Location"
  Map<String, String> FyMap = {};

  Future<void> _fetchorganizationData() async {
    setState(() {
      _isLoading = true;
    });
    await checkLogin();
    try {
      final apiUrl = '${URL}oorganizationlist';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Accept": "application/json"},
        body: {'user_id': username, 'user_pass': password,  'uuid':uuid},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print(data);
        print("data");

        setState(() {
          _organization =
              List<Map<String, dynamic>>.from(data['user_data'] ?? []);
          _finYears = List<Map<String, dynamic>>.from(data['fin_yrs'] ?? []);

          FyMap = {}; // Initialize an empty map
          if (_finYears.isNotEmpty) {
            // Set the default selected FYId to the first item in the list
            String finYrCode = _finYears[0]['fin_yr_code'] ?? '';
            String startDate = _finYears[0]['s_date'] ?? '';
            String endDate = _finYears[0]['e_date'] ?? '';
            String displayText = '$finYrCode [$startDate - $endDate]';
            selectedFYId = _finYears[0]['fin_yr_id']; // Default value to the first item's ID
            FyMap[displayText] = selectedFYId!;

            // Populate the map for the remaining financial years
            for (var location in _finYears.skip(1)) {
              String finYrCode = location['fin_yr_code'] ?? '';
              String startDate = location['s_date'] ?? '';
              String endDate = location['e_date'] ?? '';
              String displayText = '$finYrCode [$startDate - $endDate]';
              FyMap[displayText] = location['fin_yr_id'];
            }
          }
        });
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to fetch data. Please try again later.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget buildDropdown(String label, Map<String, String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 15,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: selectedFYId, // Set the default value
              items: options.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.value, // Return ID
                  child: Text(entry.key), // Display formatted text (fin_yr_code[e_date - s_date])
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _checkOrganizationDetails(String orgId) async {
    try {
      final url = '${URL}check_org';
      final response = await http.post(
        Uri.parse(url),
        body: {
        'user_id': username,
'uuid':uuid,
          'user_pass': password,
          'fin_yr': selectedFYId, // Pass as String if needed by API
          'org_id': orgId.toString(),
        },
      );

      if (response.statusCode == 200) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashBoard(currentPage: 1)),
        );

      } else {
        print("Error: Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      // drawer: AppDrawer(currentPage: 0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Organization",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _organization.isEmpty
                    ? const Center(
                        child: Text(
                          'No Data Found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(10),
                        itemCount: _organization.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey.shade200,
                        ),
                        itemBuilder: (context, index) {
                          final org = _organization[index];
                          final orgId = org['org_id'] ?? 0;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(10),
                                title: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        org['OrgName'] ??
                                            'Unknown Organization',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      org['OrgAddress'] ??
                                          'Address not available',
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                    const SizedBox(height: 5),
                                    Text('Type: ${org['org_type']}',
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                    const SizedBox(height: 5),
                                    buildDropdown(
                                      "FY:",
                                      FyMap,
                                          (value) {
                                        setState(() {
                                          selectedFYId = value;
                                          print("Selected Financial Year ID: $selectedFYId");
                                        });
                                      },
                                    ),

                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 14),
                                onTap: () {
                                  int selectedFinYearIdInt = _selectedFinYearForOrg[orgId] ?? 0;

                                  print(selectedFYId);
                                  print(orgId);

                                  // Call the method with the correct data type
                                  _checkOrganizationDetails(orgId as String);
                                },

                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

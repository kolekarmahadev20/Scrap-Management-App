import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:scrapapp/Leave/Leave_Application.dart';
import 'package:scrapapp/Pages/StartPage.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';
import '../URL_CONSTANT.dart';
import 'Add_user.dart';
import 'Edit_User.dart';


// User model to parse JSON data
class User {
  final String personId;
  final String empCode;
  final String personName;
  final String username;
  final String fatherName;
  final String motherName;
  final String dob;
  final String doj;
  final String village;
  final String district;
  final String state;
  final String pincode;
  final String address;
  final String familyPhone;
  final String adharNum;
  final String empEmail;
  final String empComStatus;
  final String? userType;
  final String? cPass;
  final String isActive;
  final String? uuid;
  final String? orgId;
  final String isDuplicate;
  final String duplicateEmpId;
  final String termAccept;
  final String terminationStatus;
  final String dateUpdated;
  final String updatedBy;
  final String copyUserEmployee;
  final String contactDetails;
  final String? approveStatus;
  final String? aprovePerson;
  final String? isMobile;
  final String? accesSaleOrder;
  final String? accesDispatch;
  final String? accesRefund;
  final String? accesPayment;
  final String? vendorId;
  final String? plantId;
  final String? orgID;
  final String? read_only;
  final String? attendance_only;



  User({
    required this.orgID,
    required this.personId,
    required this.empCode,
    required this.personName,
    required this.username,
    required this.fatherName,
    required this.motherName,
    required this.dob,
    required this.doj,
    required this.village,
    required this.district,
    required this.state,
    required this.pincode,
    required this.address,
    required this.familyPhone,
    required this.adharNum,
    required this.empEmail,
    required this.empComStatus,
    this.userType,
    this.cPass,
    required this.isActive,
    this.uuid,
    this.orgId,
    required this.isMobile,
    required this.isDuplicate,
    required this.duplicateEmpId,
    required this.termAccept,
    required this.terminationStatus,
    required this.dateUpdated,
    required this.updatedBy,
    required this.copyUserEmployee,
    required this.contactDetails,
    this.approveStatus,
    this.aprovePerson,
    this.accesSaleOrder,
    this.accesDispatch,
    this.accesRefund,
    this.accesPayment,
    this.vendorId,
    this.plantId,
    this.read_only,
    this.attendance_only,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      personId: json['person_id'] ?? 'NA',
      empCode: json['emp_code']  ?? 'NA',
      personName: json['person_name']  ?? 'NA',
      fatherName: json['father_name'] ?? 'NA',
      motherName: json['mother_name']  ?? 'NA',
      dob: json['dob']  ?? 'NA',
      doj: json['doj']  ?? 'NA',
      village: json['village'] ?? 'NA',
      district: json['district'] ?? 'NA',
      state: json['state']  ?? 'NA',
      pincode: json['pincode'] ?? 'NA',
      address: json['address']  ?? 'NA',
      familyPhone: json['family_phone'] ?? 'NA',
      adharNum: json['adhar_num'] ?? 'NA',
      empEmail: json['emp_email'] ?? 'NA',
      empComStatus: json['emp_com_Status']  ?? 'NA',
      userType: json['user_type'] ?? 'NA',
      cPass: json['c_pass'] ?? 'NA',
      username: json['uname'] ?? 'NA',
      isActive: json['is_active'] ?? 'NA',
      isMobile: json['mob_login'] ?? 'NA',
      uuid: json['uuid']?? 'NA',
      orgId: json['org_id']?? 'NA',
      isDuplicate: json['is_duplicate'] ?? 'NA',
      duplicateEmpId: json['duplicate_emp_id'] ?? 'NA',
      termAccept: json['term_accept']?? 'NA',
      terminationStatus: json['termination_status'] ?? 'NA',
      dateUpdated: json['date_updated'] ?? 'NA',
      updatedBy: json['updated_by'] ?? 'NA',
      copyUserEmployee: json['copyUserEmployee'] ?? 'NA',
      contactDetails: json['contact_details'] ?? 'NA',
      approveStatus: json['approve_status']?? 'NA',
      aprovePerson: json['aprove_person']?? 'NA',
      accesSaleOrder: json['acces_sale_order']?? 'NA',
      accesDispatch: json['acces_dispatch']?? 'NA',
      accesRefund: json['acces_refund']?? 'NA',
      accesPayment: json['acces_payment']?? 'NA',
      vendorId: json['vendor_id']?? 'NA',
      plantId: json['plant_id']?? 'NA',
      orgID: json['org_id']??'NA',
      read_only: json['read_only']?? 'NA',
      attendance_only: json['attendance_only']??'NA',
    );
  }
}

class view_user extends StatefulWidget {

  final int currentPage;
  view_user({required this.currentPage});
  
  @override
  _view_userState createState() => _view_userState();
}

class _view_userState extends State<view_user> {
  late Future<List<User>> futureUsers;
  late TextEditingController _typeAheadController;
  User? selectedUser;
  bool? _showActiveUsers; // Default to show all users

  // Variables for user details
  String? username = '';
  String uuid = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';

  int totalUsers = 0;
  int activeUsers = 0;
  int inactiveUsers = 0;

  @override
  void initState() {
    super.initState();
    futureUsers = fetchUsers();
    _typeAheadController = TextEditingController();
  }



  @override
  void dispose() {
    _typeAheadController.dispose();
    super.dispose();
  }

  // Function to fetch data from API
  Future<List<User>> fetchUsers() async {
    await checkLogin();

    final response = await http.post(
      Uri.parse('${URL}user_list_details'),
      body: {
        'uuid':uuid,
        'user_id': username,
        'user_pass': password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<User> users = (data['user_data'] as List)
          .map((userJson) => User.fromJson(userJson))
          .toList();
      // Count active and inactive users
      totalUsers = users.length;
      activeUsers = users.where((user) => user.isActive.toLowerCase() == 'y').length;
      inactiveUsers = totalUsers - activeUsers;

      setState(() {}); // UI update ke liye
      return users;
    } else {
      throw Exception('Failed to load users');
    }
  }


  // Future<List<User>> _getUsers(String searchText) async {
  //   List<User> allUsers = await futureUsers;
  //
  //   if (searchText.isEmpty) {
  //     return _filterUsers(allUsers);
  //   }
  //
  //   // Filter users by username or fullname containing the search text
  //   List<User> filteredUsers = allUsers.where((user) =>
  //   (user.username!.toLowerCase().contains(searchText.toLowerCase()) ||
  //       user.personName.toLowerCase().contains(searchText.toLowerCase())) &&
  //       (_showActiveUsers == null || (_showActiveUsers! ? user.isActive.toLowerCase() == 'y' : true))
  //   ).toList();
  //
  //   return filteredUsers;
  // }


  Future<List<User>> _getUsers(String searchText) async {
    List<User> allUsers = await futureUsers;

    if (searchText.isEmpty) {
      return _filterUsers(allUsers);
    }

    // Filter users by username or fullname containing the search text
    List<User> filteredUsers = allUsers.where((user) =>
    (user.username!.toLowerCase().contains(searchText.toLowerCase()) ||
        user.personName.toLowerCase().contains(searchText.toLowerCase())) &&
        (_showActiveUsers == null || (_showActiveUsers ?? true) ? user.isActive.toLowerCase() == 'y' : user.isActive.toLowerCase() != 'y')
    ).toList();

    return filteredUsers;
  }

  List<User> _filterUsers(List<User> users) {
    // Determine if we should include 'yes' or 'no' based on _showActiveUsers
    bool includeYes = _showActiveUsers ?? true;

    // Filter users based on the condition
    return users.where((user) {
      if (_showActiveUsers == null) {
        return true; // Show all users when _showActiveUsers is null
      } else {
        bool isActive = user.isActive.toLowerCase() == 'y';
        return includeYes ? isActive : !isActive;
      }
    }).toList();
  }


  Future<void> _navigateToEditUser(User user) async {
    final result = 
    await 
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Edit_User(user: user), // Pass full user object
      ),
    );

    if (result == true) {
      // Refresh the user list if changes were made
      setState(() {
        _typeAheadController.clear();
        selectedUser = null;
        futureUsers = fetchUsers();
      });
    }
  }

  //Fetching user details from sharedpreferences
  Future<void> checkLogin() async {
     final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    uuid = prefs.getString("uuid")!;
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
    uuid = prefs.getString("uuid")!;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentPage: widget.currentPage),
      appBar: CustomAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
         Navigator.push(context, MaterialPageRoute(builder: (context) => Add_user()));
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(), // Fixed search bar
          Expanded(
            child: FutureBuilder<List<User>>(
              future: futureUsers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                List<User> users = snapshot.data ?? [];
                users.sort((a, b) => a.personName.toLowerCase().compareTo(b.personName.toLowerCase()));
                users = _filterUsers(users);

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (selectedUser == null) ...[
                          SizedBox(height: 16),
                          Column(
                            children: users.map((user) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                UserCard(
                                  user: user,
                                  onEdit: () => _navigateToEditUser(user),
                                ),
                                SubDetails(user: user),
                                SizedBox(height: 16),
                              ],
                            )).toList(),
                          ),
                        ] else ...[
                          UserCard(
                            user: selectedUser!,
                            onEdit: () => _navigateToEditUser(selectedUser!),
                          ),
                          SubDetails(user: selectedUser!),
                        ],
                      ],
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


  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TypeAheadField<User>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _typeAheadController,
                    decoration: InputDecoration(
                      labelText: 'Search by username /full name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    return await _getUsers(pattern);
                  },
                  itemBuilder: (context, User user) {
                    return ListTile(
                      title: Text('${user.personName} - (${user.username})'),
                    );
                  },
                  onSuggestionSelected: (User user) {
                    setState(() {
                      selectedUser = user;
                      _typeAheadController.text = '${user.personName} - (${user.username})';
                    });
                  },
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedUser = null;
                    _typeAheadController.clear();
                  });
                },
                child: Text('Clear'),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showActiveUsers = true;
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen, padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),),
                child: RichText(
                  text: TextSpan(
                    text: "Active User ", // Default text
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    children: [
                      TextSpan(
                        text: "($activeUsers)", // Active user count
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

              ),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showActiveUsers = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                child:
                RichText(
                  text: TextSpan(
                    text: "InActive", // Default text
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    children: [
                      TextSpan(
                        text: " ($inactiveUsers)", // Active user count
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // Text(
                //   "InActive ($inactiveUsers)",
                //   style: TextStyle(color: Colors.white, fontSize: 12),
                // ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showActiveUsers = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                child: RichText(
                  text: TextSpan(
                    text: "All User", // Default text
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    children: [
                      TextSpan(
                        text: " ($totalUsers)", // Active user count
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // Text(
                //   "All User ($totalUsers)",
                //   style: TextStyle(color: Colors.white, fontSize: 12),
                // ),
              ),
            ],
          ),

        ],
      ),
    );
  }

}



class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onEdit; // Callback for the edit action

  const UserCard({required this.user, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    bool isActive = user.isActive.toLowerCase() == 'y'; // Check if activeUser is "yes"

    print(isActive);
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Full Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 24.0,
                    ),
                    color: Colors.black,
                    onPressed: onEdit, // Call the provided onEdit callback
                  ),
                ],
              ),
              Text(
                user.personName,
                style: TextStyle(fontSize: 24, color: Colors.blue),
              ),
              SizedBox(height: 10),
              // Text(
              //   'Email',
              //   style: TextStyle(fontWeight: FontWeight.bold),
              // ),
              // Text(
              //   user.empEmail,
              //   style: TextStyle(color: Colors.orange),
              // ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green : Colors.red, // Dynamic color based on isActive
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    isActive == true ? 'Active' : 'InActive', // Dynamic text based on isActive
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class SubDetails extends StatefulWidget {
  final User user;

  const SubDetails({required this.user});

  @override
  State<SubDetails> createState() => _SubDetailsState();
}

class _SubDetailsState extends State<SubDetails> {

  // Variables for user details
  String? username = '';
  String uuid = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';

  @override
  void initState() {
    super.initState();
    checkLogin();
    // fetchAndStoreData();
    // print("ASFasf");
    // print(widget.user.plantId );
    // print(widget.user.vendorId );
    // print(widget.user.orgID );
  }

  //Fetching user details from sharedpreferences
  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    uuid = prefs.getString("uuid")!;
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
    uuid = prefs.getString("uuid")!;
  }

  String orgNames = "";
  String branchNames = "";
  String vendorNames = "";



  Future<void> fetchAndStoreData() async {

    await checkLogin();

    final response = await http.post(
      Uri.parse('${URL}fetchplantOrg'),
      body: {
        // 'user_id':'bantu',
        // 'user_pass':'Bantu#123',
        // 'uuid':'UP1A.231005.007',
        // 'branch_id':'1,2',
        // 'vendor_id':'1,2',
        // 'org_id':'1,2',

        'uuid':uuid,
        'user_id': username,
        'user_pass': password,
        "branch_id":widget.user.plantId ,
        "vendor_id": widget.user.vendorId,
        "org_id": widget.user.orgID
      },
    );


    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      List<dynamic> organizations = responseData["organizatrion"];

      setState(() {
        orgNames = organizations.map((org) => org["OrgName"].toString()).join(", ");
        branchNames = organizations.map((org) => org["branch_name"].toString()).join(", ");
        vendorNames = organizations.map((org) => org["vendor_name"].toString()).join(", ");
      });

      print("Org Names: $orgNames");
      print("Branch Names: $branchNames");
      print("Vendor Names: $vendorNames");
    } else {
      print("Failed to fetch data: ${response.statusCode}");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Table(
            // border: TableBorder.all(color: Colors.black),
            columnWidths: {
              0: FixedColumnWidth(150),
            },
            children: [
              buildTableRows(
                ['Username', 'Password'],
                [widget.user.username, widget.user.cPass],
                1,
              ),
              // buildTableRow('Email ID', widget.user.empEmail,0),
              buildTableRows(
                ['User Type', 'UUID'],
                [widget.user.userType, widget.user.uuid],
                0,
              ),
              // buildTableRows(
              //   ['Organization', 'Active'],
              //   [widget.user.orgID,widget.user.isActive == 'Y' ? 'Yes' : 'No'],
              //   0,
              // ),
              buildTableRows(
                ['Mobile Login', 'Access Sale Order'],
                [widget.user.isMobile== 'Y' ? 'Yes' : 'No', widget.user.accesSaleOrder== 'Y' ? 'Yes' : 'No'],
                1,
              ),
              buildTableRows(
                ['Access Dispatch', 'Acccess Refund'],
                [widget.user.accesDispatch== 'Y' ? 'Yes' : 'No', widget.user.accesRefund== 'Y' ? 'Yes' : 'No'],
                0,
              ),
              buildTableRows(
                ['Access Payment', 'Emp Code'],
                [widget.user.accesPayment== 'Y' ? 'Yes' : 'No', widget.user.empCode],
                1,
              ),

              // buildTableRow('Vendor Name', orgNames,0),
              // buildTableRow('Plant Name', orgNames,1),

              // buildTableRow('Material', user.material,1),
              // if (user.plant != null) buildTableRow('Plant', user.plant!,1),

            ],
          ),
        ),
      ),
    );
  }

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





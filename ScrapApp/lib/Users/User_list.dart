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


// User model to parse JSON data
class User {
  final String personId;
  final String empCode;
  final String personName;
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
  final String? uname;
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

  User({
    required this.personId,
    required this.empCode,
    required this.personName,
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
    this.uname,
    required this.isActive,
    this.uuid,
    this.orgId,
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
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      personId: json['person_id'] ?? '',
      empCode: json['emp_code'] ?? '',
      personName: json['person_name'] ?? '',
      fatherName: json['father_name'] ?? '',
      motherName: json['mother_name'] ?? '',
      dob: json['dob'] ?? '',
      doj: json['doj'] ?? '',
      village: json['village'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      address: json['address'] ?? '',
      familyPhone: json['family_phone'] ?? '',
      adharNum: json['adhar_num'] ?? '',
      empEmail: json['emp_email'] ?? '',
      empComStatus: json['emp_com_Status'] ?? '',
      userType: json['user_type'],
      cPass: json['c_pass'],
      uname: json['uname'],
      isActive: json['is_active'] ?? '',
      uuid: json['uuid'],
      orgId: json['org_id'],
      isDuplicate: json['is_duplicate'] ?? '',
      duplicateEmpId: json['duplicate_emp_id'] ?? '',
      termAccept: json['term_accept'] ?? '',
      terminationStatus: json['termination_status'] ?? '',
      dateUpdated: json['date_updated'] ?? '',
      updatedBy: json['updated_by'] ?? '',
      copyUserEmployee: json['copyUserEmployee'] ?? '',
      contactDetails: json['contact_details'] ?? '',
      approveStatus: json['approve_status'],
      aprovePerson: json['aprove_person'],
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
  String? password = '';
  String? loginType = '';
  String? userType = '';

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
        // 'uuid': _uuid,
        'user_id': username,
        'user_pass': password,
        // 'user_type': _user_type,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<User> users = (data['user_data'] as List)
          .map((userJson) => User.fromJson(userJson))
          .toList();
      return users;
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<List<User>> _getUsers(String searchText) async {
    List<User> allUsers = await futureUsers;

    if (searchText.isEmpty) {
      return _filterUsers(allUsers);
    }

    // Filter users by username or fullname containing the search text
    List<User> filteredUsers = allUsers.where((user) =>
    (user.uname!.toLowerCase().contains(searchText.toLowerCase()) ||
        user.personName.toLowerCase().contains(searchText.toLowerCase())) &&
        (_showActiveUsers == null || (_showActiveUsers ?? true) ? user.isActive.toLowerCase() == 'yes' : user.isActive.toLowerCase() != 'yes')
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
        bool isActive = user.isActive.toLowerCase() == 'yes';
        return includeYes ? isActive : !isActive;
      }
    }).toList();
  }


  Future<void> _navigateToEditUser(String userId) async {
    final result = 
    await 
    Navigator.pushReplacement(
      context,
      // MaterialPageRoute(builder: (context) => EditUsers(userId: userId)),
      MaterialPageRoute(builder: (context) => LeaveApplication(currentPage: 0),

    ));

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
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
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
                                  onEdit: () => _navigateToEditUser(user.personId),
                                ),
                                SubDetails(user: user),
                                SizedBox(height: 16),
                              ],
                            )).toList(),
                          ),
                        ] else ...[
                          UserCard(
                            user: selectedUser!,
                            onEdit: () => _navigateToEditUser(selectedUser!.personId),
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
                      title: Text('${user.personName} - (${user.uname})'),
                    );
                  },
                  onSuggestionSelected: (User user) {
                    setState(() {
                      selectedUser = user;
                      _typeAheadController.text = '${user.personName} - (${user.uname})';
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),),
                child: Text(
                  "Active User",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showActiveUsers = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  "InActive ",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showActiveUsers = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  "All User",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
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
    bool isActive = user.isActive.toLowerCase() == 'yes'; // Check if activeUser is "yes"

    return Container(
      width: double.infinity,
      child: Card(
        elevation: 10,
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
              Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                user.empEmail,
                style: TextStyle(color: Colors.orange),
              ),
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
                    isActive ? 'Active' : 'Not Active', // Dynamic text based on isActive
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

class SubDetails extends StatelessWidget {
  final User user;

  const SubDetails({required this.user});

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
                [user.uname, user.cPass],
                1,
              ),
              buildTableRows(
                ['User Type', 'UUID'],
                [user.userType, user.uuid],
                1,
              ),
              // buildTableRows(
              //   ['Access Scrap Data', 'Access Seal Data'],
              //   [user.accessScrapData, user.accessSealData],
              //   1,
              // ),
              // buildTableRows(
              //   ['Active User', 'Allowed Mobile Login'],
              //   [user.activeUser, user.allowedMobileLogin],
              //   1,
              // ),
              // buildTableRows(
              //   ['Receiver', 'Sender'],
              //   [user.receiver, user.sender],
              //   1,
              // ),
              // buildTableRows(
              //   ['Access GPS Module', 'App Version'],
              //   [user.accessGpsModule, user.appVersion],
              //   1,
              // ),
              //
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





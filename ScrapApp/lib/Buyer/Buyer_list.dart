import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';
import '../Model/BuyerData.dart';
import '../URL_CONSTANT.dart';
import 'Buyer_EditForm.dart';
import 'Buyer_Form.dart';
import 'package:url_launcher/url_launcher.dart';

class Buyer_list extends StatefulWidget {
  final int currentPage;
  Buyer_list({required this.currentPage});

  @override
  _Buyer_listState createState() => _Buyer_listState();
}

class _Buyer_listState extends State<Buyer_list> {
  List<BuyerData> buyersData = [];

  Future<List<BuyerData>> _buyerDataFuture = Future<List<BuyerData>>.value([]);

  TextEditingController _searchController = TextEditingController();

  //Variables for user details
  String? username = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';

  @override
  void initState() {
    super.initState();
    _buyerDataFuture = _getBuyerData();
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
      // _buyerDataFuture = _getBuyerData(query: query);
    });
  }

  Future<List<BuyerData>> _getBuyerData() async {
    await checkLogin();

    try {
      // Prepare the request body with user credentials
      Map<String, dynamic> requestBody = {
        'user_id': username,
        'user_pass': password,
      };

      // Make an HTTP POST request to the API endpoint
      final response = await http.post(
        Uri.parse('${URL}ajax_bidder_list'),
        headers: {"Accept": "application/json"},
        body: requestBody,
      );

      // Check if the response status code is 200 (OK)
      if (response.statusCode == 200) {
        // Parse the response body as JSON
        final data = json.decode(response.body);
        print(data);
        print("sfdefe");

        // Check if the API response contains the buyer list
        if (data["buyer_list"] != null) {
          // Create a list to store the fetched buyer data
          List<BuyerData> fetchedBuyersData = [];

          // Iterate through each buyer in the response data
          for (var buyer in data["buyer_list"]) {
            // Initialize a new BuyerData object based on the response data
            BuyerData buyerData = BuyerData(
              srNo: buyer[0]?.toString() ?? "",
              name: buyer[1] ?? "",
              companyName: buyer[2] ?? "",
              email: buyer[3]?.replaceAll('<br>', '\n') ?? "",
              phone: buyer[4]?.replaceAll('<br>', '\n') ?? "",
              address: buyer[5] ?? "",
              gstNumber: buyer[6] ?? "",
              entityType: buyer[7] ?? "",
              activeStatus: buyer[8] ?? "",
              businessType: buyer[9] ?? "",
              contactPerson: buyer[10] ?? "",
              Buyer_id: buyer[11] ?? "",
              CPCB: buyer[12] ?? "",
              CPCBdate: buyer[13] ?? "",
              SPCB: buyer[14] ?? "",
              SPCBdate: buyer[15] ?? "",

              country: buyer[17] ?? "",
              pan: buyer[18] ?? "",
              state: buyer[19] ?? "",
              city: buyer[20] ?? "",
              pinCode: buyer[21] ?? "",
              formType: buyer[22] ?? "",

              // Active: "",  // You can set it to a default value or omit it if not present
            );
            // Add the BuyerData object to the list
            fetchedBuyersData.add(buyerData);
          }

          setState(() {
            buyersData = List.from(fetchedBuyersData);
          });

          // Return the fetched buyer data
          return fetchedBuyersData;
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

  void _openFile(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch $url");

      // Show dialog if the file cannot be opened
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Message'),
            // content: Text('$url'),
            content: Text('No file available or the file could not be opened.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
  Future<void> deleteBuyer(String Buyer_id) async {
    try {
      print(Buyer_id);
      print('pooja');
      final response = await http.post(
        Uri.parse('${URL}bidder_delete'),
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'user_pass': password,
          'object_id': Buyer_id,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["success"] == true) {
          print('Seal record deleted successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Buyer deleted successfully!')),
          );
          setState(() {
            _buyerDataFuture = _getBuyerData(); // Refresh the seal data
          });
        } else {
          print('Failed to delete buyer record: ${data["msg"]}');
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
      _buyerDataFuture = _getBuyerData();
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Buyer_Form()),
            );
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.blueGrey[200], // FAB background color
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await _refreshData();
          },
          child: FutureBuilder<List<BuyerData>>(
            future: _buyerDataFuture,
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
                                "Buyer",
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
                                  borderRadius: BorderRadius.circular(
                                      12), // Rounded corners
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

  List<BuyerData> _filterData(List<BuyerData> data, String query) {
    // Trim white spaces from the query
    query = query.trim();

    if (query.isEmpty) {
      // If the query is empty, return the original data
      return data;
    }

    // Filter data based on the search query (case insensitive)
    return data
        .where((buyer) =>
            buyer.srNo!.toLowerCase().contains(query.toLowerCase()) ||
            buyer.name!.toLowerCase().contains(query.toLowerCase()) ||
            // buyer.vehicle_no!.toLowerCase().contains(query.toLowerCase()) ||
            // buyer.rejected_seal_no!.toLowerCase().contains(query.toLowerCase()) ||
            // buyer.new_seal_no!.toLowerCase().contains(query.toLowerCase()) ||
            // buyer.start_seal_no!.toLowerCase().contains(query.toLowerCase()) ||
            buyer.companyName!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Widget _buildSealsList(List<BuyerData> buyersData) {
    List<BuyerData> filteredData =
        _filterData(buyersData, _searchController.text);

    return ListView.builder(
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        BuyerData buyer = filteredData[index];

        return Column(
          children: [
            Card(
              color: Colors.blueGrey[500],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Text(
                          '${buyer.srNo ?? 'N/A'}.  ${buyer.name ?? 'N/A'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.white,
                          ),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Buyer_EditForm(
                                  details: buyer.formType,
                                  buyerID: buyer.Buyer_id,
                                  country: buyer.country,
                                  gstNumber: buyer.gstNumber,
                                  finYear: '',
                                  buyerName: buyer.name,
                                  contactPerson: buyer.companyName,
                                  address: buyer.address,
                                  state: buyer.state,
                                  city: buyer.city,
                                  pinCode: buyer.pinCode,
                                  pan: buyer.pan,
                                  companyType: buyer.entityType,
                                  natureActivity: buyer.businessType,
                                  phone: buyer.phone,
                                  email: buyer.email,
                                  CPCB: buyer.CPCB,
                                  CPCBdate: buyer.CPCBdate,
                                  SPCB: buyer.SPCB,
                                  SPCBdate: buyer.SPCBdate,
                                  isActive: buyer.activeStatus,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_forever,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            // Show confirmation dialog before deleting
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Are you sure?'),
                                  content:
                                      Text('Do you want to delete this buyer?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                        deleteBuyer(buyer.Buyer_id ??
                                            ''); // Proceed with deletion
                                      },
                                      child: Text('Yes'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Table(
                    columnWidths: {0: FixedColumnWidth(150)},
                    children: [
                      buildTableRows(
                        ['Buyer Company Name', 'Email'],
                        [buyer.name, buyer.email],
                        0, // Provide index
                      ),
                      buildTableRows(
                        ['Contact Person', 'Contacts'],
                        [buyer.contactPerson, buyer.phone],
                        1, // Provide index
                      ),
                      buildTableRow('Address', buyer.address, 2), // Provide index
                      buildTableRows(
                        ['Type Of Company', 'GST Number'],
                        [buyer.entityType, buyer.gstNumber],
                        3, // Provide index
                      ),
                      buildTableRows(
                        ['Is Active', 'Nature Of Activity'],
                        [buyer.activeStatus, buyer.businessType],
                        4, // Provide index
                      ),
                      buildTableRow('Updated By', buyer.contactPerson, 5), // Provide index
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: buyer.CPCB.isNotEmpty
                            ? () => _openFile(context, buyer.CPCB)  // Pass context here
                            : null,
                        icon: const Icon(Icons.file_present, color: Colors.blue),
                        label: const Text("View CPCB"),
                      ),
                      SizedBox(width: 14),
                      TextButton.icon(
                        onPressed: buyer.SPCB.isNotEmpty
                            ? () => _openFile(context, buyer.SPCB)  // Pass context here
                            : null,
                        icon: const Icon(Icons.file_present, color: Colors.blue),
                        label: const Text("View SPCB"),
                      ),
                    ],
                  )

                ],
              ),
            ),
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

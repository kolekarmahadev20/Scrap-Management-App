import 'dart:convert'; // Import this for JSON decoding
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../AppClass/appBar.dart';
import '../URL_CONSTANT.dart';


// Forward_AllAuction_List widget displays a list of auctions.
class OrganizationList extends StatefulWidget {
  @override
  State<OrganizationList> createState() =>
      _OrganizationListState();
}

class _OrganizationListState extends State<OrganizationList> {


  //Variables for user details
  String? username = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';

  bool _isLoading = true;

  List<Map<String, dynamic>> _organization = [];

  @override
  void initState() {
    super.initState();
    checkLogin(); // Fetch bidder details when the widget initializes
    _fetchorganizationData(); // Fetch auction data when the widget initializes
  }


  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
  }

  // Fetch auction data from API
  Future<void> _fetchorganizationData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiUrl = '${URL}oorganizationlist';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Accept": "application/json"},
        body: {'user_id': username, 'user_pass': password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['user_data'] != null && data['user_data'] is List) {
          setState(() {
            _organization = List<Map<String, dynamic>>.from(data['user_data']);
          });
        } else {
          print('Invalid data format');
        }
      } else {
        print('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: Column(
        children: [
          // Filter Section
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Forward Auction",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // TextButton.icon(
                //   icon: Icon(Icons.filter_list_alt, color: Colors.grey),
                //   label: Text('FILTER',
                //       style: TextStyle(fontSize: 14, color: Colors.grey)),
                //   onPressed: () {
                //     // Handle filter button press
                //   },
                // ),
                SizedBox(height: 30),
              ],
            ),
          ),
          // Auction List
          Expanded(
            child: _isLoading
                ? Center(
                child:
                CircularProgressIndicator()) // Show loading spinner while data is being fetched
                : _organization.isEmpty
                ? Center(
              child: Text(
                'No Data Found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : ListView.separated(
              itemCount: _organization.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.shade200,
              ),
              itemBuilder: (context, index) {
                final auction = _organization[index];
                return AuctionItem(
                  auctionId: auction['OrgName'] ?? '',
                  startDate: auction['OrgAddress'] ?? '',
                  vendorName: auction['org_type'] ?? '',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// AuctionItem widget displays individual auction details.
class AuctionItem extends StatelessWidget {
  final String auctionId;
  final String startDate;
  final String vendorName;

  AuctionItem({
    required this.auctionId,
    required this.startDate,
    required this.vendorName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        contentPadding: EdgeInsets.all(10),
        leading: CircleAvatar(
          radius: 30.0,
          backgroundImage: AssetImage('assets/images/salasar.PNG'),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                "$vendorName",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '(ID: $auctionId)',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text('Auction Date: $startDate',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) =>
          //         Forward_AuctionDetails(auctionId: auctionId),
          //   ),
          // );
        },
      ),
    );
  }


}

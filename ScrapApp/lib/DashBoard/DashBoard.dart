import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/DashBoard/saleOrderList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../URL_CONSTANT.dart';

class DashBoard extends StatefulWidget {
  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  String? username;
  String? password;
  String? saleOrders;
  String? buyerCount;
  String? auctionCmp;
  List<int> saleOrder =[];
  String? totalSaleOrder = '92';


  @override
  void initState() {
    super.initState();
    checkLogin();
    fetchDashBoardData();
  }

  // Fetch saved login data from SharedPreferences
  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    password = prefs.getString("password");
  }

  // Fetch dashboard data from the server
  Future<void> fetchDashBoardData() async {
    try {
      await checkLogin();
      final url = Uri.parse("${URL}Dashboard");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'user_pass': password,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          saleOrders = jsonData['saleorder']['sale_cnt'];
          buyerCount = jsonData['bidders']['bidder_cnt'];
          auctionCmp = jsonData['auction_company']['auc_cnt'];
        });
      } else {
        _handleError("Unable to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      _handleError("Server Exception: $e");
    }
  }

  // Handle errors
  void _handleError(String message) {
    print(message);
    // You can also show a dialog or a snackbar to inform the user
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: AppDrawer(),
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: _buildGraph(screenHeight,screenWidth),
            ),
            SizedBox(height: 16),
            _buildSummaryCards(screenWidth, screenHeight),
          ],
        ),
      ),
    );
  }

  // Build the graph section
  Widget _buildGraph(double screenHeight , double screenWidth) {
    return Container(
        width: screenWidth * 1.0,
        height: screenHeight * 0.3,
      padding: EdgeInsets.all(16.0),
      decoration: _boxDecoration(),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  _buildLineChartBarData([FlSpot(0, 3), FlSpot(1, 1), FlSpot(2, 4), FlSpot(3, 2), FlSpot(4, 5), FlSpot(5, 3)], Colors.green),
                  _buildLineChartBarData([FlSpot(0, 2), FlSpot(1, 3), FlSpot(2, 2), FlSpot(3, 5), FlSpot(4, 3), FlSpot(5, 4)], Colors.orange),
                ],
                titlesData: FlTitlesData(show: false),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
              ),
            ),
          ),
          SizedBox(height: 15),
          _buildGraphLegend(),
        ],
      ),
    );
  }

  // Build line chart bar data
  LineChartBarData _buildLineChartBarData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2,
      belowBarData: BarAreaData(show: false),
    );
  }

  // Build the graph legend
  Widget _buildGraphLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.green, "Active SO"),
        _buildLegendItem(Colors.orange, "Closed SO"),
      ],
    );
  }

  // Build a legend item for the graph
  Widget _buildLegendItem(Color color, String label) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 10, height: 10, color: color),
          SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }

  // Build summary cards
  Widget _buildSummaryCards(double screenWidth, double screenHeight) {
    return Column(
      children: [
        SizedBox(height: 10,),
        Container(
          width: screenWidth * 1.0,
          height: screenHeight * 0.25,
          child: Row(
            children: [
              _buildCard("$saleOrders", "Auction Company", () {}, true),
              _buildCard("$totalSaleOrder", "Total Sale Order", () {}, false),
            ],
          ),
        ),
        SizedBox(height: 10,),
        Container(
          width: screenWidth * 1.0,
          height: screenHeight * 0.25,
          child: Row(
            children: [
              _buildCard("$auctionCmp", "Auction Company", () {}, false),
              _buildCard("$buyerCount", "Buyer", () {}, false),
            ],
          ),
        ),
      ],
    );
  }

  // Build a card widget
  Widget _buildCard(String value, String label, VoidCallback onPressed, bool isOnPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: _boxDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              Text(label),
              Spacer(),
              if (isOnPressed) _buildCardActions(onPressed),
            ],
          ),
        ),
      ),
    );
  }

  // Build card actions
  Widget _buildCardActions(VoidCallback onPressed) {
    return Row(
      children: [
        TextButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => saleOrderList()));
            }, child: Text("View More")),
        Expanded(
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.arrow_forward_ios_outlined, color: Colors.deepPurple, size: 20),
          ),
        ),
      ],
    );
  }

  // Box decoration for containers
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 3),
        ),
      ],
    );
  }
}



class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color circleColor;
  final Color backgroundColor;
  final Function() onPressed;

  SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    this.circleColor = Colors.blue,
    this.backgroundColor = Colors.white,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              Text(label),
              Spacer(),
              Row(
                children: [
                  TextButton(
                    onPressed:onPressed,
                    child: Text("View More"),
                  ),
                  IconButton(onPressed:onPressed, icon: Icon(Icons.arrow_forward_ios_outlined ,color: Colors.deepPurple,size: 20,),)
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

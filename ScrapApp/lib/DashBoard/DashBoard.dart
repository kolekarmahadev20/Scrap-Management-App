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
  String? curr_year;
  List<dynamic> graph =[];



  @override
  void initState() {
    super.initState();
    checkLogin();
    fetchDashBoardData();
    getLastSixMonths();
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
          graph = jsonData['six_month_data'];
          print(graph);
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildGraph(screenHeight,screenWidth),
              ),
              _buildSummaryCards(screenWidth, screenHeight),
            ],
          ),
        ),
      ),
    );
  }

  // Build the graph section
// Build the graph section
  Widget _buildGraph(double screenHeight, double screenWidth) {
    List<String> lastSixMonths = getLastSixMonths();
    return Container(
      width: screenWidth * 1.0,
      height: screenHeight * 0.35,
      padding: EdgeInsets.all(16.0),
      decoration: _boxDecoration(),
      child: Column(
        children: [
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35, // Increase the reserved space for the Y-axis labels
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 10, // Add space between the labels and the bars
                          child: Text(
                            value.toStringAsFixed(0), // Display the Y-axis values
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                        );
                      },
                    ),
                  ),
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 50, // Increase the reserved size to give more space for labels
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value >= 0 && value < lastSixMonths.length) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(lastSixMonths[value.toInt()]), // Get the month name from the list
                          );
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(''), // Return empty if out of range
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                barGroups: _buildBarGroups(),
                gridData: FlGridData(show: false),
              ),
            ),
          ),
          _buildGraphLegend(),
        ],
      ),
    );
  }

// Build the bar chart data groups
  List<BarChartGroupData> _buildBarGroups() {
    if (graph.isEmpty) {
      return [];
    }
    return List.generate(graph.length, (index) {
      int count = int.tryParse(graph[index]['cnt'].toString()) ?? 0; // Use tryParse for safety
      return _buildBarGroup(index, count, Colors.green);
    });
  }
// Create a bar chart group for a specific index and value
  BarChartGroupData _buildBarGroup(int x, int y, Color color) {
    // double clampedValue = y.clamp(0, 100);
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y.toDouble(),
          color: color,
          width: 30,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  //To dynamically get the Last six months on the chart
  List<String> getLastSixMonths() {
    DateTime now = DateTime.now();
    List<String> months = [];

    for (int i = 0; i < graph.length; i++) {
      DateTime date = DateTime(now.year, now.month - i, 1);
      String month = "${_getMonthName(date.month)}";
      months.add(month);
      curr_year ='${date.year}';
    }

    return months.reversed.toList();
  }
  String _getMonthName(int month) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }



  // Build the graph legend
  Widget _buildGraphLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.green, "Active SO (${curr_year})"),
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
              _buildCard("$saleOrders", "Active Sale Order", () {}, true , Colors.blue),
              _buildCard("$saleOrders", "Total Sale Order", () {}, false , Colors.green),
            ],
          ),
        ),
        SizedBox(height: 10,),
        Container(
          width: screenWidth * 1.0,
          height: screenHeight * 0.25,
          child: Row(
            children: [
              _buildCard("$auctionCmp", "Auction Company", () {}, false ,  Colors.deepPurple),
              _buildCard("$buyerCount", "Buyer", () {}, false , Colors.pink),
            ],
          ),
        ),
      ],
    );
  }

  // Build a card widget
  Widget _buildCard(String value, String label, VoidCallback onPressed, bool isOnPressed , Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: color),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold , color: color)),
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
            },
            child: Text("View More" , style: TextStyle(color: Colors.blue),)),
        Expanded(
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.arrow_forward_ios_outlined, color: Colors.blue, size: 20),
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




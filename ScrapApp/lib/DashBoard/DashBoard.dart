import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';

class DashBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get screen width and height
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: AppDrawer(),
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Graph with static values
            Container(
              height: screenHeight * 0.3, // 30% of screen height
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
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
              ),
              child: Column(
                children: [
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              FlSpot(0, 3),
                              FlSpot(1, 1),
                              FlSpot(2, 4),
                              FlSpot(3, 2),
                              FlSpot(4, 5),
                              FlSpot(5, 3),
                            ],
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 2,
                            belowBarData: BarAreaData(show: false),
                          ),
                          LineChartBarData(
                            spots: [
                              FlSpot(0, 2),
                              FlSpot(1, 3),
                              FlSpot(2, 2),
                              FlSpot(3, 5),
                              FlSpot(4, 3),
                              FlSpot(5, 4),
                            ],
                            isCurved: true,
                            color: Colors.orange,
                            barWidth: 2,
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                        titlesData: FlTitlesData(show: false),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: true),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 10, height: 10, color: Colors.green),
                            SizedBox(width: 4),
                            Text("Active SO"),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 10, height: 10, color: Colors.orange),
                            SizedBox(width: 4),
                            Text("Closed SO"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),
            // Summary Cards
            Material(
              elevation: 1,
              child: Container(
                width: screenWidth * 0.9, // 90% of screen width
                height: screenHeight * 0.3, // 30% of screen height
                child: Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        icon: Icons.currency_rupee,
                        label: "Active Sale Order",
                        value: "36",
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: SummaryCard(
                        icon: Icons.currency_rupee,
                        label: "Lifting",
                        value: "92.76",
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),
            // Bottom graph with static values
            Container(
              height: screenHeight * 0.3, // 30% of screen height
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
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
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildProgressBar(progress: 5, maxProgress: 10, label: 'Item'),
                  _buildProgressBar(progress: 6, maxProgress: 10, label: 'Item'),
                  _buildProgressBar(progress: 7, maxProgress: 10, label: 'Item'),
                  _buildProgressBar(progress: 8, maxProgress: 10, label: 'Item'),
                  _buildProgressBar(progress: 9, maxProgress: 10, label: 'Item'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildProgressBar({required String label, required int progress, required int maxProgress}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(height: 8),
      Container(
        width: 16,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: FractionallySizedBox(
          heightFactor: progress / maxProgress,
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.8),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
      Text(label),
    ],
  );
}

class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color circleColor;
  final Color backgroundColor;

  SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    this.circleColor = Colors.blue,
    this.backgroundColor = Colors.white,
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
                    onPressed:() {},
                    child: Text("View More"),
                  ),
                  IconButton(onPressed: (){}, icon: Icon(Icons.arrow_forward_ios_outlined ,color: Colors.deepPurple,size: 20,),)
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

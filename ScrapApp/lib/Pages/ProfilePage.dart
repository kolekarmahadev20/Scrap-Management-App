import 'package:flutter/material.dart';
import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: CustomAppBar(),
      backgroundColor: Color(0xFFF5FFFA), // Mint Cream Background Color
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Picture Section
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF87CEEB), Color(0xFFfadced)], // Primary Blue and Accent Color
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/welcome_image.gif'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Bharat Chaudhari',
                      style: TextStyle(
                        color: Color(0xFF2F4F4F), // Dark Slate Gray Text Color
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'bharat.chaudhari@salasarauction.com',
                      style: TextStyle(
                        color: Color(0xFF2F4F4F), // Dark Slate Gray Text Color
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
              // User Details
              _buildProfileItem(Icons.person, 'Name', 'John Doe'),
              _buildProfileItem(Icons.email, 'Email', 'johndoe@gmail.com'),
              _buildProfileItem(Icons.phone, 'Phone', '+1 234 567 8901'),
              _buildProfileItem(Icons.home, 'Address', '1234 Elm Street, Springfield, IL'),
              _buildProfileItem(Icons.calendar_today, 'Date of Birth', 'January 1, 1990'),
              _buildProfileItem(Icons.accessibility, 'Gender', 'Male'),
              _buildProfileItem(Icons.business, 'Occupation', 'Software Developer'),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget for Profile Info Items
  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF87CEEB)), // Primary Blue Icon Color
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2F4F4F), // Dark Slate Gray Text Color
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

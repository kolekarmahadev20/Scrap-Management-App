import 'package:flutter/material.dart';
import 'ProfilePage.dart';

class StartPage extends StatefulWidget {
  @override
  State<StartPage> createState() => _StartDashBoardPageState();
}

class _StartDashBoardPageState extends State<StartPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true; // Variable to manage password visibility

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Log in")),
        backgroundColor: Colors.indigo[800], // Navy blue for AppBar background
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          brightness: Brightness.dark,
          primaryColor: Colors.indigo[800], // Navy blue primary color
          colorScheme: ColorScheme.dark(
            primary: Colors.indigo.shade800,
            secondary: Colors.lightBlueAccent, // Sky blue accent color
          ),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white70),
            labelLarge: TextStyle(color: Colors.black),
            headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          inputDecorationTheme: InputDecorationTheme(
            prefixIconColor: Colors.white70, // Icon color
            labelStyle: TextStyle(color: Colors.white70),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2.0), // Sky blue border
              borderRadius: BorderRadius.circular(30),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white54, width: 1.0),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.blue.shade900, // Button text color
              backgroundColor: Colors.white, // Sky blue background
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 10,
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo[300]!, Colors.indigo.shade50], // Gradient from navy to sky blue
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          height: double.infinity,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Placeholder for a logo
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Icon(
                      Icons.account_circle,
                      size: 100,
                      color: Colors.deepPurple.shade50,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: usernameController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        labelText: 'Username',
                        fillColor: Colors.white12,
                        filled: true,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white70,
                          ),
                          onPressed: _togglePasswordVisibility, // Toggle visibility
                        ),
                        prefixIcon: Icon(Icons.lock),
                        labelText: 'Password',
                        fillColor: Colors.white12,
                        filled: true,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfilePage()),
                          );
                        },
                        child: Text("Log In", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

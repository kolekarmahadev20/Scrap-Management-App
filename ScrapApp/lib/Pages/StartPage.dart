import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../URL_CONSTANT.dart';
import 'ProfilePage.dart';

class StartPage extends StatefulWidget {
  @override
  State<StartPage> createState() => _StartDashBoardPageState();
}

class _StartDashBoardPageState extends State<StartPage> {
  TextEditingController usernameController = TextEditingController(text: "Bantu");
  TextEditingController passwordController = TextEditingController(text : "Bantu#123");
  bool _obscureText = true; // Variable to manage password visibility


  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }


/*---------------------------------------------------------------------------------------------------------------*/
// Function to save user data
  Future<void> saveUserData(bool isLoggedIn ,String name, String contact, String email, String empCode, String address) async {
    final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', isLoggedIn);
        await prefs.setString('name', name);
        await prefs.setString('contact', contact);
        await prefs.setString('email', email);
        await prefs.setString('empCode', empCode);
        await prefs.setString('address', address);
    }

/*---------------------------------------------------------------------------------------------------------------*/
  checkLogin(String username , String password)async{
    final login = await SharedPreferences.getInstance();
    await login.setString("username", username);
    await login.setString("password", password);
  }
/*---------------------------------------------------------------------------------------------------------------*/

  //Api function for Getting login Credentials and setting onto next page
  Future<void> getCredentials() async {
    String username = usernameController.text;
    String password = passwordController.text;
    try {
      final url = Uri.parse("${URL}login");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'user_pass': password,
        },
      );

      var jsonData = json.decode(response.body);
      if (jsonData['success'] == true) {
        var user_data = jsonData['session_data'];

        // Access fields using keys
        var person_name = user_data['user_name'];
        var person_email = user_data['user_email'];
        var emp_code = user_data['emp_code'];
        var emp_address = user_data['emp_address'];
        var contact = user_data['Mobile'];

        await saveUserData(true ,person_name, contact, person_email, emp_code, emp_address);
        await checkLogin(username, password);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
      } else {
        showErrorDialog("${jsonData['msg']}");
        print("${jsonData['msg']}");

      }
    } catch (e) {
      showErrorDialog("Server Exception: $e");
      print("Server Exception: $e");
    }
  }

/*---------------------------------------------------------------------------------------------------------------*/

  //Display Error Message
  showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message , textAlign: TextAlign.center,),
          icon: Icon(Icons.crisis_alert_sharp, color: Colors.red, size: 60,),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

/*---------------------------------------------------------------------------------------------------------------*/









  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState){
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
                            setState((){
                              getCredentials();
                            });
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
      });
  }
}

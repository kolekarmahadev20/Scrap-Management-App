import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:scrapapp/DashBoard/DashBoard.dart';
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
  int _selectedValue = 1;


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
          MaterialPageRoute(builder: (context) => DashBoard()),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: _buildTop(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottom(),
          ),
        ],
      ),
    );
  }

  Widget _buildTop() {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Image.asset(
        'assets/images/login.gif',
        fit: BoxFit
            .cover, // Use BoxFit.cover to ensure the image covers the entire area
        width: double
            .infinity, // Ensure the image takes the full width of the container
      ),
    );
  }

  Widget _buildBottom() {
    return Container(
      width: double.infinity,
      height: 600, // Adjust height based on screen size
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(21),
            topLeft: Radius.circular(21),
          ),
          border:Border.all(width: 1 , color:Colors.deepPurple)
      ),
      child: Column(
        children: [
          SizedBox(height:40),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Welcome Back",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.indigo,)),
              ),
              _welcomeGif(),
            ],),
          ),
          Center(child: _buildLoginForm(),),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items with space between
              children: [
                // Expanded(
                //   child: Row(
                //     children: [
                //       Radio(
                //         value: 1,
                //         groupValue: _selectedValue, // The selected value for the radio group
                //         onChanged: (int? value) {
                //           setState(() {
                //             _selectedValue = value!;
                //           });
                //         },
                //       ),
                //       Text(
                //         "Remember Me", // Text next to the radio button
                //         style: TextStyle(fontSize: 16),
                //       ),
                //     ],
                //   ),
                // ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              getCredentials();
                            });
                          },
                          child: Text(
                            "Log In",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5), // Box-shaped with no rounded corners
                            ),
                          )
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Material(
        elevation: 20,
        color: Colors.white,
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: Colors.white),
        ),
        child: Container(
          height: 300,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Login", style:TextStyle(fontSize: 25 , fontWeight: FontWeight.bold ,)),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30), // Circular borders
                        borderSide: BorderSide.none, // No border initially
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30), // Circular focus border
                        borderSide: BorderSide(color: Colors.blue, width: 2), // Blue focus border
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30), // Circular enabled border
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1), // Light grey enabled border
                      ),
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
                          color: Colors.black,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                      prefixIcon: Icon(Icons.lock),
                      labelText: 'Password',
                      fillColor: Colors.white12,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30), // Circular borders
                        borderSide: BorderSide.none, // No border initially
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30), // Circular focus border
                        borderSide: BorderSide(color: Colors.blue, width: 2), // Blue focus border
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30), // Circular enabled border
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1), // Light grey enabled border
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _welcomeGif(){
    return Container(
      height: 100,

      child: Image.asset(
        'assets/images/welcome.gif',
        fit: BoxFit.fill, // Use BoxFit.cover to ensure the image covers the entire area
      ),
    );
  }
}

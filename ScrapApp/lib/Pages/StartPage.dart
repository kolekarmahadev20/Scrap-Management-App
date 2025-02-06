import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:scrapapp/DashBoard/DashBoard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../URL_CONSTANT.dart';
import 'dart:math' as math;
import 'package:device_info_plus/device_info_plus.dart';
import 'ProfilePage.dart';


class StartPage extends StatefulWidget {
  @override
  State<StartPage> createState() => _StartDashBoardPageState();
}

class _StartDashBoardPageState extends State<StartPage> {
  // TextEditingController usernameController = TextEditingController(text: "bhag2368");
  // TextEditingController passwordController = TextEditingController(text : "Bhag@2368");
  // TextEditingController usernameController = TextEditingController(text: "paar9044");
  // TextEditingController passwordController = TextEditingController(text: "Paar@9044");
  TextEditingController usernameController = TextEditingController(text: "Bantu");
  TextEditingController passwordController = TextEditingController(text: "Bantu#123");
  bool _obscureText = true; // Variable to manage password visibility

  late Timer _gpsCheckTimer;


  final Location _location = Location();
  LocationData? _previousLocation;


  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }


  @override
  void initState() {
    super.initState();
    _getDeviceInfo();

    _gpsCheckTimer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      getlocation();
      _updateLocation();
    });

  }

  @override
  void dispose() {
    _gpsCheckTimer.cancel();
    super.dispose();
  }

  String? _deviceID;


  Future<void> _getDeviceInfo() async {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      try {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        setState(() {
          _deviceID = androidInfo.id!;
          print("_deviceID");

          print(_deviceID);

        });

        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // await prefs.setString("uuid", _deviceID);

      } catch (e) {
        print('Error getting device info: $e');
      }
    });
  }

  Location location = new Location();
  bool _serviceEnabled = true;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  Future<dynamic> getlocation() async {
    _serviceEnabled = await location.serviceEnabled();

    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }
      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
    }
    _locationData = await location.getLocation();
  }

  // Haversine formula to calculate distance between two coordinates
  double degToRad(double deg) {
    return deg * (math.pi / 180);
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const int R = 6371000; // Earth radius in meters
    double dLat = degToRad(lat2 - lat1);
    double dLon = degToRad(lon2 - lon1);
    double a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(degToRad(lat1)) * math.cos(degToRad(lat2)) * math.pow(math.sin(dLon / 2), 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  Future<void> updateLocation(double latitude, double longitude) async {
    print("=== Starting updateLocation Function ===");
    print("Username: ${usernameController.text}");
    print("Password: ${passwordController.text}");
    print("Latitude: $latitude");
    print("Longitude: $longitude");

    try {
      // Construct the API URL
      final url = '${URL}update_location';
      print("API URL: $url");

      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        body: {
          'user_id': usernameController.text,
          'user_pass': passwordController.text,
          'locations[lat]': latitude.toString(),
          'locations[long]': longitude.toString(),
        },
      );

      // Debug response status
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      // Handle the response
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print("Decoded Response: $responseData");

        if (responseData['status'] == "1") {
          print("Success: ${responseData['msg']}");
        } else {
          print("Failed: ${responseData['msg']}");
        }
      } else {
        print("Failed to update location. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception occurred: $e");
    }

    print("=== End of updateLocation Function ===");
  }

  void _updateLocation() async {
    try {
      if (_locationData != null) {
        double latitude = _locationData!.latitude!;
        double longitude = _locationData!.longitude!;

        // Calculate the distance from the previous location, if available
        if (_previousLocation != null) {
          double previousLat = _previousLocation!.latitude!;
          double previousLong = _previousLocation!.longitude!;
          double distance = calculateDistance(previousLat, previousLong, latitude, longitude);

          // Check if the calculated distance is greater than or equal to the desired threshold
          if (distance >= 5000) {
            // Update the location only if the condition is satisfied
            await updateLocation(latitude, longitude);

            // Update the previous location
            _previousLocation = _locationData;
          }
        } else {
          // If previous location is not available, update the location
          await updateLocation(latitude, longitude);

          // Update the previous location
          _previousLocation = _locationData;
        }
      }
    } catch (e) {
      print('Error updating location: $e');
    }
  }

/*---------------------------------------------------------------------------------------------------------------*/
// Function to save user data
  Future<void> saveUserData(bool isLoggedIn ,String name, String contact, String email, String empCode, String address, String person_id,String uuid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
    await prefs.setString('name', name);
    await prefs.setString('contact', contact);
    await prefs.setString('email', email);
    await prefs.setString('empCode', empCode);
    await prefs.setString('address', address);
    await prefs.setString('person_id', person_id);
    prefs.setString("uuid", uuid!);
  }

/*---------------------------------------------------------------------------------------------------------------*/
  checkLogin(String username , String password , String loginType,String userType,
      String person_email, String person_name,String uuid)async{
    final login = await SharedPreferences.getInstance();
    await login.setString("username", username);
    await login.setString("password", password);
    await login.setString("loginType", loginType);
    await login.setString("userType", userType);
    await login.setString("person_email", person_email);
    await login.setString("person_name", person_name);
    await login.setString("uuid", uuid!);

  }
/*---------------------------------------------------------------------------------------------------------------*/

  //Api function for Getting login Credentials and setting onto next page
  Future<void> getCredentials() async {
    print("BHASFHASF:$_deviceID");
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
          'uuid':_deviceID
        },
      );

      var jsonData = json.decode(response.body);

      if (jsonData['success'] == true) {

        var user_data = jsonData['session_data'] ?? "N?A";
        // Access fields using keys
        var person_id = user_data['person_id']?? "N?A";
        var person_name = user_data['user_name']?? "N?A";
        var person_email = user_data['user_type'] == 'S'
            ? user_data['user_email'] ?? "N/A"
            : user_data['user_email'] ?? "N/A";
        var emp_code = user_data['emp_code']?? "N?A";
        var emp_address = user_data['user_add']?? "N?A";
        var contact = user_data['Mobile']?? "N?A";
        var loginType = user_data['login_type']?? "N?A";
        var userType = user_data['user_type']?? "N?A";

        await saveUserData(true ,person_name, contact, person_email, emp_code, emp_address,person_id,_deviceID!);
        await checkLogin(username, password ,loginType ,userType,person_email,person_name,_deviceID!);

        if (userType == "S") {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashBoard(currentPage: 1))
          );
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(currentPage: 2))
          );
        }

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => ProfilePage(currentPage: 2,)),
        // );

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
          _buildTop(),
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
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Image.asset(
          'assets/images/pic.png',
          fit: BoxFit.fill, // Use BoxFit.cover to ensure the image covers the entire area
        ),
      ),
    );
  }

  Widget _buildBottom() {
    return ClipPath(
      clipper: BottomCurveClipper(), // Apply custom clipper for the bottom widget
      child: Container(
        height: 600, // Explicit height for the bottom container
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1, color: Colors.black12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0), // Add top padding for space
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Uncomment the welcome message and gif to see the changes
              // Padding(
              //   padding: const EdgeInsets.all(20.0),
              //   child: Text(
              //     "Welcome Back",
              //     style: TextStyle(
              //         fontSize: 30,
              //         fontWeight: FontWeight.bold,
              //         color: Colors.blueGrey[700]),
              //   ),
              // ),

              Expanded(
                child: Center(
                  child: _buildLoginForm(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50, // Adjust the height of the button as needed
                  child: ElevatedButton(
                    onPressed: () {
                      _updateLocation();

                      getCredentials();
                    },
                    child: Text(
                      "Log In",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Material(
        elevation: 50,
        color: Colors.white,
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: Colors.white),
        ),
        child: Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
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
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey), // Color for normal state
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue), // Color when focused
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey), // Color when enabled
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
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey), // Color for normal state
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue), // Color when focused
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey), // Color when enabled
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
class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // Start from the top left
    path.moveTo(0.0, 0.0);

    // Create the curve from the left to the right side
    var firstControlPoint = Offset(size.width / 2, 80);
    var firstEndPoint = Offset(size.width, 0.0);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    // Draw a line down the right side
    path.lineTo(size.width, size.height);

    // Draw a line across the bottom
    path.lineTo(0.0, size.height);

    // Close the path
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
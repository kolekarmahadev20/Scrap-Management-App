import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'URL_CONSTANT.dart';

class LocationService {
  // Singleton implementation
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal() {
    // First load credentials, then start location tracking.
    checkLogin().then((_) {
      _init();
    });
  }

  // Credentials and user data loaded from SharedPreferences
  String? username;
  String? uuid;
  String? password;
  String? loginType;
  String? userType;

  // API URL (update with your actual endpoint)
  final String _apiUrl = '${URL}update_location';

  // Location package instance
  final Location _location = Location();

  // Timer for periodic location checks
  Timer? _gpsCheckTimer;

  // Previous location for distance comparison
  LocationData? _previousLocation;

  // Current location and permission/service status
  late LocationData _locationData;
  bool _serviceEnabled = true;
  late PermissionStatus _permissionGranted;

  /// Loads the user data from SharedPreferences.
  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    // If your keys are repeated, ensure you fetch the right ones.
    uuid = prefs.getString("uuid");
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
    debugPrint("checkLogin: username: $username, uuid: $uuid, password: $password");
  }

  /// Initializes the periodic timer for location updates.
  void _init() {
    _gpsCheckTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      await _getLocation();
      await _updateLocation();
    });
  }

  /// Checks for service/permission and then obtains the current location.
  Future<void> _getLocation() async {
    _serviceEnabled = await _location.serviceEnabled();

    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        debugPrint('Location service is not enabled.');
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        debugPrint('Location permission not granted.');
        return;
      }
    }

    try {
      _locationData = await _location.getLocation();
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  /// Converts degrees to radians.
  double _degToRad(double deg) {
    return deg * (math.pi / 180);
  }

  /// Calculates the distance between two coordinates using the Haversine formula.
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const int R = 6371000; // Earth's radius in meters
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);
    double a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_degToRad(lat1)) * math.cos(_degToRad(lat2)) * math.pow(math.sin(dLon / 2), 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  /// Checks if the new location is sufficiently far from the previous one and sends an update if so.
  Future<void> _updateLocation() async {
    if (_locationData == null) return;

    double latitude = _locationData.latitude!;
    double longitude = _locationData.longitude!;

    if (_previousLocation != null) {
      double previousLat = _previousLocation!.latitude!;
      double previousLon = _previousLocation!.longitude!;
      double distance = _calculateDistance(previousLat, previousLon, latitude, longitude);

      // Update only if the distance is greater than or equal to 5000 meters
      if (distance >= 5000) {
        await _sendLocationUpdate(latitude, longitude);
        _previousLocation = _locationData;
      }
    } else {
      // First update (no previous location exists)
      await _sendLocationUpdate(latitude, longitude);
      _previousLocation = _locationData;
    }
  }

  /// Sends the location update to the backend API using the credentials loaded from SharedPreferences.
  Future<void> _sendLocationUpdate(double latitude, double longitude) async {
    debugPrint("=== Starting updateLocation Function ===");
    debugPrint("Username: $username");
    debugPrint("Password: $password");
    debugPrint("UUID: $uuid");
    debugPrint("Latitude: $latitude");
    debugPrint("Longitude: $longitude");
    debugPrint("API URL: $_apiUrl");

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        body: {
          'user_id': username ?? '',
          'user_pass': password ?? '',
          'uuid': uuid ?? '',
          'locations[lat]': latitude.toString(),
          'locations[long]': longitude.toString(),
        },
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == "1") {
          debugPrint("Success: ${responseData['msg']}");
        } else {
          debugPrint("Failed: ${responseData['msg']}");
        }
      } else {
        debugPrint("Failed to update location. Status code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Exception occurred while sending location: $e");
    }

    debugPrint("=== End of updateLocation Function ===");
  }

  /// Call this method when you no longer need the location updates.
  void dispose() {
    _gpsCheckTimer?.cancel();
  }
}

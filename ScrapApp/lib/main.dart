import 'package:flutter/material.dart';
import 'package:scrapapp/Pages/splashScreen.dart';
import 'LocationService.dart';
import 'Internet_Connection/ConnectionOverlay.dart';
import 'Internet_Connection/ConnectivityService.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // ✅ Start connectivity monitoring
  ConnectivityService().initialize();
  // ✅ Start location service
  LocationService();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scrap Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          color: Colors.indigo[800],
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: SplashScreen(),

      /// ✅ Add the overlay here to ensure Directionality exists
      builder: (context, child) {
        return ConnectionOverlay(child: child!);
      },
    );
  }
}
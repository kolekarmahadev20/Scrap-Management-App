import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'LocationService.dart';
import 'Internet_Connection/ConnectionOverlay.dart';
import 'Internet_Connection/ConnectivityService.dart';
import 'Pages/splashScreen.dart';

void main() async {

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

      // ✅ Add connectivity overlay without breaking UI
      builder: (context, child) {
        return ConnectionOverlay(child: child!);
      },
    );
  }
}

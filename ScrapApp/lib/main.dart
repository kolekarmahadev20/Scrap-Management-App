import 'package:flutter/material.dart';
import 'package:scrapapp/Pages/StartPage.dart';

import 'LocationService.dart';
import 'Pages/splashScreen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Start the LocationService (credentials are loaded and tracking begins)
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
            iconTheme:IconThemeData(color: Colors.white),
          ),
        ),
        home:SplashScreen()
    );
  }
}

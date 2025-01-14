import 'package:flutter/material.dart';
import 'package:inventaris/Screens/Welcome/welcome_screen.dart';
import 'package:inventaris/constants.dart';
import 'package:inventaris/pages/body.dart';
import 'package:inventaris/pages/login.dart';
import 'package:inventaris/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventaris',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      // home: WelcomeScreen(),
      home: loginScreen(),
      // home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

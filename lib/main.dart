import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';
import 'calibration_screen.dart';
import 'email_signin_screen.dart';
import 'tab_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    title: 'Size Adviser',
    // Start the app with the "/" named route. In this case, the app starts
    // on the StartScreen widget.
    initialRoute: '/',
    routes: {
      // When navigating to the "/" route, build the StartScreen widget.
      '/': (context) => StartScreen(),
      // When navigating to the "/calibration" route, build the CalibrationScreen widget.
      '/calibration': (context) => CalibrationScreen(),
      '/email-signin': (context) => EmailSignInScreen(),
      '/tab-screen': (context) => TabScreen()
    },
  ),
  );
}


class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    new Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushNamed(context, '/calibration');
    });

    return Scaffold(
      body: Center(
        child: Column (
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
          Text(
              "SIZE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 55
              ),
          ),
          Text(
              "adviser",
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                letterSpacing: 6
              ),
          ),
        ],
        )
      ),
      backgroundColor: sa_blue,
    );
  }
}
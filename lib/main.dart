import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:size_adviser/auth_main_screen.dart';
import 'package:size_adviser/new_brand.dart';
import 'package:size_adviser/show_zoomed_of.dart';
import 'package:size_adviser/colors.dart';
import 'package:size_adviser/calibration_screen.dart';
import 'package:size_adviser/email_signin_screen.dart';
import 'package:size_adviser/tab_screen.dart';
import 'package:size_adviser/take_picture.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  await Firebase.initializeApp();

  await Settings.init();

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
      '/signin-main': (context) => AuthMainScreen(),
      '/email-signin': (context) => EmailSignInScreen(),
      '/email-signup': (context) => EmailSignUpScreen(),
      '/final-signin': (context) => FinalSignUpScreen(),
      '/tab-screen': (context) => TabScreen(),
      '/zoomed-of': (context) => ZoomedOfScreen(),
      '/new-brand': (context) => NewBrandScreen(),
      '/take-picture': (context) => TakePictureScreen(camera: firstCamera),
      '/settings': (context) => SettingsScreen(
        children: [
          TextInputSettingsTile(
            title: 'User name',
            settingKey: 'profile_user_name',
            initialValue: "John Johnson",
            validator: (String username) {
              if (username != null && username != "") {
                return null;
              }
              return "User name cannot be empty!";
            },
            borderColor: sa_blue,
            errorColor: palettePink,
            onChange: (String value) async {
              await FirebaseAuth.instance.currentUser!.updateProfile(
                displayName: value
              );
            },
          ),
          RadioSettingsTile<String>(
            title: 'Gender',
            settingKey: 'profile_gender',
            values: <String, String>{
              "0": "Male",
              "1": "Female"
            },
            selected: "1",
            onChange: (value) {
              debugPrint('profile_default_standard: $value');
            },
          ),
          RadioSettingsTile<String>(
            title: 'Default system',
            settingKey: 'profile_default_standard',
            values: <String, String>{
              "UK": "UK",
              "US": "US",
              "RU": "RU",
              "Cm": "Cm",
              "EU": "EU"
            },
            selected: "RU",
            onChange: (value) {
              debugPrint('profile_default_standard: $value');
            },
          )
        ]
      )
    },
  ),
  );
}


class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    new Future.delayed(const Duration(seconds: 3), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? gotGender = prefs.getInt("userGender");
      if (gotGender == null) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/calibration', (Route<dynamic> route) => false);
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/tab-screen', (Route<dynamic> route) => false);
      }
      //Navigator.pushReplacementNamed(context, '/calibration');
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
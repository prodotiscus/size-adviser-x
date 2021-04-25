import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';

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
      '/email-signin': (content) => EmailSignInScreen(),
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

class CalibrationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.pushReplacementNamed(context, '/email-signin');
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Size Adviser"),
        backgroundColor: sa_blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Text(
                "Welcome!",
                style: TextStyle(
                  color: sa_blue,
                  fontSize: 30,
                ),
              ),
              margin: EdgeInsets.only(bottom: 25.0),
            ),
            Text(
              "To recommend sizes we need to calibrate your profile.",
              style: TextStyle(
                fontSize: 16
              ),
              textAlign: TextAlign.center,
            ),
            Container(
              child: Text(
                "Choose your gender",
                style: TextStyle(
                  fontSize: 16
                )
              ),
              margin: EdgeInsets.only(top: 50.0, bottom: 10.0)
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {  },
                  child: Text(
                    "MALE",
                    style: TextStyle(
                      color: Colors.black
                    )
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white54)
                  ),
                ),
                ElevatedButton(
                  onPressed: () {  },
                  child: Text(
                      "FEMALE",
                      style: TextStyle(
                          color: Colors.black,
                      )
                  ),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white54),
                  ),
                  width
                ),
              ],
            ),
            Text(
                "Please try at least 5 pairs of shoes of different popular brands.",
                textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: () {  },
              child: Text("OK, I understand")
            )
          ],
        )
      )
    );
  }
}

class EmailSignInScreen extends StatefulWidget {
  @override
  _EmailSignInScreenState createState() => _EmailSignInScreenState();
}

class _EmailSignInScreenState extends State<EmailSignInScreen> {
  bool _invalid_ep = false;
  final emailController = TextEditingController();
  final pwdController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    pwdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> send_signin_data() async {
      setState(() {
        _invalid_ep = false;
      });
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailController.text,
            password: pwdController.text
        );
        Navigator.pushReplacementNamed(context, '/calibration');
      } on FirebaseAuthException catch (e) {
        // TODO: may use different 'e.code' values
        setState(() {
          _invalid_ep = true;
        });
      }
    }

    return Scaffold(
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Email'
                ),
                controller: emailController,
              ),
              TextFormField(
                decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Password',
                ),
                controller: pwdController,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
              ),
              ElevatedButton(
                // Within the CalibrationScreen widget
                onPressed: send_signin_data,
                child: Text("Sign In"),
              ),
              if (_invalid_ep) Text(
                "Invalid e-mail or password",
                style: TextStyle(
                  color: Colors.red
                ),
              )
            ]
          )
      )
    );
  }
}
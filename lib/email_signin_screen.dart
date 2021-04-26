import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';

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
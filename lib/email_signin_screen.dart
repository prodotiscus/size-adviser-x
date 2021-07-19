import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'authentication.dart';
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

  void signInOperation () {
    return;
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
        setState(() {
          _invalid_ep = true;
        });
      }
    }

    return Scaffold(
        appBar: AppBar(
            title: Text("Sign in using e-mail"),
            backgroundColor: sa_blue
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                      "Sign in and go.",
                      style: TextStyle(
                          color: darkerGray,
                          fontSize: 35.0
                      )
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: "Email"
                        ),
                        controller: emailController,
                      )
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 30.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: "Password",
                        ),
                        controller: pwdController,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                      )
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 10.0),
                      width: 300.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: sa_blue,
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(0.0))
                          ),
                        ),
                        onPressed: signInOperation,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  "SIGN IN",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0
                                  )
                              ),
                            ]
                        ),
                      )
                  ),
                  if (_invalid_ep) Text(
                    "Invalid e-mail or password",
                    style: TextStyle(
                        color: Colors.red
                    ),
                  ),
                  Container(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(
                            fontSize: 20,
                          color: holoBlueLight
                        ),
                      ),
                      onPressed: () {},
                      child: const Text('Forgot password?'),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 20.0)
                  ),
                  Container(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(
                              fontSize: 20,
                              color: holoBlueLight
                          ),
                        ),
                        onPressed: () {},
                        child: const Text("Don't have an account? Sign up"),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 20.0)
                  )
                ]
            )
        )
    );
  }
}
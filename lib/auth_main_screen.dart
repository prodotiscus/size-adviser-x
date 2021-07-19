import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'authentication.dart';
import 'colors.dart';

class AuthMainScreen extends StatefulWidget {
  @override
  _AuthMainScreenState createState() => _AuthMainScreenState();
}

class _AuthMainScreenState extends State<AuthMainScreen> {
  var _email_controller = TextEditingController();
  String email = "";

  void proceedToEmailLogin () {
    if (email == "") return;

    Navigator.pushNamed(context,
      "/email-signin", arguments: EmailLoginArguments(email));
  }

  void googleSignIn() async {
    await signInWithGoogle();
    Navigator.pushReplacementNamed(context, '/calibration');
  }

  void fbSignIn() async {
    await signInWithFacebook();
    Navigator.pushReplacementNamed(context, '/calibration');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome to Size Adviser!"),
        backgroundColor: sa_blue
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Please sign in.",
              style: TextStyle(
                color: darkerGray,
                fontSize: 30.0
              )
            ),
            Container(
              margin: EdgeInsets.only(top: 25.0),
              width: 300.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0.0))
                  ),
                  elevation: 0
                ),
                onPressed: fbSignIn,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(
                        "images/fb_button_logo.png",
                      width: 48,
                      height: 48
                    ),
                    Text(
                      "SIGN IN WITH FACEBOOK",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0
                      )
                    )
                  ]
                ),
              )
            ),
            Container(
                margin: EdgeInsets.only(top: 10.0),
                width: 300.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(0.0))
                      ),
                      elevation: 0
                  ),
                  onPressed: googleSignIn,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Image.asset(
                            "images/google_button_logo.png",
                            width: 48,
                            height: 48
                        ),
                        Text(
                            "SIGN IN WITH GOOGLE    ",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0
                            )
                        ),
                      ]
                  ),
                )
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                "or",
                style: TextStyle(
                  color: darkerGray
                )
              )
            ),
            Container(
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: _email_controller,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'email',
                  labelStyle: TextStyle(
                    color: sa_blue,
                  ),
                  hintText: "e. g. john@example.com",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                onChanged: (text) {
                  setState(() {
                    email = text;
                  });
                },
              ),
              margin: EdgeInsets.symmetric(horizontal: 60.0)
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
                  onPressed: proceedToEmailLogin,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            "NEXT",
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
          ],
        )
      )
    );
  }
}

class EmailLoginArguments {
  String email;

  EmailLoginArguments(this.email);
}
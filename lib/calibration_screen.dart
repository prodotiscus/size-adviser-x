import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';

class CalibrationScreen extends StatefulWidget {
  @override
  _CalibrationScreenState createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  int genderSelected = -1;
  bool agreement = false;

  void selectGenderByClick(int genderValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("profile_gender", genderValue.toString());
    setState(() {
      genderSelected = genderValue;
    });
  }
  
  void agree () {
    setState(() {
      agreement = true;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Future.delayed(Duration.zero, () {
      print(FirebaseAuth.instance.currentUser);
      print(genderSelected);
      print(agreement);
      if (FirebaseAuth.instance.currentUser == null) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/signin-main', (Route<dynamic> route) => false);
      }
      else if (genderSelected != -1 && agreement) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/tab-screen', (Route<dynamic> route) => false);
      }
    });

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
                    margin: EdgeInsets.only(top: 150.0, bottom: 10.0)
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        child: SizedBox(
                            width: 150.0,
                            height: 40.0,
                            child: ElevatedButton(
                              onPressed: () { selectGenderByClick(0); },
                              child: Text(
                                  "MALE",
                                  style: TextStyle(
                                      color: Colors.black
                                  )
                              ),
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(genderSelected != 0 ? paletteLightGray: colorAccent),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                      )
                                  )
                              ),
                            )
                        ),
                        margin: EdgeInsets.only(right: 25.0)
                    ),
                    SizedBox(
                        width: 150.0,
                        height: 40.0,
                        child: ElevatedButton(
                          onPressed: () { selectGenderByClick(1); },
                          child: Text(
                              "FEMALE",
                              style: TextStyle(
                                color: Colors.black,
                              )
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(genderSelected != 1 ? paletteLightGray: colorAccent),
                          ),
                        )
                    ),
                  ],
                ),
                Container(
                  child: Text(
                    "Please, try on at least 5 pairs of shoes of different popular brands.",
                    style: TextStyle(
                      fontSize: 16
                    ),
                    textAlign: TextAlign.center,
                  ),
                  margin: EdgeInsets.only(top: 100.0, bottom: 25.0),
                ),
                SizedBox(
                    width: 150.0,
                    height: 40.0,
                    child: ElevatedButton(
                      onPressed: agree,
                      child: Text(
                          "Ok I understand",
                          style: TextStyle(
                            color: Colors.black,
                          )
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(!agreement ? paletteLightGray: colorAccent),
                      ),
                    )
                ),
              ],
            )
        )
    );
  }
}
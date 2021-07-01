import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';

class MyCollectionScreen extends StatefulWidget {
  @override
  _MyCollectionScreenState createState() => _MyCollectionScreenState();
}

class _MyCollectionScreenState extends State<MyCollectionScreen> {
  @override
  Widget build(BuildContext context) {
    registerUser();

    return Scaffold(
      body: Center(
          child: Column (
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "MY COLLECTION",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 55
                ),
              ),
            ],
          )
      ),
    );
  }

  void registerUser() async {
    var spf = await SharedPreferences.getInstance();
    var api = SizeAdviserApi();
    //api.registerCurrentUser(spf);
    api.boundLoadFittingData(spf, "Adidas", (b) => null);
  }
}
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
  List<Widget> col = [];
  bool collectionLoaded = false;

  @override
  Widget build(BuildContext context) {
    registerUser();
    if (!collectionLoaded) {
      loadCollection();
      collectionLoaded = true;
    }

    return Scaffold(
      body: Center(
          child: Column (
            children: <Widget>[
              const Divider(
                height: 20,
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              Row (
                mainAxisAlignment: MainAxisAlignment.start, //change here don't //worked
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      child: Align(
                        child: Text(
                          "DETAILS"
                        ),
                      ),
                      margin: EdgeInsets.only(left: 20.0),
                  ),
                  new Spacer(),
                  Align(
                      child: Text(
                        "size"
                      )
                  ),
                  new Spacer(),
                  Container(
                    child: Align(
                      child: Text(
                          "fit"
                      ),
                    ),
                    margin: EdgeInsets.only(right: 20.0),
                  ),
                ],
              ),
              const Divider(
                height: 20,
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              Column(
                children: (() {
                  if (col.isEmpty) {
                    return <Widget>[];
                  } else {
                    return col;
                  }
                })()
              )
            ],
          )
      ),
    );
  }

  void loadCollection() async {
    var spf = await SharedPreferences.getInstance();
    var api = SizeAdviserApi();
    var col2 = await api.getCollection(spf);

    setState(() {
      col = <Widget>[
        Text("Number of items: " + col2.length.toString()),
        Text("B"),
        Text("C")
      ];
    });
  }

  void registerUser() async {
    var spf = await SharedPreferences.getInstance();
    var api = SizeAdviserApi();
    //api.registerCurrentUser(spf);
    api.boundLoadFittingData(spf, "Adidas", (b) => null);
  }
}
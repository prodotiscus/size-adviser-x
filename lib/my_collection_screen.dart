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
              SingleChildScrollView(
              child: Column(
                children: (() {
                  if (col.isEmpty) {
                    return <Widget>[];
                  } else {
                    return col;
                  }
                })()
              ))
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
      var c = <Widget>[];
      for (var item in col2) {
        c.add(itemCard(item));
      }
      col = c;
    });
  }
  
  Widget defMargin(Widget w) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      child: w
    );
  }

  Text fitValueColored(int fitValue) {
    String? w = null;
    Color? c = null;

    switch(fitValue) {
      case 1: {
        w = "1 SIZE DOWN";
        c = Colors.red;
      }
      break;
      case 2: {
        w = "TOO SMALL";
        c = Colors.orange;
      }
      break;
      case 3: {
        w = "IDEAL";
        c = Colors.green;
      }
      break;
      case 4: {
        w = "TOO BIG";
        c = Colors.orange;
      }
      break;
      case 5: {
        w = "1 SIZE UP";
        c = Colors.red;
      }
      break;
    }
    return Text(w!, style:TextStyle(color: c!));
  }

  Widget itemCard(CollectionItem item) {
    return Center(
      child: Card(
        child: Column(
          children: <Widget>[
            defMargin(Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                new Text(item.date),
                new Text(item.standard),
              ],
            )),
            defMargin(
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  new Text(item.brand, style: TextStyle(fontWeight: FontWeight.bold)),
                  new Text(item.size, style: TextStyle(fontWeight: FontWeight.bold)),
                  fitValueColored(item.fitValue)
                ]
              )
            )
          ],
        )
      )
    );
  }

  void registerUser() async {
    var spf = await SharedPreferences.getInstance();
    var api = SizeAdviserApi();
    //api.registerCurrentUser(spf);
    api.boundLoadFittingData(spf, "Adidas", (b) => null);
  }
}
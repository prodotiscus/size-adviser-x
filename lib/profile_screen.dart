import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:scroll_snap_list/scroll_snap_list.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final searchController = TextEditingController();
  final lrMarginValue = 20.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column (
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ClipOval(
                child: Image.network(
                  'https://via.placeholder.com/150',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                child: Text(
                  "Personal name",
                  style: TextStyle(
                      fontSize: 15
                  ),
                ),
                margin: EdgeInsets.only(top: 10.0),
              ),
              Container(
                child: TextFormField(
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'search'
                  ),
                  controller: searchController,
                ),
                margin: EdgeInsets.only(left: lrMarginValue, right: lrMarginValue),
              ),
              Container(
                child: const Divider(
                  height: 20,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                  color: Colors.black,
                ),
              ),
            ],
          )
      ),
    );
  }
}
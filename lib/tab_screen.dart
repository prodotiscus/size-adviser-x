import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:size_adviser/colors.dart';

class TabScreen extends StatefulWidget {
  TabScreen({Key? key}) : super(key: key);

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: <Widget>[
              Expanded(
                child: TabBarView(
                  children: <Widget>[
                    Center(
                      child: Icon(Icons.directions_car),
                    ),
                    Center(
                      child: Icon(Icons.directions_transit),
                    ),
                    Center(
                      child: Icon(Icons.directions_bike),
                    ),
                  ],
                ),
              ),
              ButtonsTabBar(
                backgroundColor: paletteLightGray,
                unselectedBackgroundColor: paletteLightGray,
                unselectedLabelStyle: TextStyle(color: Colors.black),
                labelStyle:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                tabs: [
                  Tab(
                    child: Container(
                      child: Text(
                        "PROFILE",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black
                        )
                      ),
                      width: 120.0
                    ),
                  ),
                  Tab(
                    child: Container(
                        child: Text(
                          "FITTING ROOM",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black
                          )
                        ),
                        width: 120.0
                    ),
                  ),
                  Tab(
                    child: Container(
                        child: Text(
                          "MY COLLECTION",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black
                          )
                        ),
                        width: 120.0
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
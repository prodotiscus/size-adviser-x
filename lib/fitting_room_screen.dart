import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:size_adviser/api.dart';
import 'package:size_adviser/colors.dart';

class FittingRoomScreen extends StatefulWidget {
  @override
  _FittingRoomScreenState createState() => _FittingRoomScreenState();
}

class BrandOptionSelector {
  final String selectedBrand;
  final List<String> allBrands;

  BrandOptionSelector(this.selectedBrand, this.allBrands);

  String get capsSelected => this.selectedBrand.toUpperCase();
  List<String> get capsAllBrands => this.allBrands.map(
     (String s) {
       return s.toUpperCase();
     }
  ).toList();
}

class FitController {
  String? brand;
  List<Standard>? standardObj;
  String? fittingID;

  FitController (String brand, List<Standard> standardObj) {
    this.brand = brand;
    this.standardObj = standardObj;

    var rnd = new Random();
    var next = rnd.nextDouble() * 1000000;
    while (next < 100000) {
      next *= 10;
    }
    this.fittingID = next.toInt().toString();
  }

  List<String> get standards => this.standardObj!.map((Standard el) => el.name).toList();
}

class _FittingRoomScreenState extends State<FittingRoomScreen> {
  double defaultFontSize = 16.0;
  String selectedBrand = "Adidas";
  var api = SizeAdviserApi();
  Widget? recommendations = null;
  BrandOptionSelector? optionSelector = null;

  Widget produceRecommendationWidget(List<Recommendation> lst) {
    List<Widget> listForRow = [];
    for (var recom in lst) {
      listForRow.add(
        Container(
          width: 65.0,
          padding: EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 5.0
          ),
          color: sa_blue,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                recom.standard,
                style: TextStyle(
                  color: Colors.white
                )
              ),
              Text(
                recom.value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0
                )
              )
            ]
          )
        )
      );
    }
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: listForRow
      ),
      margin: EdgeInsets.symmetric(horizontal: 20.0)
    );
  }

  void loadBoundData() async {
    var spf = await SharedPreferences.getInstance();
    var data = await api.boundLoadFittingData(spf, selectedBrand);
    setState(() {
      recommendations = produceRecommendationWidget(data.recommendation.recommendations);
      optionSelector = BrandOptionSelector(selectedBrand, data.brandsList.list);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (recommendations == null) {
      loadBoundData();
    }

    return Scaffold(
      body: Center(
          child: Column (
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Text(
                  "choose brand",
                  style: TextStyle(
                    fontSize: defaultFontSize
                  )
                ),
                margin: EdgeInsets.symmetric(vertical: 20.0),
              ),
              if(optionSelector != null) Container(
                margin: EdgeInsets.symmetric(horizontal: 20.0),
                width: 350.0,
                child: DropdownButton<String>(
                  isExpanded: true,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(
                      color: sa_blue,
                      fontSize: 20.0
                    ),
                    underline: Container(
                      height: 2,
                      color: sa_blue,
                    ),
                    value: optionSelector!.capsSelected,
                    items: optionSelector!.capsAllBrands.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                    onChanged: (_) {},
                  )
              ),
              Container(
                child: Text(
                    "size recommendation",
                    style: TextStyle(
                        fontSize: defaultFontSize
                    )
                ),
                margin: EdgeInsets.only(top: 10.0)
              ),
              if (recommendations != null) Center(
                child: Container(
                  child: recommendations!,
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                )
              ),
              Container(
                child: Text(
                    "I am trying size",
                    style: TextStyle(
                        fontSize: defaultFontSize
                    )
                ),
                margin: EdgeInsets.symmetric(vertical: 10.0),
              ),
              const Divider(
                height: 20,
                thickness: 1,
                indent: 15,
                endIndent: 15,
              ),
            ],
          )
      ),
    );
  }
}
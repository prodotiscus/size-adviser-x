import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
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
  String? selectedStandard;
  String? selectedSize;
  int? fitValue;

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

  List<String>? getSelectedRange() {
    for (var subobj in this.standardObj!) {
      if (subobj.name == this.selectedStandard) return subobj.sizes;
    }
    return null;
  }
}

class _FittingRoomScreenState extends State<FittingRoomScreen> {
  double defaultFontSize = 16.0;
  String selectedBrand = "Adidas";
  var api = SizeAdviserApi();
  Widget? recommendations = null;
  BrandOptionSelector? optionSelector = null;
  int _standards_index = 0;
  int _sizes_index = 0;
  FitController? fitController = null;
  var standardsController = PageController(
      viewportFraction: 0.2
  );
  var sizesController = PageController(
      viewportFraction: 0.2
  );

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

  String? getCurrentRecommended(List<Recommendation> lst, String standard) {
    var mySize = null;
    for (var rec in lst) {
      if (rec.standard == standard) {
        mySize = rec.value;
      }
    }
    return mySize;
  }

  void loadBoundData() async {
    var spf = await SharedPreferences.getInstance();
    var data = await api.boundLoadFittingData(spf, selectedBrand);
    setState(() {
      recommendations = produceRecommendationWidget(data.recommendation.recommendations);
      optionSelector = BrandOptionSelector(selectedBrand, data.brandsList.list);
      fitController = new FitController(selectedBrand, data.brandData.standards);
      fitController!.selectedStandard = fitController!.standards[0];
      var switchTo = fitController!.getSelectedRange()!.indexOf(
          getCurrentRecommended(
              data.recommendation.recommendations,
              fitController!.selectedStandard!
          )!
      );
      sizesController = PageController(
          viewportFraction: 0.3,
          initialPage: switchTo
      );
      _sizes_index = switchTo;
    });
  }

  Widget standardsScroller() {
    return Container(
        margin: EdgeInsets.only(top: 10.0),
        child: SizedBox(
            height: 50,
            child: PageView.builder(
              itemCount: fitController!.standards.length,
              controller: standardsController,
              onPageChanged: (int index) {
                setState(() {
                  _standards_index = index;
                  fitController!.selectedStandard = fitController!.standards[index];
                });
              },
              itemBuilder: (_, i) {
                return Transform.scale(
                    scale: i == _standards_index ? 1 : 0.8,
                    child: GestureDetector(
                      onTap: () {
                        standardsController.animateToPage(i, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
                      },
                      child: Text(
                        fitController!.standards[i],
                        style: TextStyle(
                            fontSize: 27,
                            color: i == _standards_index ? sa_blue : darkerGray,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    )
                );
              },
            )
        )
    );
  }

  Widget sizesScroller() {
    return Container(
        margin: EdgeInsets.only(top: 10.0),
        child: SizedBox(
            height: 50,
            child: PageView.builder(
              itemCount: fitController!.getSelectedRange()!.length,
              controller: sizesController,
              onPageChanged: (int index) {
                setState(() {
                  _sizes_index = index;
                  fitController!.selectedSize = fitController!.getSelectedRange()![index];
                });
              },
              itemBuilder: (_, i) {
                return Transform.scale(
                    scale: i == _sizes_index ? 1 : 0.8,
                    child: GestureDetector(
                      onTap: () {
                        sizesController.animateToPage(i, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
                      },
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        child: Center(
                            child: Card(
                              elevation: 0,
                              color: Colors.transparent,
                              child: Text(
                                fitController!.getSelectedRange()![i],
                                style: TextStyle(
                                    fontSize: 27,
                                    color: i == _sizes_index ? Colors.black : darkerGray,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                          )
                        )
                      )
                     )
                );
              },
            )
        )
    );
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
                height: 0,
                thickness: 1,
                indent: 15,
                endIndent: 15,
              ),
              if (fitController != null) standardsScroller(),
              const Divider(
                height: 0,
                thickness: 1,
                indent: 15,
                endIndent: 15,
              ),
              if (fitController != null) sizesScroller(),
              const Divider(
                height: 0,
                thickness: 1,
                indent: 15,
                endIndent: 15,
              ),
              Container(
                //color: background,
                child: LayoutGrid(
                  areas: '''
                    sb  Ib bb
                    Nw  .  Ph
                  ''',
                  // A number of extension methods are provided for concise track sizing
                  columnSizes: [100.px, 180.px, 100.px],
                  rowSizes: [
                    300.px
                  ],
                  children: [
                  Center(child:Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 30.0),
                            child:ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              primary: paletteLightGray
                          ),
                          child: Container(
                            width: 80,
                            height: 80,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: Text(
                              'too small',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12.0,
                                  color: sa_blue
                              )
                            ),
                          ),
                          onPressed: () {},
                        )),
                        Container(
                          margin: EdgeInsets.only(top: 15.0),
                            child:ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              primary: paletteLightGray
                          ),
                          child: Container(
                            width: 60,
                            height: 60,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                      "1 size",
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12.0,
                                          color: sa_blue
                                      )
                                  ),
                                  Text(
                                      "DOWN",
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12.0,
                                          color: sa_blue
                                      )
                                  ),
                                ]
                            ),
                          ),
                          onPressed: () {},
                        )),
                      ]
                    )).inGridArea("sb"),
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 30.0, bottom: 20.0),
                            child:ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              primary: idealFitColor
                          ),
                          child: Container(
                            width: 160,
                            height: 160,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: Text(
                              'IDEAL FIT',
                              style: TextStyle(fontSize: 22),
                            ),
                          ),
                          onPressed: () {},)),
                        TextButton(
                          style: TextButton.styleFrom(
                            textStyle: const TextStyle(
                                fontSize: 30,
                              fontWeight: FontWeight.bold
                            ),
                            primary: idealFitColor
                          ),
                          onPressed: () {},
                          child: const Text('GOT IT'),
                        )
                      ]).inGridArea("Ib"),
                    Center(child:Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 30.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              primary: paletteLightGray
                            ),
                            child: Container(
                              width: 80,
                              height: 80,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(shape: BoxShape.circle),
                              child: Text(
                                'too big',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12.0,
                                  color: sa_blue
                                )
                              ),
                            ),
                            onPressed: () {},
                          )
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 15.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            primary: paletteLightGray
                          ),
                          child: Container(
                            width: 60,
                            height: 60,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "1 size",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12.0,
                                    color: sa_blue
                                  )
                                ),
                                Text(
                                  "UP",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12.0,
                                    color: sa_blue
                                  )
                                ),
                                ]
                            ),
                          ),
                          onPressed: () {},
                        ))
                      ]
                    )).inGridArea("bb"),
                  ],
                ),
              ),
            ],
          )
      ),
    );
  }
}
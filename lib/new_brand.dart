import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:size_adviser/api.dart';
import 'package:size_adviser/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'color_loader_4.dart';

class NewBrandScreen extends StatefulWidget {
  @override
  _NewBrandScreenState createState() => _NewBrandScreenState();
}

class BrandOptionSelector {
  String selectedBrand;
  List<String> allBrands;

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
  List<String> standards = ["??"];
  String? fittingID;
  String? selectedStandard;
  String? selectedSize;
  int? fitValue;

  FitController (String brand, List<String> standards) {
    this.brand = brand;
    this.standards = standards;

    var rnd = new Random();
    var next = rnd.nextDouble() * 1000000;
    while (next < 100000) {
      next *= 10;
    }
    this.fittingID = next.toInt().toString();
  }
}

class _NewBrandScreenState extends State<NewBrandScreen> {
  double defaultFontSize = 16.0;
  String selectedBrand = "My new brand";
  var api = SizeAdviserApi();
  Widget? recommendations = null;
  BrandOptionSelector? optionSelector = null;
  int _standards_index = 0;
  FitController? fitController = null;
  var standardsController = PageController(
      viewportFraction: 0.2
  );
  var _controller2 = TextEditingController();
  var _controller3 = TextEditingController();
  bool fitSending = false;
  bool alreadySaved = false;

  Widget produceRecommendationWidget(List<Recommendation> lst) {
    List<Widget> listForRow = [];
    for (var recom in lst) {
      listForRow.add(
          Container(
              width: 75.r,
              padding: EdgeInsets.symmetric(
                  vertical: 10.h,
                  horizontal: 5.r
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
        margin: EdgeInsets.symmetric(horizontal: 20.r)
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

  void loadBoundData() {
    setState(() {
      fitController = new FitController(
          "My new brand",
          api.getAllStandards()
      );
      fitController!.selectedStandard = fitController!.standards[0];
    });
  }

  Widget standardsScroller() {
    return Container(
        margin: EdgeInsets.only(top: 10.h),
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

  void saveFitData () async {
    setState(() {
      fitSending = true;
    });
    print(fitController!.fittingID!);
    print(fitController!.brand!);
    print(fitController!.selectedSize! );
    print(fitController!.selectedStandard! );
    print(fitController!.fitValue!.toString());

    bool tResult = await api.tryWithSize(
        fitController!.fittingID!,
        fitController!.brand!,
        fitController!.selectedSize!,
        fitController!.selectedStandard!,
        fitController!.fitValue!,
        change: alreadySaved
    );
    setState(() {
      fitSending = false;
      alreadySaved = true;
    });
  }

  bool isOk () {
    return fitController!.fitValue != null && fitController!.brand != null
        && fitController!.brand != "" && fitController!.selectedSize != null
        && fitController!.selectedSize != "";
  }

  @override
  Widget build(BuildContext context) {
    if (fitController == null) {
      loadBoundData();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Adding new brand"),
        backgroundColor: sa_blue
      ),
      body: Center(
          child: fitController != null ? Column (
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Text(
                    "new brand",
                    style: TextStyle(
                        fontSize: defaultFontSize,
                      color: palettePink
                    )
                ),
                margin: EdgeInsets.symmetric(vertical: 20.h),
              ),
              Container(
                child: TextFormField(
                  controller: _controller2,
                  enabled: !alreadySaved,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'enter new brand name',
                    labelStyle: TextStyle(
                      color: sa_blue,
                    ),
                    hintText: "Adidas",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: Container(
                        margin: EdgeInsets.only(top: 10.h),
                        child: IconButton(
                            onPressed: () {
                              _controller2.clear();
                              setState(() {
                                fitController!.brand = "";
                              });
                            },
                            icon: Icon(Icons.clear),
                            padding: EdgeInsets.all(0.0)
                        )
                    ),
                  ),
                  onChanged: (text) {
                    setState(() {
                      fitController!.brand = text;
                    });
                  },
                ),
                margin: EdgeInsets.symmetric(horizontal: 20.r)
              ),
              Container(
                child: Text(
                    "I am trying size",
                    style: TextStyle(
                        fontSize: defaultFontSize
                    )
                ),
                margin: EdgeInsets.symmetric(vertical: 30.h),
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
              Container(
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    controller: _controller3,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                      fontSize: 30.0
                    ),
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      hintText: "38.5",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    onChanged: (text) {
                      setState(() {
                        fitController!.selectedSize = text;
                      });
                    },
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 20.r, vertical: 10.h)
              ),
              Container(
                //color: background,
                child: LayoutGrid(
                  areas: '''
                    sb  Ib bb
                    .   .  Ph
                  ''',
                  columnSizes: [105.r.px, 180.r.px, 105.r.px],
                  rowSizes: [
                    265.h.px,
                    70.h.px
                  ],
                  children: [
                    Center(child:Column(
                        children: [
                          Container(
                              margin: EdgeInsets.only(top: 30.h),
                              child:ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(),
                                    primary: (fitController != null &&
                                        (fitController!.fitValue == null || fitController!.fitValue != 2))
                                        ? paletteLightGray : otherFitPressedColor
                                ),
                                child: Container(
                                  width: 85.r,
                                  height: 85.h,
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
                                onPressed: () {
                                  setState(() {
                                    fitController!.fitValue = 2;
                                  });
                                },
                              )),
                          Container(
                              margin: EdgeInsets.only(top: 15.h),
                              child:ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(),
                                    primary: (fitController != null &&
                                        (fitController!.fitValue == null || fitController!.fitValue != 1))
                                        ? paletteLightGray : otherFitPressedColor
                                ),
                                child: Container(
                                  width: 60.r,
                                  height: 60.h,
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
                                onPressed: () {
                                  setState(() {
                                    fitController!.fitValue = 1;
                                  });
                                },
                              )),
                        ]
                    )).inGridArea("sb"),
                    Column(
                        children: [
                          Container(
                              margin: EdgeInsets.only(top: 30.h, bottom: 20.h),
                              child:ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(),
                                    primary: (fitController != null &&
                                        (fitController!.fitValue == null || fitController!.fitValue != 3))
                                        ? idealFitColor : otherFitPressedColor
                                ),
                                child: Container(
                                  width: 160.r,
                                  height: 160.h,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(shape: BoxShape.circle),
                                  child: Text(
                                    'IDEAL FIT',
                                    style: TextStyle(fontSize: 22),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    fitController!.fitValue = 3;
                                  });
                                },
                              )),
                          if(!fitSending) TextButton(
                            style: TextButton.styleFrom(
                                textStyle: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold
                                ),
                                primary: idealFitColor
                            ),
                            onPressed: () {
                              if (!isOk()) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text("But how it fits you?"),
                                ));
                              } else {
                                setState(() {
                                  saveFitData();
                                });
                              }
                            },
                            child: Text(
                                !alreadySaved ? 'GOT IT' : 'CHANGE'
                            ),
                          ),
                          if (fitSending) Container(child:ColorLoader4(
                              dotOneColor: idealFitColor,
                              dotTwoColor: idealFitColor,
                              dotThreeColor: idealFitColor,
                              duration: Duration(seconds: 2)
                          ),
                              margin: EdgeInsets.only(top: 20.h))
                        ]).inGridArea("Ib"),
                    Center(child:Column(
                        children: [
                          Container(
                              margin: EdgeInsets.only(top: 30.h),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(),
                                    primary: (fitController != null &&
                                        (fitController!.fitValue == null || fitController!.fitValue != 4))
                                        ? paletteLightGray : otherFitPressedColor
                                ),
                                child: Container(
                                  width: 85.r,
                                  height: 85.h,
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
                                onPressed: () {
                                  setState(() {
                                    fitController!.fitValue = 4;
                                  });
                                },
                              )
                          ),
                          Container(
                              margin: EdgeInsets.only(top: 15.h),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(),
                                    primary: (fitController != null &&
                                        (fitController!.fitValue == null || fitController!.fitValue != 5))
                                        ? paletteLightGray : otherFitPressedColor
                                ),
                                child: Container(
                                  width: 60.r,
                                  height: 60.h,
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
                                onPressed: () {
                                  setState(() {
                                    fitController!.fitValue = 5;
                                  });
                                },
                              ))
                        ]
                    )).inGridArea("bb"),
                    Center(child:RawMaterialButton(
                      onPressed: () {
                        if (!isOk()) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("But how it fits you?"),
                          ));
                        } else {
                          Navigator.of(context).pushNamed(
                              "/take-picture",
                              arguments: PhotoArguments(
                                  fitController!.fittingID!)
                          );
                        }
                      },
                      elevation: 2.0,
                      fillColor: sa_blue,
                      child: Icon(
                          Icons.photo_camera,
                          size: 35.r,
                          color: Colors.white
                      ),
                      padding: EdgeInsets.all(15.r),
                      shape: CircleBorder(),
                    )).inGridArea("Ph")
                  ],
                ),
                margin: EdgeInsets.only(top: 15.h)
              ),
            ],
          ) :
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  child: ColorLoader4(
                      dotOneColor: sa_blue,
                      dotTwoColor: sa_blue,
                      dotThreeColor: sa_blue,
                      duration: Duration(milliseconds: 500)
                  )
              )
            ],
          )
      ),
    );
  }
}
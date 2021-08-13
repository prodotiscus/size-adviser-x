import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:size_adviser/api.dart';
import 'package:size_adviser/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'color_loader_4.dart';

class FittingRoomScreen extends StatefulWidget {
  @override
  _FittingRoomScreenState createState() => _FittingRoomScreenState();
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

  List<String> get standards => prioritizeDefault(
      this.standardObj!.map((Standard el) => el.name).toList()
  );

  List<String> prioritizeDefault (List<String> l) {
    String defaultS = Settings.getValue("profile_default_standard", "RU");
    int n = l.length;
    l.removeWhere((element) => element == defaultS);
    if (n > l.length) {
      l.insert(0, defaultS);
    }
    return l;
  }

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
  bool fitSending = false;
  bool alreadySaved = false;

  Widget produceRecommendationWidget(List<Recommendation> lst) {
    List<Widget> listForRow = [];
    for (var recom in lst) {
      listForRow.add(
          Container(
              width: (75.0*1.0000).r,
              padding: EdgeInsets.symmetric(
                  vertical: (10.0*1.0000).r,
                  horizontal: (5.0*1.0000).h
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
        margin: EdgeInsets.symmetric(horizontal: (20.0*1.0000).r)
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
      print("switchTo");
      sizesController = PageController(
          viewportFraction: 0.3,
          initialPage: switchTo
      );
      _sizes_index = switchTo;
      fitController!.selectedSize = fitController!.getSelectedRange()![_sizes_index];
      print("SET_TO");
      print(fitController!.selectedSize);
      //sizesController.jumpToPage(switchTo);
    });
  }

  Widget standardsScroller() {
    return Container(
        margin: EdgeInsets.only(top: (10.0*1.0000).h),
        child: SizedBox(
            height: (50*1.0000).h,
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
        margin: EdgeInsets.only(top: (10.0*1.0000).h),
        child: SizedBox(
            height: (50*1.0000).h,
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
                            width: (50.0*1.0000).r,
                            height: (50.0*1.0000).h,
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

  void saveFitData () async {
    if (fitController!.fitValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("But how it fits you?"),
      ));
      return;
    }
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

  Widget smallPartButtons() {
    return Center(child:Column(
        children: [
          Container(
              margin: EdgeInsets.only(top: (30.0*1.0000).h),
              child:ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    primary: (fitController != null &&
                        (fitController!.fitValue == null || fitController!.fitValue != 2))
                        ? paletteLightGray : otherFitPressedColor
                ),
                child: Container(
                  width: (85*1.0000).r,
                  height: (85*1.0000).r,
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
              margin: EdgeInsets.only(top: (15.0*1.0000).h),
              child:ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    primary: (fitController != null &&
                        (fitController!.fitValue == null || fitController!.fitValue != 1))
                        ? paletteLightGray : otherFitPressedColor
                ),
                child: Container(
                  width: (60*1.0000).r,
                  height: (60*1.0000).r,
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
    ));
  }

  Widget idealPartButtons() {
    return Column(
        children: [
          Container(
              margin: EdgeInsets.only(top: (30.0*1.0000).h, bottom: (20.0*1.0000).h),
              child:ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    primary: (fitController != null &&
                        (fitController!.fitValue == null || fitController!.fitValue != 3))
                        ? idealFitColor : otherFitPressedColor
                ),
                child: Container(
                  width: 140.r,
                  height: 140.r,
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
              setState(() {
                saveFitData();
              });
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
              margin: EdgeInsets.only(top: (20.0*1.0000).h))
        ]);
  }

  Widget bigPartButtons() {
    return Center(child:Column(
        children: [
          Container(
              margin: EdgeInsets.only(top: (30.0*1.0000).h),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    primary: (fitController != null &&
                        (fitController!.fitValue == null || fitController!.fitValue != 4))
                        ? paletteLightGray : otherFitPressedColor
                ),
                child: Container(
                  width: (85*1.0000).r,
                  height: (85*1.0000).r,
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
              margin: EdgeInsets.only(top: (15.0*1.0000).h),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    primary: (fitController != null &&
                        (fitController!.fitValue == null || fitController!.fitValue != 5))
                        ? paletteLightGray : otherFitPressedColor
                ),
                child: Container(
                  width: (60*1.0000).r,
                  height: (60*1.0000).r,
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
    ));
  }

  @override
  Widget build(BuildContext context) {

    if (recommendations == null) {
      loadBoundData();
    }

    return Scaffold(
      body: Center(
          child: recommendations != null ? Column (
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Text(
                    "choose brand",
                    style: TextStyle(
                        fontSize: defaultFontSize
                    )
                ),
                margin: EdgeInsets.symmetric(vertical: (20.0*1.0000).h),
              ),
              if(optionSelector != null) Container(
                  margin: EdgeInsets.symmetric(horizontal: (20.0*1.0000).r),
                  width: (350.0*1.0000).r,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: (24*1.0000).r,
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
                    onChanged: (String? value) {
                      if (value == null) return;
                      setState(() {
                        selectedBrand = value[0] + value.substring(1).toLowerCase();
                        recommendations = null;
                        optionSelector = null;
                        _standards_index = 0;
                        _sizes_index = 0;
                        fitController = null;
                        standardsController = PageController(
                            viewportFraction: 0.2
                        );
                        sizesController = PageController(
                            viewportFraction: 0.2
                        );
                        fitSending = false;
                        alreadySaved = false;
                      });
                      loadBoundData();
                    },
                  )
              ),
              Container(
                  child: Text(
                      "size recommendation",
                      style: TextStyle(
                          fontSize: defaultFontSize
                      )
                  ),
                  margin: EdgeInsets.only(top: (10.0*1.0000).h)
              ),
              if (recommendations != null) Center(
                  child: Container(
                    child: recommendations!,
                    margin: EdgeInsets.symmetric(vertical: (10.0*1.0000).h),
                  )
              ),
              Container(
                child: Text(
                    "I am trying size",
                    style: TextStyle(
                        fontSize: defaultFontSize
                    )
                ),
                margin: EdgeInsets.symmetric(vertical: (10.0*1.0000).h),
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
                  columnSizes: [(105*1.0000).r.px, (180*1.0000).r.px, (105*1.0000).r.px],
                  rowSizes: [
                    (265*1.0000).h.px,
                    (70*1.0000).h.px
                  ],
                  children: [
                    smallPartButtons().inGridArea("sb"),
                    idealPartButtons().inGridArea("Ib"),
                    bigPartButtons().inGridArea("bb"),
                    Center(child:RawMaterialButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                            "/new-brand"
                        );
                      },
                      elevation: 2.0,
                      fillColor: sa_blue,
                      child: Icon(
                          Icons.add,
                          size: 35.0,
                          color: Colors.white
                      ),
                      padding: EdgeInsets.all((15.0*1.0000).r),
                      shape: CircleBorder(),
                    )).inGridArea("Nw"),
                    Center(child:RawMaterialButton(
                      onPressed: () {
                        if (fitController!.fitValue == null) {
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
                          size: 35.0,
                          color: Colors.white
                      ),
                      padding: EdgeInsets.all((15.0*1.0000).r),
                      shape: CircleBorder(),
                    )).inGridArea("Ph")
                  ],
                ),
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
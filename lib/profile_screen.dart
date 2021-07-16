import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:size_adviser/colors.dart';

import 'api.dart';

class ProfileSearchControl {
  List<String> standards;
  List<DfgBrand> brands;
  ProfileSearchControl(
      this.standards,
      this.brands
  );

  int get numTotal => this.brands.length;
  int get numTested => this.brands.where((element) => element.triedOn).length;
}


class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final lrMarginValue = 20.0;
  final user = FirebaseAuth.instance.currentUser;
  int _index = 0;
  var _controller1 = PageController(
    viewportFraction: 0.2
  );
  var _controller2 = TextEditingController();
  var api = SizeAdviserApi();
  var profileControl = ProfileSearchControl(
    [], []
  );
  double statsFontSize = 18.0;
  bool showOnlyTested = false;
  String filteringPrefix = "";
  String selectedStandard = "RU";

  Widget defMargin(Widget w, {double custom = 10.0}) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: custom),
        child: w
    );
  }

  void updateStandardsList() async {
    var standards = await api.getAllStandards();
    var spf = await SharedPreferences.getInstance();
    var defaultS = spf.getString("profile_default_standard") ?? "US";

    List<DfgBrand> dfg = await api.getDataForUser(spf);

    setState(() {
      profileControl.standards = standards;
      profileControl.standards.removeWhere((element) => element == defaultS);
      profileControl.standards.insert(0, defaultS);
      selectedStandard = defaultS;
      profileControl.brands = dfg;
    });
  }

  Widget togglingButton () {
    return KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          if (isKeyboardVisible) return SizedBox.shrink();
          return Center(
              child: Container(
                  child:ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showOnlyTested = !showOnlyTested;
                      });
                    },
                    child: Text(
                        !showOnlyTested ? "Show only tested" : "Show all",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold
                        )
                    ),
                    style: ElevatedButton.styleFrom(
                        primary: paletteLightGray,
                        padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0)
                    ),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 20.0)
              )
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    if (profileControl.standards.isEmpty) {
      updateStandardsList();
    }

    return Scaffold(
      body: Center(
          child: Column (
            /*mainAxisAlignment: MainAxisAlignment.center,*/
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Column(
                 children: <Widget>[
                   if(user!.photoURL != null) ClipOval(
                    child: Image.network(
                      largerPictureURL(user!.photoURL!)!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if(user!.photoURL == null) ClipOval(
                    child: Image.asset(
                      "images/avatar_placeholder.png",
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
              ]),
                margin: EdgeInsets.only(top: 20.0)
              ),
              Container(
                child: Text(
                  user!.displayName != null ? user!.displayName! : "null",
                  style: TextStyle(
                    fontSize: 14,
                    color: darkerGray
                  ),
                ),
                margin: EdgeInsets.only(top: 20.0),
              ),
              Container(
                child: TextFormField(
                  controller: _controller2,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'search',
                    labelStyle: TextStyle(
                      color: sa_blue,
                    ),
                    hintText: "Adidas",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: Container(
                      margin: EdgeInsets.only(top: 10.0),
                      child: IconButton(
                        onPressed: () {
                          _controller2.clear();
                          filteringPrefix = "";
                        },
                        icon: Icon(Icons.clear),
                        padding: EdgeInsets.all(0.0)
                      )
                    ),
                  ),
                  onChanged: (text) {
                    setState(() {
                      filteringPrefix = text;
                    });
                  },
                ),
                margin: EdgeInsets.only(left: lrMarginValue, right: lrMarginValue),
              ),
              Container(
                margin: EdgeInsets.only(top: 10.0),
                child: defMargin(SizedBox(
                  height: 50, // card height
                  child: PageView.builder(
                    itemCount: profileControl.standards.length,
                    controller: _controller1,
                    onPageChanged: (int index) {
                      setState(() {
                        _index = index;
                        selectedStandard = profileControl.standards[index];
                      });
                    },
                    itemBuilder: (_, i) {
                      return Transform.scale(
                        scale: i == _index ? 1 : 0.8,
                        child: GestureDetector(
                          onTap: () {
                            _controller1.animateToPage(i, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
                          },
                          child: Text(
                            profileControl.standards[i],
                            style: TextStyle(
                              fontSize: 27,
                              color: i == _index ? sa_blue : darkerGray,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        )
                      );
                    },
                  )
                ))
              ),
              const Divider(
                height: 0,
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              Container(
              child: defMargin(
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "TOTAL",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: statsFontSize
                      )
                    ),
                    Text(
                        profileControl.numTotal.toString(),
                        style: TextStyle(
                          fontSize: statsFontSize
                        )
                    ),
                    Text(
                        "Tested",
                      style: TextStyle(
                        fontSize: statsFontSize,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    Text(
                        profileControl.numTested.toString(),
                      style: TextStyle(
                        fontSize: statsFontSize
                      )
                    ),
                  ],
                ),
                custom: 20.0
              ),
                margin: EdgeInsets.symmetric(vertical: 10.0)
              ),
              const Divider(
                height: 0,
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              Container(
              child: defMargin(
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        "brands",
                      style: TextStyle(
                        color: darkerGray,
                        fontSize: statsFontSize
                      )
                    ),
                    Text(
                        "size",
                        style: TextStyle(
                            color: darkerGray,
                            fontSize: statsFontSize
                        )
                    )
                  ],
                ),
                custom: 20.0
              ),
              margin: EdgeInsets.symmetric(vertical: 10.0)),
              Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    height: 50.0,
                    child: ListView(
                        shrinkWrap: true,
                        physics: AlwaysScrollableScrollPhysics(),
                        children: profileList()
                    ),
                  )
              ),
              togglingButton()
            ],
          )
      ),
    );

  }

  List<Widget> profileList () {
    List<Widget> l1 = [];
    List<String> addedLetters = [];
    var sortedBrands = profileControl.brands;
    sortedBrands.sort((a, b) => a.brand.compareTo(b.brand));
    for (var brand in profileControl.brands) {
      if (showOnlyTested && !brand.triedOn) {
        continue;
      }
      if (filteringPrefix != "" &&
          !brand.brand.toLowerCase().startsWith(filteringPrefix.toLowerCase())) {
        continue;
      }

      if (!addedLetters.any((el) => el == brand.brand[0].toUpperCase())) {
        l1.add(
          Text(
            brand.brand[0].toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: statsFontSize
            )
          )
        );
        addedLetters.add(brand.brand[0].toUpperCase());
      }

      String displaySize = "";
      for(var pair in brand.systemsOfSize) {
        if (pair.standard == selectedStandard) {
          displaySize = pair.size;
        }
      }
      l1.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                brand.brand,
              style: TextStyle(
                color: brand.triedOn ? palettePink : Colors.black,
                fontSize: statsFontSize
              )
            ),
            Text(
                displaySize,
              style: TextStyle(
                color: brand.triedOn ? palettePink : Colors.black,
                fontSize: statsFontSize
              )
            )
          ],
        )
      );
    }
    return l1;
  }

  String? largerPictureURL(String smallPictureURL) {
    if (smallPictureURL.contains("graph.facebook.com")) {
      for (var profile in FirebaseAuth.instance.currentUser!.providerData) {
        if (FacebookAuthProvider.PROVIDER_ID == profile.providerId) {
          var larger = "https://graph.facebook.com/" + profile.uid + "/picture?height=500&width=500";
          return larger;
        }
      }
    }
    else if (smallPictureURL.contains("googleusercontent.com")) {
      for (var profile in FirebaseAuth.instance.currentUser!.providerData) {
        if (GoogleAuthProvider.PROVIDER_ID == profile.providerId) {
          var larger = smallPictureURL;
          larger = larger.replaceAll("96", "500");
          return larger;
        }
      }
    }
  }
}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:size_adviser/colors.dart';
import 'api.dart';

class MyCollectionScreen extends StatefulWidget {
  @override
  _MyCollectionScreenState createState() => _MyCollectionScreenState();
}

class _MyCollectionScreenState extends State<MyCollectionScreen> {
  List<Widget> col = [];
  bool collectionLoaded = false;
  double cardTitleSize = 18.0;

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
                indent: 15,
                endIndent: 15,
              ),
              Row (
                mainAxisAlignment: MainAxisAlignment.start, //change here don't //worked
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      child: Align(
                        child: Text(
                          "DETAILS",
                          style: TextStyle(
                            color: darkerGray
                          )
                        ),
                      ),
                      margin: EdgeInsets.only(left: 20.0),
                  ),
                  new Spacer(),
                  Align(
                      child: Text(
                        "size",
                        style: TextStyle(
                          color: darkerGray
                        )
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
              Expanded(
                child: Container(
                  height: 100.0,
                  child: ListView(
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    children: (() {
                      if (col.isEmpty) {
                        return <Widget>[];
                      } else {
                        return col;
                      }
                    })()
                  ),
                )
              ),
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
      for (var i = 0; i < col2.length; i ++) {
        c.add(itemCard(col2[i], last: i == col2.length - 1));
      }
      if (c.isNotEmpty) {
        col = c;
      } else {
        col = [
          const Divider(
            height: 20,
            thickness: 1,
            indent: 15,
            endIndent: 15,
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: Text(
                "Your collection is empty.",
                style: TextStyle(
                  color: darkerGray
                )
              )
            )
          )
        ];
      }
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
    return Text(w!, style: TextStyle(color: c!, fontSize: cardTitleSize));
  }

  void showZoomedOf(String fittingID, int index) {
    print("Pushing route for $fittingID/$index");
    Navigator.of(context).pushNamed(
      "/zoomed-of",
      arguments: ZoomArguments(
        fittingID,
        index,
      ),
    );
  }

  Widget itemCard(CollectionItem item, {bool last = false}) {
    var api = SizeAdviserApi();
    print(api.getItemPhotoURL(item.fittingID, index: 1));
    return GestureDetector(
      onTap: () {_showFittingActions(item.fittingID);},
      child: Center(
        child: Card(
          elevation: 0,
          color: Colors.transparent,
          child: Column(
            children: <Widget>[
              const Divider(
                height: 20,
                thickness: 1,
                indent: 10,
                endIndent: 10,
              ),
              defMargin(Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  new Text(
                    item.date,
                    style: TextStyle(
                      color: darkerGray
                    )
                  ),
                  new Text(
                    item.standard,
                    style: TextStyle(
                      color: darkerGray
                    )
                  )
                ],
              )),
              defMargin(
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      new Text(
                        item.brand,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: cardTitleSize,
                          color: darkerGray
                        )
                      ),
                      new Text(
                        item.size,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: cardTitleSize,
                          color: darkerGray
                        )
                      ),
                      fitValueColored(item.fitValue)
                    ]
                  )
                ),
              ),
              if (item.hasPhotos) defMargin(
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    GestureDetector(
                      child: itemPhoto(api, item.fittingID, 0),
                      onLongPress: () { _showPhotoActions(item.fittingID, 0); },
                    ),
                    GestureDetector(
                      child: itemPhoto(api, item.fittingID, 1),
                      onLongPress: () { _showPhotoActions(item.fittingID, 1); },
                    ),
                    GestureDetector(
                      child: itemPhoto(api, item.fittingID, 2),
                      onLongPress: () { _showPhotoActions(item.fittingID, 2); },
                    ),
                  ]
                )
              ),
              if (!item.hasPhotos) defMargin(
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Image.asset("images/shoe_placeholder.png", width: 100.0, height: 100.0)
                      ]
                  )
              ),
              if (last) const Divider(
                height: 20,
                thickness: 1,
                indent: 10,
                endIndent: 10,
              ),
            ],
          )
        )
      )
    );

  }

  Widget itemPhoto(SizeAdviserApi api, String fittingID, int index) {
    return GestureDetector(
      onTap: () {
        showZoomedOf(fittingID, index);
      },
      child: SizedBox(
        width: 100.0,
        height: 100.0,
        child: Image.network(
          api.getItemPhotoURL(fittingID, index: index, thumbnail: true),
          fit: BoxFit.cover,
          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
            return Container(width: 100.0, height: 100.0);
          },
        )
      )
    );
  }

  void registerUser() async {
    var spf = await SharedPreferences.getInstance();
    var api = SizeAdviserApi();
    api.registerCurrentUser(spf);
  }

  Future<void> _showFittingActions(String fittingID) async {
    switch (await showDialog<String?>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Fitting actions'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () { Navigator.pop(context, "RemoveFitting"); },
                child: const Text('Remove fitting'),
              )
            ],
          );
        }
    )) {
      case "RemoveFitting":
        var api = SizeAdviserApi();
        api.removeFitting(fittingID);
        loadCollection();
        break;
      case null:
        break;
    }
  }

  Future<void> _showPhotoActions(String fittingID, int index) async {
    switch (await showDialog<String?>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text("Actions with photo"),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () { Navigator.pop(context, "RemoveThisPhoto"); },
                child: const Text("Remove photo"),
              )
            ],
          );
        }
    )) {
      case "RemoveThisPhoto":
        var api = SizeAdviserApi();
        api.removePhoto(fittingID, index);
        loadCollection();
        break;
      case null:
        break;
    }
  }
}


class ZoomArguments {
  final String fittingID;
  final int index;

  ZoomArguments(this.fittingID, this.index);
}
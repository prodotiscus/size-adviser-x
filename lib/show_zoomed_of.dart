import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:size_adviser/api.dart';
import 'package:size_adviser/my_collection_screen.dart';

class ZoomedOfScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ZoomArguments;
    var api = SizeAdviserApi();

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        child: Center(
          child: Column (
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                  width: 400.0,
                  height: 400.0,
                  child: Image.network(
                    api.getItemPhotoURL(args.fittingID, index: args.index),
                    fit: BoxFit.contain,
                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      return Text(
                          "Failed to load image, try again",
                          style: TextStyle(color: Colors.white)
                      );
                    },
                    loadingBuilder: (BuildContext context, Widget child,ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null ?
                          loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  )
              )
            ],
          )
       )
      ,
      onTap: () {
        Navigator.of(context).pop();
      },
      behavior: HitTestBehavior.translucent)
    );
  }
}
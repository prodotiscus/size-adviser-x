import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:size_adviser/api.dart';
import 'package:size_adviser/color_loader_4.dart';

import 'colors.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key? key,
    required this.camera
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late String fittingID;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as PhotoArguments;
    fittingID = args.fittingID;
    return Scaffold(
      appBar: AppBar(
          title: Text("Take a photo for your fit"),
        backgroundColor: sa_blue,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Construct the path where the image should be saved using the
            // pattern package.
            final path = join(
              // Store the picture in the temp directory.
              // Find the temp directory using the `path_provider` plugin.
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );

            // Attempt to take a picture and log where it's been saved.
            await _controller.takePicture(path);

            // If the picture was taken, display it on a new screen.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  imagePath: path, key: null, fittingID: fittingID),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final String fittingID;

  DisplayPictureScreen({
    required Key? key,
    required this.imagePath,
    required this.fittingID
  }) : super(key: key);

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  bool _uploaded = false;
  bool _startedUpload = false;

  Future<void> photoUpload(String path) async {
    setState(() {
      _startedUpload = true;
    });
    var uploader = ApiPhotoUploader(widget.fittingID);
    var formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(path, filename: uploader.filename)
    });
    var response = await Dio().post(uploader.uploadUrl, data: formData);
    setState(() {
      _uploaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_uploaded && !_startedUpload) {
      photoUpload(widget.imagePath);
    }

    return Scaffold(
      backgroundColor: sa_blue,
      appBar: AppBar(
          title: Text("Well done!"),
        backgroundColor: sa_blue,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 200,
            width: 200,
            child: FittedBox(
              child: Image.file(File(widget.imagePath),fit:BoxFit.contain)
            )
            ),
            Container(child:Text(
                !_uploaded ? "Uploading your photo" : "Photo uploaded",
              style: TextStyle(
                fontSize: 25.0,
                color: Colors.white
              )),
              margin: EdgeInsets.symmetric(vertical: 15.0)
            ),
            if (!_uploaded) Container(
              child: ColorLoader4(
                dotOneColor: Colors.white,
                dotTwoColor: Colors.white,
                dotThreeColor: Colors.white,
                duration: const Duration(milliseconds: 500)
              ),
              margin: EdgeInsets.only(bottom: 15.0)
            ),
            if (_uploaded) Center(child:Container(
                child: Icon(
                    Icons.check_circle_outline,
                  size: 150.0,
                  color: Colors.white
                ),
                margin: EdgeInsets.only(bottom: 15.0)
            )),
            Center(child:Container(
                child:ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      primary: Colors.white
                  ),
                  child: Container(
                    width: 160,
                    height: 160,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children:[
                          Text(
                            'Add another',
                            style: TextStyle(
                                fontSize: 22,color:Colors.black),
                          ),
                          Text(
                            'photo',
                            style: TextStyle(
                                fontSize: 22,color:Colors.black),
                          ),
                    ]
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )))
          ]),
    );
  }
}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    title: 'Size Adviser',
    // Start the app with the "/" named route. In this case, the app starts
    // on the StartScreen widget.
    initialRoute: '/',
    routes: {
      // When navigating to the "/" route, build the StartScreen widget.
      '/': (context) => StartScreen(),
      // When navigating to the "/second" route, build the CheckAuthScreen widget.
      '/second': (context) => CheckAuthScreen(),
      '/email-signin': (content) => EmailSignInScreen(),
    },
  ),
  );
}


class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    new Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushNamed(context, '/second');
    });

    return Scaffold(
      body: Center(
        child: Column (
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
          Text(
              "SIZE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 55
              ),
          ),
          Text(
              "adviser",
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                letterSpacing: 6
              ),
          ),
        ],
        )
      ),
      backgroundColor: sa_blue,
    );
  }
}

class CheckAuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.pushReplacementNamed(context, '/email-signin');
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Screen"),
      ),
      body: Center(
        child: ElevatedButton(
          // Within the CheckAuthScreen widget
          onPressed: () {
            // Navigate back to the first screen by popping the current route
            // off the stack.
            Navigator.pop(context);
          },
          child: Text('Hello, ' + FirebaseAuth.instance.currentUser.toString()),
        ),
      ),
    );
  }
}

class EmailSignInScreen extends StatefulWidget {
  @override
  _EmailSignInScreenState createState() => _EmailSignInScreenState();
}

class _EmailSignInScreenState extends State<EmailSignInScreen> {
  bool _invalid_ep = false;

  @override
  Widget build(BuildContext context) {
    void throw_warning() {
      setState(() {
        _invalid_ep = true;
      });
    }

    return Scaffold(
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Email'
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Password',
                ),
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
              ),
              ElevatedButton(
                // Within the CheckAuthScreen widget
                onPressed: throw_warning,
                child: Text("Sign In"),
              ),
              if (_invalid_ep) Text(
                "Invalid e-mail or password",
                style: TextStyle(
                  color: Colors.red
                ),
              )
            ]
          )
      )
    );
  }
}
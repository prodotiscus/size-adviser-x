import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:size_adviser/auth_main_screen.dart';
import 'authentication.dart';
import 'colors.dart';

class EmailSignInScreen extends StatefulWidget {
  @override
  _EmailSignInScreenState createState() => _EmailSignInScreenState();
}

class _EmailSignInScreenState extends State<EmailSignInScreen> {
  bool _invalid_ep = false;
  final emailController = TextEditingController();
  final pwdController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    pwdController.dispose();
    super.dispose();
  }

  Future<void> signInOperation() async {
    setState(() {
      _invalid_ep = false;
    });

    if (emailController.text == "" || pwdController.text == "") return;

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: pwdController.text
      );
      Navigator.pushReplacementNamed(context, '/calibration');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _invalid_ep = true;
      });
    }
  }
  
  Future<void> resetPasswordOperation() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("E-mail for password reset was sent"),
      ));
      FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Something went wrong, try again"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as EmailLoginArguments;
    emailController.text = args.email;

    return Scaffold(
        appBar: AppBar(
            title: Text("Sign in using e-mail"),
            backgroundColor: sa_blue
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                      "Sign in and go.",
                      style: TextStyle(
                          color: darkerGray,
                          fontSize: 35.0
                      )
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: "Email"
                        ),
                        controller: emailController,
                      )
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 30.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: "Password",
                        ),
                        controller: pwdController,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                      )
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 10.0),
                      width: 300.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: sa_blue,
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(0.0))
                          ),
                        ),
                        onPressed: signInOperation,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  "SIGN IN",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0
                                  )
                              ),
                            ]
                        ),
                      )
                  ),
                  if (_invalid_ep) Container(
                      margin: EdgeInsets.only(top: 15.0),
                      child: Text(
                        "Invalid e-mail or password",
                        style: TextStyle(
                            color: Colors.red
                        ),
                      )
                  ),
                  Container(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(
                          color: holoBlueLight,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      onPressed: () {},
                      child: const Text('Forgot password?'),
                    ),
                    margin: EdgeInsets.only(top: 20.0)
                  ),
                  Container(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(
                              color: holoBlueLight,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, "/email-signup");
                        },
                        child: const Text("Don't have an account? Sign up"),
                      ),
                      margin: EdgeInsets.only(top: 5.0)
                  )
                ]
            )
        )
    );
  }
}

// Sign Up

class EmailSignUpScreen extends StatefulWidget {
  @override
  _EmailSignUpScreenState createState() => _EmailSignUpScreenState();
}

class _EmailSignUpScreenState extends State<EmailSignUpScreen> {
  final emailController = TextEditingController();
  final pwd1Controller = TextEditingController();
  final pwd2Controller = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    pwd1Controller.dispose();
    pwd2Controller.dispose();
    super.dispose();
  }

  Future<void> signUpOperation() async {

    if (emailController.text == "" || pwd1Controller.text == "" ||
      pwd2Controller.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Email/password must be non-empty"),
      ));
      return;
    }
    if (pwd1Controller.text != pwd2Controller.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Passwords do not match"),
      ));
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: pwd1Controller.text
      );
      Navigator.pushReplacementNamed(context, '/final-signin');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("The password provided is too weak!"),
        ));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Account already exists for this e-mail"),
          action: SnackBarAction(label: 'SIGN IN', onPressed: () {
            Navigator.pop(context);
          }),
        ));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
            title: Text("Sign in using e-mail"),
            backgroundColor: sa_blue
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                      "Sign in and go.",
                      style: TextStyle(
                          color: darkerGray,
                          fontSize: 35.0
                      )
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: "Email"
                        ),
                        controller: emailController,
                      )
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 30.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: "Password",
                        ),
                        controller: pwd1Controller,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                      )
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 30.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: "Re-enter password",
                        ),
                        controller: pwd2Controller,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                      )
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 10.0),
                      width: 300.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: sa_blue,
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(0.0))
                          ),
                        ),
                        onPressed: signUpOperation,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  "SIGN UP",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0
                                  )
                              ),
                            ]
                        ),
                      )
                  ),
                  Container(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(
                              color: holoBlueLight,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Already have an account? Sign in"),
                      ),
                      margin: EdgeInsets.only(top: 5.0)
                  )
                ]
            )
        )
    );
  }
}

class FinalSignUpScreen extends StatefulWidget {
  @override
  _FinalSignUpScreenState createState() => _FinalSignUpScreenState();
}

class _FinalSignUpScreenState extends State<FinalSignUpScreen> {
  final nameController = TextEditingController();
  bool emailSent = false;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future <void> sendVerificationMail () async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user!= null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }
  
  Future <void> finishOperation () async {
    User? user = FirebaseAuth.instance.currentUser;
    if (nameController.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter a valid name!"),
      ));
      return;
    }

    await user!.updateProfile(displayName: nameController.text);
    Navigator.pushReplacementNamed(context, '/calibration');
  }

  @override
  Widget build(BuildContext context) {
    if (!emailSent) {
      sendVerificationMail();
      emailSent = true;
    }

    return Scaffold(
        appBar: AppBar(
            title: Text("Verify your e-mail"),
            backgroundColor: sa_blue
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                      "You're almost there!",
                      style: TextStyle(
                          color: darkerGray,
                          fontSize: 35.0
                      )
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      "We've send verification e-mail to you."
                    )
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                          "Please proceed to the link in the e-mail"
                      )
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                          "And enter your first name and last name"
                      )
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: "Your name"
                        ),
                        controller: nameController,
                      )
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 10.0),
                      width: 300.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: sa_blue,
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(0.0))
                          ),
                        ),
                        onPressed: finishOperation,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  "I HAVE VERIFIED MY E-MAIL",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0
                                  )
                              ),
                            ]
                        ),
                      )
                  ),
                ]
            )
        )
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';


Future<UserCredential> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

/*Future<UserCredential> signInWithFacebook() async {
  // Trigger the sign-in flow
  final AccessToken result = await FacebookAuth.instance.login();

  // Create a credential from the access token
  final facebookAuthCredential = FacebookAuthProvider.credential(result.token);
  print("FACEBOOK:");
  print(result);
  print(facebookAuthCredential);

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
}*/

/*Future<void> _checkIfIsLogged() async {
  final accessToken = await FacebookAuth.instance.accessToken;
  setState(() {
    _checking = false;
  });
  if (accessToken != null) {
    print("is Logged:::: ${prettyPrint(accessToken.toJson())}");
    // now you can call to  FacebookAuth.instance.getUserData();
    final userData = await FacebookAuth.instance.getUserData();
    // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
    _accessToken = accessToken;
    setState(() {
      _userData = userData;
    });
  }
}*/

void _printCredentials(accessToken) {
  print(accessToken.toJson());
}

Future<UserCredential> signInWithFacebook() async {
  final LoginResult result = await FacebookAuth.instance.login(); // by default we request the email and the public profile

  // loginBehavior is only supported for Android devices, for ios it will be ignored
  // final result = await FacebookAuth.instance.login(
  //   permissions: ['email', 'public_profile', 'user_birthday', 'user_friends', 'user_gender', 'user_link'],
  //   loginBehavior: LoginBehavior
  //       .DIALOG_ONLY, // (only android) show an authentication dialog instead of redirecting to facebook app
  // );

  if (result.status == LoginStatus.success) {
    var accessToken = result.accessToken;
    var fbCredential = FacebookAuthProvider.credential(accessToken!.token);
    return await FirebaseAuth.instance.signInWithCredential(fbCredential);
    _printCredentials(accessToken);
    // get the user data
    // by default we get the userId, email,name and picture
    final userData = await FacebookAuth.instance.getUserData();
    // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
    print(userData);
  } else {
    print(result.status);
    print(result.message);
    throw Exception("FB auth: something went wrong");
  }
}


/*Future<void> _logOut() async {
  await FacebookAuth.instance.logOut();
  _accessToken = null;
  _userData = null;
  setState(() {});
}*/
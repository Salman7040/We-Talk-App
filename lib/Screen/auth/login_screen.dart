import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_talk/Helper/dialogs.dart';
import 'package:we_talk/Screen/home_screen.dart';
import 'package:we_talk/api/apis.dart';
import 'package:we_talk/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleBtnClick() {
    //for showing  progress bar
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      //for hiding progress bar
      Navigator.pop(context);
      if (user != null) {
        print("user: ${user.user}\n");
        print("additionalUserInfo: ${user.additionalUserInfo}");

        if ((await APIs.userExist())) {
          APIs.getSelfInfo().then((onValue) => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen())));
        } else {
          APIs.createUser().then((value) {
            APIs.getSelfInfo().then((onValue) => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen())));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      //for hindig showing te snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // for checking the internate is on or off
      await InternetAddress.lookup('google.com');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print(e);

      //for showing te snackbar
      Dialogs.showSnackBar(
          context, "Somthing Went Wrong (Check Your Internet)",Colors.red.withOpacity(.9));
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Welcome to We Talk"),
      ),
      body: Stack(
        children: [
          //This position for  App logo
          AnimatedPositioned(
            top: mq.height * .17,
            right: _isAnimate ? mq.width * .2 : -mq.width * .5,
            width: mq.width * .5,
            child: Image.asset("images/chat_app3.png"),
            duration: const Duration(milliseconds: 700),
          ),

          //This position for  Google sign in
          Positioned(
              bottom: mq.height * .16,
              left: mq.width * .18,
              width: mq.width * .7,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                      shape: StadiumBorder()),
                  //on press sign in function invoked
                  onPressed: () {
                    _handleGoogleBtnClick();
                  },
                  icon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      "images/google.png",
                      width: mq.width * .1,
                    ),
                  ),
                  label: RichText(
                    text: const TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: 19),
                        children: [
                          TextSpan(text: "Login with "),
                          TextSpan(
                              text: "Google",
                              style: TextStyle(fontWeight: FontWeight.w500)),
                        ]),
                  ))),
        ],
      ),
    );
  }
}

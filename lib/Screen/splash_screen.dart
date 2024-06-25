import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_talk/Screen/auth/login_screen.dart';
import 'package:we_talk/Screen/home_screen.dart';
import 'package:we_talk/api/apis.dart';
import 'package:we_talk/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState

    super.initState();

    Future.delayed(const Duration(milliseconds: 2000), () {


      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      //this is for changing bottom bar color to white
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white));

//if user login then go direct to the homeScreen  other wise it will show the login screen
      if (APIs.auth.currentUser != null) {
        print("From Splash Screen APIs.auth.currentUser: ${APIs.auth.currentUser}");
        APIs.getSelfInfo().then((onValue) => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen())));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
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
            right: mq.width * .25,
            width: mq.width * .5,
            child: Image.asset("images/chat_app3.png"),
            duration: const Duration(milliseconds: 700),
          ),

          //This position for  Google sign in
          Positioned(
              bottom: mq.height * .16,
              width: mq.width,
              child: const Text(
                "WELCOME TO WE TALK",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                    color: Colors.grey),
              )),
        ],
      ),
    );
  }
}

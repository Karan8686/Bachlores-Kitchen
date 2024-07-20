import 'dart:async';
import 'package:batchloreskitchen/Logins/NewL.dart';
import 'package:batchloreskitchen/Pages/NavigationBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


class SplashScreen1 extends StatefulWidget {
  @override
  _SplashScreen1State createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth auth=FirebaseAuth.instance;
    Timer(
        Duration(seconds: 3),
            () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => auth.currentUser != null?  const BottomBar():Log())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.deepOrangeAccent,
      body: Center(
          child: Image.asset("images/LogoSplash.jpg",fit: BoxFit.cover,)
      ),
    );
  }
}
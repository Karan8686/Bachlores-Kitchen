import 'package:batchloreskitchen/Logins/NewL.dart';
import 'package:batchloreskitchen/Logins/login.dart';
import 'package:batchloreskitchen/Onboard/PageView.dart';
import 'package:batchloreskitchen/Pages/Home.dart';
import 'package:batchloreskitchen/Pages/details.dart';
import 'package:batchloreskitchen/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:batchloreskitchen/Pages/NavigationBar.dart';
import 'package:flutter/services.dart';
import 'package:batchloreskitchen/Pages/Map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:telephony/telephony.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final Telephony telephony = Telephony.instance;
  bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;

  // Set the status bar style to be visible
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor:Colors.white10,  // Set a background color for the status bar
      statusBarIconBrightness: Brightness.dark,  // Use dark icons for light backgrounds
    ),
  );

  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
    ],
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;

    return ScreenUtilInit(
      builder: (context, child) => MaterialApp(
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
            child: child!,
          );
        },
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        home: Details(),
      ),
      designSize: Size(375, 812),
    );
  }
}

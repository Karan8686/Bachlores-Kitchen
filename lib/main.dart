import 'package:batchloreskitchen/Logins/NewL.dart';
import 'package:batchloreskitchen/Logins/login.dart';
import 'package:batchloreskitchen/Onboard/PageView.dart';
import 'package:batchloreskitchen/Onboard/pages.dart';
import 'package:batchloreskitchen/Pages/Home.dart';


import 'package:batchloreskitchen/prrovider/Cart/Cart_provider.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:batchloreskitchen/Pages/NavigationBar.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:provider/provider.dart';
import 'package:telephony/telephony.dart';
import 'package:batchloreskitchen/providers/address_provider.dart';

import 'Pages/theme.dart'; // Add this import

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final Telephony telephony = Telephony.instance;
  bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:Brightness.dark,
    ),
  );

  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
    ],
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => AddressProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
          themeMode: ThemeMode.light,
                // Enable system theme mode
        home: auth.currentUser != null ? const AestheticBottomNavigation() : const Log(),
        //Home(),
        //View1(),
        //Login(p:"8655547603",c:"123456"),
       // OrderTrackingPage(),
        //SettingsPage()
      ),
      designSize: const Size(360, 690),
      splitScreenMode: true,
      minTextAdapt: true,
    );
  }
}
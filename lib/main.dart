import 'package:batchloreskitchen/Logins/NewL.dart';
import 'package:batchloreskitchen/Logins/login.dart';
import 'package:batchloreskitchen/Onboard/PageView.dart';
import 'package:batchloreskitchen/Pages/Home.dart';
import 'package:batchloreskitchen/Pages/cart.dart';
import 'package:batchloreskitchen/Pages/details.dart';
import 'package:batchloreskitchen/firebase_options.dart';
import 'package:batchloreskitchen/widgets/ThemeProvider.dart';
import 'package:batchloreskitchen/widgets/restart_widget.dart';
import 'package:batchloreskitchen/widgets/restart_widget.dart';
import 'package:batchloreskitchen/widgets/theme_aware.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:batchloreskitchen/Pages/NavigationBar.dart';
import 'package:flutter/services.dart';
import 'package:batchloreskitchen/Pages/Map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:provider/provider.dart';
import 'package:telephony/telephony.dart';


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

  runApp( RestartWidget(
      child:MyApp()
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
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
            child: child!,
          );
        },
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
          themeMode: ThemeMode.light,
                // Enable system theme mode
        home: auth.currentUser != null ? const BottomBar() : const Log(),

      ),
      designSize: Size(375, 812),
    );
  }
}
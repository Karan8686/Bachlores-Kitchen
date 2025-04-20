import 'package:batchloreskitchen/Logins/NewL.dart';
import 'package:batchloreskitchen/Pages/Map.dart';
import 'package:batchloreskitchen/prrovider/Cart/Cart_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:batchloreskitchen/Pages/NavigationBar.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:batchloreskitchen/Pages/no_network.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:batchloreskitchen/providers/address_provider.dart';
import 'Pages/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();

  // Enable maximum refresh rate
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Set preferred refresh rate to highest
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
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
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: NetworkAwareWidget(
          child: auth.currentUser != null ? const AestheticBottomNavigation() : const Log(),
        ),
      ),
      designSize: const Size(360, 690),
      splitScreenMode: true,
      minTextAdapt: true,
    );
  }
}

class NetworkAwareWidget extends StatefulWidget {
  final Widget child;

  const NetworkAwareWidget({Key? key, required this.child}) : super(key: key);

  @override
  _NetworkAwareWidgetState createState() => _NetworkAwareWidgetState();
}

class _NetworkAwareWidgetState extends State<NetworkAwareWidget> {
  late Stream<ConnectivityResult> _connectivityStream;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _connectivityStream = Connectivity().onConnectivityChanged;

    // Check the initial connectivity status
    _checkInitialConnectivity();

    // Listen for connectivity changes
    _connectivityStream.listen((ConnectivityResult result) {
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
    });
  }

  Future<void> _checkInitialConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOffline = connectivityResult == ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isOffline) {
      return const NoNetworkScreen();
    }
    return widget.child;
  }
}

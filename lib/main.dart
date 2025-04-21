import 'package:batchloreskitchen/Logins/NewL.dart';
import 'package:batchloreskitchen/Pages/Map.dart';
import 'package:batchloreskitchen/Pages/cart.dart';
import 'package:batchloreskitchen/Pages/recent_order.dart';
import 'package:batchloreskitchen/prrovider/Cart/Cart_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:batchloreskitchen/Pages/NavigationBar.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:batchloreskitchen/Pages/no_network.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:batchloreskitchen/providers/address_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Pages/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Get saved language
  final prefs = await SharedPreferences.getInstance();
  final savedLanguage = prefs.getString('selectedLanguage') ?? 'English';
  
  // Get language code
  final languageCode = _getLanguageCode(savedLanguage);
  
  // Initialize Awesome Notifications
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'order_channel',
        channelName: 'Order Notifications',
        channelDescription: 'Notifications for order updates',
        defaultColor: Colors.green,
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      )
    ],
    debug: true
  );

  // Request notification permissions
  await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

  // Set up notification action listeners
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: (ReceivedAction receivedAction) async {
      if (receivedAction.buttonKeyPressed == 'OPEN_CART') {
        // Navigate to cart screen
        Navigator.of(GlobalKey<NavigatorState>().currentContext!).pushNamed('/cart');
      } else if (receivedAction.buttonKeyPressed == 'VIEW_ORDER') {
        final orderId = receivedAction.payload?['orderId'];
        if (orderId != null) {
          Navigator.of(GlobalKey<NavigatorState>().currentContext!).push(
            MaterialPageRoute(builder: (context) => RecentOrder()),
          );
        }
      }
    }
  );

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
      child: MyApp(locale: Locale(languageCode)),
    ),
  );
}

String _getLanguageCode(String language) {
  switch (language) {
    case 'English': return 'en';
    case 'Spanish': return 'es';
    case 'French': return 'fr';
    case 'German': return 'de';
    case 'Hindi': return 'hi';
    default: return 'en';
  }
}

class MyApp extends StatelessWidget {
  final Locale locale;
  
  const MyApp({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;

    return ScreenUtilInit(
      builder: (context, child) => MaterialApp(
        title: 'Batchlores Kitchen',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: locale,
        supportedLocales: const [
          Locale('en'), // English
          Locale('es'), // Spanish
          Locale('fr'), // French
          Locale('de'), // German
          Locale('hi'), // Hindi
        ],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        navigatorKey: GlobalKey<NavigatorState>(), // Add this for notification navigation
        routes: {
          '/cart': (context) => const CartScreen(),
        },
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

class _NetworkAwareWidgetState extends State<NetworkAwareWidget> with WidgetsBindingObserver {
  bool _isOffline = true; // Start with offline to force initial check
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initConnectivity();
    }
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('Couldn\'t check connectivity status: $e');
    }
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    final isOffline = result == ConnectivityResult.none;
    if (mounted && _isOffline != isOffline) {
      setState(() {
        _isOffline = isOffline;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _isOffline 
        ? const NoNetworkScreen()
        : widget.child,
    );
  }
}

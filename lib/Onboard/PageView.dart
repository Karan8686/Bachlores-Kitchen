import 'package:batchloreskitchen/Onboard/pages.dart';
import 'package:batchloreskitchen/Onboard/spalsh.dart';
import 'package:batchloreskitchen/Pages/NavigationBar.dart';
import 'package:batchloreskitchen/widgets/widget_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class View1 extends StatefulWidget {
  const View1({super.key});

  @override
  State<View1> createState() => _View1State();
}

class _View1State extends State<View1> with WidgetsBindingObserver {
  final controller = PageController();
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestPermissions();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App has resumed, check permissions again
      checkPermissions();
    }
  }

  Future<void> requestPermissions() async {
    try {
      // Check and request location permission
      var locationStatus = await Permission.location.status;
      if (!locationStatus.isGranted) {
        await Permission.location.request();
      }

      // Check and request storage permissions for photos and videos
      var photosStatus = await Permission.photos.status;
      if (!photosStatus.isGranted) {
        await Permission.photos.request();
      }

      var videosStatus = await Permission.videos.status;
      if (!videosStatus.isGranted) {
        await Permission.videos.request();
      }
    } catch (e) {
      print('Error requesting permissions: $e');
    }
  }

  Future<void> checkPermissions() async {
    try {
      // Check location permission
      if (await Permission.location.isGranted) {
        // Location permission is granted
      } else {
        // Location permission is not granted, handle accordingly
      }

      // Check storage permissions for photos and videos
      if (await Permission.photos.isGranted) {
        // Photos permission is granted
      } else {
        // Photos permission is not granted, handle accordingly
      }

      if (await Permission.videos.isGranted) {
        // Videos permission is granted
      } else {
        // Videos permission is not granted, handle accordingly
      }
    } catch (e) {
      print('Error checking permissions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lottie animation file paths
    String s = "images/VerityFood.json";
    String s2 = "images/QualityFood.json";
    String s3 = "images/Animation3.json";

    return Scaffold(
      body: Container(
        height: 735.h,
        child: PageView(
          onPageChanged: (index) {
            setState(() {
              isLastPage = index == 2;
            });
          },
          controller: controller,
          children: [
            page(
              imagePath: s,
              content1: "Delivery in 30 min",
              content2: "Get all your loved foods in once place to eat",
              content3: "just by placing an order.",
              backgroundColor: Colors.red.withOpacity(0.1),
            ),
            page(
              imagePath: s2,
              content1: "Delivery in 30 min",
              content2: "Get all your loved foods in once place to eat",
              content3: "just by placing an order.",
              backgroundColor: Colors.green.withOpacity(0.1),
            ),
            page(
              imagePath: s3,
              content1: "All Your Favorites",
              content2: "Variety of food available here only for You",
              content3: "Give your tongue new taste.",
              backgroundColor: Colors.blue.withOpacity(0.1),
            ),
          ],
        ),
      ),

      // Bottom Part
      bottomSheet: isLastPage
          ? TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          backgroundColor: Colors.white,
          minimumSize: const Size.fromHeight(85),
        ),
        onPressed: () {
          // Use ScaleTransition animation for navigation
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => BottomBar(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
            ),
          );
        },
        child: Text(
          "Get Started",
          style: AppWidget.boldTextFeildSstyleTop1(),
        ),
      )
          : Container(
        decoration: BoxDecoration(color: Colors.white),
        height: 80.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: TextButton(
                onPressed: () {
                  controller.animateToPage(
                    2,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeIn,
                  );
                },
                child: Text(
                  "Skip",
                  style: AppWidget.boldTextFeildSstyleTop1(),
                ),
              ),
            ),
            Center(
              child: SmoothPageIndicator(
                controller: controller,
                count: 3,
                effect: JumpingDotEffect(
                  activeDotColor: Colors.deepOrangeAccent,
                  dotHeight: 15.h,
                  radius: 80,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20.w),
              child: TextButton(
                onPressed: () {
                  controller.nextPage(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeInOutQuad,
                  );
                },
                child: Text(
                  "Next",
                  style: AppWidget.boldTextFeildSstyleTop1(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Function to create page with image and content
Widget page({
  required String imagePath,
  required String content1,
  required String content2,
  required String content3,
  required Color backgroundColor,
}) {
  return Container(
    color: backgroundColor, // Use the provided background color
    child: Column(
      children: [
        SizedBox(height: 150.h),
        Lottie.asset(
          imagePath, // Path to the Lottie animation file
          fit: BoxFit.cover,
          height: 290.h,
          filterQuality: FilterQuality.high,
        ),
        SizedBox(height: 50.h),
        // First content row with bold text
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              content1,
              style: TextStyle(
                fontSize: 22.sp, // Using ScreenUtil for responsive font size
                fontFamily: 'Poppins',
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        // Second content row with medium text
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              content2,
              style: TextStyle(
                fontSize: 16.sp, // Using ScreenUtil for responsive font size
                fontFamily: 'Poppins',
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        // Third content row with medium text
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              content3,
              style: TextStyle(
                fontSize: 16.sp, // Using ScreenUtil for responsive font size
                fontFamily: 'Poppins',
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

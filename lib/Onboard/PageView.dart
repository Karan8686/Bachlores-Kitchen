import 'package:batchloreskitchen/Onboard/pages.dart';
import 'package:batchloreskitchen/Pages/NavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Page Widget
Widget page({
  required String imagePath,
  required String content1,
  required String content2,
  required String content3,
  required Color backgroundColor,
  required String heroTag,
}) {
  return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          color: backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: heroTag,
                child: Lottie.asset(
                  imagePath,
                  height: 300.h,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              )
                  .animate()
                  .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
              )
                  .fade(
                duration: const Duration(milliseconds: 600),
              ),
              SizedBox(height: 40.h),
              Column(
                children: [
                  Text(
                    content1,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontSize: 35.sp
                    ),
                  )
                      .animate()
                      .fadeIn(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 200),
                  )
                      .slideY(
                    begin: 0.2,
                    end: 0,
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                  ),
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      content2,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 18.sp
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 400),
                  )
                      .slideY(
                    begin: 0.2,
                    end: 0,
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    content3,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  )
                      .animate()
                      .fadeIn(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 600),
                  )
                      .slideY(
                    begin: 0.2,
                    end: 0,
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                  ),
                ],
              ),
            ],
          ),
        );
      }
  );
}

class View1 extends StatefulWidget {
  const View1({super.key});

  @override
  State<View1> createState() => _View1State();
}

class _View1State extends State<View1> with TickerProviderStateMixin {
  final PageController controller = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String s = "images/VerityFood.json";
    String s2 = "images/QualityFood.json";
    String s3 = "images/Animation3.json";

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.tertiary.withOpacity(0.1),
                ],
              ),
            ),
          ),
          PageView(
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == 2;
              });
            },
            controller: controller,
            children: [
              page(
                imagePath: s,
                content1: "Quick Delivery",
                content2: "Delicious food at your doorstep",
                content3: "in just 30 minutes",
                backgroundColor: theme.colorScheme.primary.withOpacity(0.05),
                heroTag: "page1",
              ),
              page(
                imagePath: s2,
                content1: "Premium Quality",
                content2: "Savor the finest ingredients",
                content3: "crafted just for you",
                backgroundColor: theme.colorScheme.secondary.withOpacity(0.05),
                heroTag: "page2",
              ),
              page(
                imagePath: s3,
                content1: "Endless Variety",
                content2: "Explore a world of flavors",
                content3: "all in one place",
                backgroundColor: theme.colorScheme.tertiary.withOpacity(0.05),
                heroTag: "page3",
              ),
            ],
          )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 600))
              .slideY(
            begin: 0.2,
            end: 0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
          ),
        ],
      ),
      bottomSheet: Container(
        height: 90.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface.withOpacity(0),
              theme.colorScheme.tertiary.withOpacity(0.1),
            ],
          ),
        ),
        child: isLastPage
            ? Center(
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                  const AestheticBottomNavigation(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            },
            child: Container(
              width: 200.w,
              height: 50.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  "Get Started",
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            )
          ))
            : Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  controller.animateToPage(
                    2,
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeInCirc,
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
                  .animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              )
                  .shimmer(
                duration: const Duration(milliseconds: 1500),
                delay: const Duration(milliseconds: 200),
              ),
              SmoothPageIndicator(
                controller: controller,
                count: 3,
                effect: WormEffect(
                  dotColor: theme.colorScheme.primary.withOpacity(0.2),
                  activeDotColor: theme.colorScheme.primary,
                  dotHeight: 8.h,
                  dotWidth: 8.w,
                  spacing: 8,
                  strokeWidth: 1.5,
                  paintStyle: PaintingStyle.fill,
                ),
              )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 600))
                  .scale(delay: const Duration(milliseconds: 300)),
              GestureDetector(
                onTap: () {
                  controller.nextPage(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "Next",
                    style: TextStyle(
                      color: theme.colorScheme.surface,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
                  .animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              )
                  .shimmer(
                duration: const Duration(milliseconds: 1500),
                delay: const Duration(milliseconds: 200),
              ),]
      ),
            ))
    );
  }
}
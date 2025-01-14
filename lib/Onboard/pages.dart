import 'package:batchloreskitchen/widgets/widget_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

// Function to create a page with image and content
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

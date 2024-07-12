
import 'package:flutter_screenutil/flutter_screenutil.dart';


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppWidget{
   BuildContext get context => context;

  static TextStyle boldTextFeildSstyle()
  {
    return  const TextStyle(
      fontSize:20,
      color: Colors.black,
      fontWeight:FontWeight.bold,
      fontFamily:'Poppins',
    );

  }

  static TextStyle boldTextFeildSstylelight()
  {
    return const TextStyle(
      fontSize:18.0,
      color: Colors.grey,
      fontWeight:FontWeight.w500,
      fontFamily:'Poppins',
    );


  }
  static TextStyle boldTextFeildSstyleSmall()
  {
    return const TextStyle(
      fontSize:13.0,
      color: Colors.grey,
      fontWeight:FontWeight.w700,
      fontFamily:'Poppins',
    );


  }
  static TextStyle boldTextFeildSstyleSmallDark()
  {
    return const TextStyle(
      fontSize:16.0,
      color: Colors.black54,
      fontWeight:FontWeight.w700,
      fontFamily:'Poppins',

    );


  }
  static TextStyle boldTextFeildSstyleTop()
  {
    return const TextStyle(
      fontSize:18.0,
      color: Colors.black,
      fontWeight:FontWeight.w700,
      fontFamily:'Poppins',
    );

  }

static TextStyle boldTextFeildSstyleWhite()
  {
    return const TextStyle(
      fontSize:18.0,
      color: Colors.white,
      fontWeight:FontWeight.bold,
      fontFamily:'Poppins',
    );

  }
   static TextStyle boldTextFeildSstyleTop1()
  {
    return const TextStyle(
      fontSize:18.0,
      color: Colors.deepOrangeAccent,
      fontWeight:FontWeight.w700,
      fontFamily:'Poppins',
    );


  }


}
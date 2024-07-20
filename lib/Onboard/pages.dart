import 'package:batchloreskitchen/widgets/widget_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

Widget page(image,content1,content2,content3,Color color)
{


  return Container(
    color: Colors.white,

      child: Column(
        children: [
          SizedBox(height: 150.h,),
          Lottie.asset(image,
          fit: BoxFit.cover,
            height: 290.h,
            filterQuality: FilterQuality.high
          ),

          SizedBox(height: 50.h,),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(content1,style:TextStyle(
                fontSize: 22,
                fontFamily: 'Poppins',
                color: Colors.black,
                fontWeight: FontWeight.bold
              ),
              )
            ],

          ),
          SizedBox(height: 20.h,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(content2,style:TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                  fontWeight: FontWeight.w500
              ),),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(content3,style:TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                  fontWeight: FontWeight.w500
              ),),
            ],
          )
        ],
      ),


  );
}
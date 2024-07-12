

import 'package:flutter/material.dart';
import 'package:batchloreskitchen/widgets/widget_support.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class Details extends StatefulWidget {
  const Details({super.key});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  int n=1;

  add()
  {
    if(n<=9) {
      n = n + 1;
    }
  }

  remove()
  {
    if(n>1) {
      n = n - 1;
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(


        margin: EdgeInsets.symmetric(vertical: 22.h,horizontal: 16.w),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
              child: Icon(Icons.arrow_back_ios_new_rounded,size: 30.0.sp),



          ),





            Container(
              child: Image.asset("images/SaladQ.png",
                width:400.w,
                height: 320.h,
                fit: BoxFit.fill,
              ),
            ),


            Container(



                child:Row(





                  children: [

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text("Veggie Taco Hash",style: AppWidget.boldTextFeildSstyle(),),
                        Text("Healthy and Fressh  ",style: AppWidget.boldTextFeildSstyle()),
                      ],
                    ),
                    SizedBox(width: 47.w,),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              add();
                            });
                          },
                          child: Column(
                            children: [
                              Icon(Icons.add_circle,size:28.sp,color: Colors.deepOrangeAccent,),

                            ],
                          ),
                        ),

                        SizedBox(
                          width: 30.w,

                            child: Center(
                              child: Text("$n",style:const TextStyle(fontSize:20 ,),
                              ),
                            )
                        ),

                        InkWell(
                          onTap: () {
                            setState(() {
                              remove();
                            });
                          },
                          child: Column(
                            children: [
                              Icon(Icons.remove_circle,size:28.sp,color: Colors.deepOrangeAccent,),

                            ],
                          ),
                        ),

                      ],
                    ),




                  ],
                ),


            ),
            SizedBox(height: 8.h,),
            Text("Garden salads use a base of leafy greens such as lettuce, arugula or rocket, kale or spinach.",style: AppWidget.boldTextFeildSstylelight(),),
            SizedBox(height: 20.h,),
            Row(
              children: [
                Text("Delivary Time",style: AppWidget.boldTextFeildSstyleTop(),),
                SizedBox(width: 14.w),
                Icon(Icons.alarm_outlined,color: Colors.orangeAccent[700],),
                SizedBox(width: 14.w,),
                Text("30min",style: AppWidget.boldTextFeildSstyleTop(),)
              ],
            ),
            Spacer(),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),

              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Price",style: AppWidget.boldTextFeildSstyle(),),
                      Text("\$25",style: AppWidget.boldTextFeildSstyleTop1(),),
                    ],
                  ),
                  //SizedBox(width:100),
                  SizedBox(
                    height: 50.h,
                    width: 150.w,
                    child: TextButton(onPressed: () {

                    },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),

                        ),
                        child: Text("Add to Cart",style: AppWidget.boldTextFeildSstyleWhite(),
                        )
                    ),

                  )

                ],
              ),
            )
          ],

        ),



      ),

    );

  }
}


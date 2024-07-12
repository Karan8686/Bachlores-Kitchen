import 'package:batchloreskitchen/widgets/widget_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:batchloreskitchen/Logins/login.dart';
import 'package:batchloreskitchen/Pages/NavigationBar.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:batchloreskitchen/Logins/NewL.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

@override

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),

        child: Stack(
        
            children: [
        
        
              Image.asset("images/log3.jpg",
                height:330.h,
                width: 400.w,
                fit:BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
        
        
        
              Container(
                margin: EdgeInsets.symmetric(vertical: 300.h),
                width: 400.w,
                height: 500.h,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft:Radius.circular(40.r),topRight: Radius.circular(40.r))
                ),
              
                child: Column(
                  children: [
                    Row(
              
                      children: [
              
                        Padding(
                          padding:  EdgeInsets.symmetric(vertical: 20.h,horizontal: 20.w),
                          child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.arrow_circle_left_rounded,size:38.sp,color:Colors.deepOrangeAccent,)),
                        ),
                        Padding(
                          padding:  EdgeInsets.symmetric(vertical: 20.h),
                          child: Container(
                            width: 180.h,
                              child: Text("We Texted You a verification code.",style: AppWidget.boldTextFeildSstyleSmall(),)),
                        ),
                      ],
                    ),
              
                    Padding(
                      padding:  EdgeInsets.only(top: 40.h,left: 23.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
              
                        children: [
              
                          Padding(
                            padding: EdgeInsets.only(left: 52.w),
                            child: OtpTextField(
                              borderWidth: 3,

                              decoration: InputDecoration(
                               border: OutlineInputBorder(
              
                                 borderSide: BorderSide(
                                   color: Colors.red,
                                 ),
              
                               ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                  )
                                )
                              ),
                              numberOfFields: 5,
                              borderColor: Colors.black,
                              //set to true to show as box or false to show as dash
                              showFieldAsBox: true,
                              //runs when a code is typed in
                              onCodeChanged: (String code) {
                                //handle validation or checks here
                              },
                              //runs when every textfield is filled
                              onSubmit: (String verificationCode){
                                showDialog(
                                    context: context,
                                    builder: (context){
                                      return AlertDialog(
                                        title: Text("Verification Code"),
                                        content: Text('Code entered is $verificationCode'),
                                      );
                                    }
                                );
                              }, // end onSubmit
                            ),
                          ),
              
                        ],
              
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top:8.h,left:130.w),
                          child: Text("Didnt got code?",style: AppWidget.boldTextFeildSstyleSmall(),),
                        )
                      ],
                    ),

                    SizedBox(height:56.h,),
                    SizedBox(
                      height: 50.h,
                      width: 100.w,
                      child: TextButton (onPressed: () {
                            Navigator.push(context, _createRoute(BottomBar()));
                      },
                          style: ButtonStyle(
                            elevation:MaterialStateProperty.all(10),
                            backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),

                          ),
                          child: Text("Login",style: AppWidget.boldTextFeildSstyleWhite(),)
                      ),
                    ),
                    Spacer(),
                    Row(

                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(width :350.w,child: Text("By Clicking you accepted terms and conditions",style: AppWidget.boldTextFeildSstyleSmall(),))
                      ],
                    )
                  ],
              
                ),
              ),
        
            ]
        ),
      ),
    );
  }
}

Route _createRoute(Widget child) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

import 'package:batchloreskitchen/widgets/widget_support.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:batchloreskitchen/Logins/login.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
class Log extends StatefulWidget {
  const Log({super.key});
  static String verify='';

  @override

  State<Log> createState() => _LogState();
}

class _LogState extends State<Log> {

  late String number;
  late String code;
  @override

  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;

    return Scaffold(

      body: Stack(
          children: [
            Image.asset("images/logo.jpeg",
              height: 530.h,
              width: 400.w,
              fit: BoxFit.fitHeight,
              filterQuality: FilterQuality.high,
            ),

            SingleChildScrollView(

              scrollDirection: Axis.vertical,
              child: Container(
                margin: EdgeInsets.only(top:500.h),
                width: 400.w,
                height: 310.h,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft:Radius.circular(40.r),topRight: Radius.circular(40.r))
                ),

                child: Column(

                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding:  EdgeInsets.only(top:25.h,left: 20.w),
                          child: Text("Login",style:TextStyle(
                              fontSize: 30.sp,
                              fontFamily: "poppins",
                              color: Colors.black
                          )),
                        ),
                      ],
                    ),
                    SizedBox(height: 39.h,),
                    Padding(
                      padding:  EdgeInsets.only(left:25.w,right: 25.w),
                      child: SizedBox(
                        height: 70.h,
                        child: IntlPhoneField(
                          onChanged: (value) {
                            number= value.number;
                            code = value.countryCode;

                          },
                          dropdownTextStyle:AppWidget.boldTextFeildSstyleSmallDark(),

                          decoration:InputDecoration(
                              hintText: "Enter a Number",
                              hintStyle: AppWidget.boldTextFeildSstyleSmall(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 1.5,

                                ),
                                borderRadius: BorderRadius.circular(40.r),
                              ),
                              border: OutlineInputBorder(

                                borderRadius: BorderRadius.circular(40.r),
                                borderSide: BorderSide(
                                    width: 1.5,
                                    color: Colors.black
                                ),
                              )
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height:30.h,),
                    SizedBox(
                      height: 50.h,
                      width: 110.w,
                      child: TextButton(onPressed: () async {
                        await FirebaseAuth.instance.verifyPhoneNumber(
                          phoneNumber: code+number,
                          verificationCompleted: (PhoneAuthCredential credential) {},
                          verificationFailed: (FirebaseAuthException e) {},
                          codeSent: (String verificationId, int? resendToken) {
                            Log.verify=verificationId;
                          },
                          codeAutoRetrievalTimeout: (String verificationId) {},
                        );
                        Navigator.push(context, _createRoute(Login()));
                      },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),

                          ),
                          child: Text("Get Otp",style: AppWidget.boldTextFeildSstyleWhite(),)
                      ),
                    )




                  ],






                ),


              ),



            ),
          ]
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
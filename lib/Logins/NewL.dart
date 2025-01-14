import 'package:batchloreskitchen/widgets/widget_support.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:batchloreskitchen/Logins/login.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Log extends StatefulWidget {
  const Log({super.key});
  static String verify = '';

  @override
  State<Log> createState() => _LogState();
}

class _LogState extends State<Log> {
  late String number;
  late String code;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            "images/logo.jpeg",
            height: 530.h,
            width: 400.w,
            fit: BoxFit.fitHeight,
            filterQuality: FilterQuality.high,
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Spacer(),
                        // Form Container
                        Container(
                          width: 400.w,
                          height: 310.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40.r),
                              topRight: Radius.circular(40.r),
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Login Title
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 25.h, left: 20.w),
                                      child: Text(
                                        "Login",
                                        style: TextStyle(
                                          fontSize: 30.sp,
                                          fontFamily: "poppins",
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 39.h),
                                // Phone Number Input
                                Padding(
                                  padding: EdgeInsets.only(left: 25.w, right: 25.w),
                                  child: SizedBox(
                                    height: 70.h,
                                    child: IntlPhoneField(
                                      initialCountryCode: "IN",
                                      validator: (value) {
                                        if (value == null || value.number.isEmpty) {
                                          return 'Please enter your phone number';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        number = value.number;
                                        code = value.countryCode;
                                      },
                                      dropdownTextStyle: AppWidget.boldTextFeildSstyleSmallDark(),
                                      decoration: InputDecoration(
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
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 30.h),
                                // Get OTP Button
                                SizedBox(
                                  height: 50.h,
                                  width: 110.w,
                                  child: TextButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        await FirebaseAuth.instance.verifyPhoneNumber(
                                          phoneNumber: code + number,
                                          verificationCompleted: (PhoneAuthCredential credential) {},
                                          verificationFailed: (FirebaseAuthException e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text(e.message ?? 'Verification failed')),
                                            );
                                          },
                                          codeSent: (String verificationId, int? resendToken) {
                                            Log.verify = verificationId;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('OTP sent successfully')),
                                            );
                                          },
                                          codeAutoRetrievalTimeout: (String verificationId) {},
                                        );
                                        Navigator.of(context).pushReplacement(
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) => Login(p: number, c: code),
                                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                              return FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              );
                                            },
                                          ),
                                        );
                                      }
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                                    ),
                                    child: Text(
                                      "Get Otp",
                                      style: AppWidget.boldTextFeildSstyleWhite(),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

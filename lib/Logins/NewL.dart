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
  late String code;
  late String number;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            "images/logo.jpeg",
            height: 450.h,
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
                          height: 400.h, // Increased height
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40.r),
                              topRight: Radius.circular(40.r),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, -5),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Welcome Text
                                Padding(
                                  padding: EdgeInsets.only(top: 25.h, left:3.w),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Welcome",
                                        style: theme.textTheme.displayLarge?.copyWith(
                                          fontSize: 32.sp,
                                          fontFamily: "poppins",
                                          color: theme.colorScheme.secondary,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        "Enter your phone number to continue",
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontSize: 16.sp,
                                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                                          fontFamily: "poppins"
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 30.h),

                                // Phone Number Input
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Phone Number",
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      SizedBox(
                                        height: 80.h,
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
                                          dropdownTextStyle: TextStyle(
                                            color: theme.colorScheme.onSurface,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: "Enter your number",
                                            hintStyle: TextStyle(
                                              color: theme.colorScheme.primary.withOpacity(0.6),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: theme.colorScheme.secondary,
                                                width: 2,
                                              ),
                                              borderRadius: BorderRadius.circular(40.r),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(40.r),
                                              borderSide: BorderSide(
                                                width: 1.5,
                                                color: theme.colorScheme.onSurface.withOpacity(0.3),
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: theme.colorScheme.surface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 30.h),

                                // Get OTP Button
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 55.h,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          await FirebaseAuth.instance.verifyPhoneNumber(
                                            phoneNumber: code + number,
                                            verificationCompleted: (PhoneAuthCredential credential) {},
                                            verificationFailed: (FirebaseAuthException e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(e.message ?? 'Verification failed'),
                                                  backgroundColor: theme.colorScheme.error,
                                                ),
                                              );
                                            },
                                            codeSent: (String verificationId, int? resendToken) {
                                              Log.verify = verificationId;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('OTP sent successfully'),
                                                  backgroundColor: theme.colorScheme.primary,
                                                ),
                                              );
                                            },
                                            codeAutoRetrievalTimeout: (String verificationId) {},
                                          );
                                          Navigator.of(context).pushReplacement(
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation, secondaryAnimation) =>
                                                  Login(p: number, c: code),
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
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.colorScheme.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(40.r),
                                        ),
                                        elevation: 2,
                                      ),
                                      child: Text(
                                        "Get OTP",
                                        style: theme.textTheme.labelLarge?.copyWith(
                                          fontSize: 18.sp,
                                          color: theme.colorScheme.surface
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Terms and Conditions
                                Padding(
                                  padding: EdgeInsets.only(top: 20.h),
                                  child: Text(
                                    "By continuing, you agree to our Terms & Conditions",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 14.sp,
                                      color: theme.colorScheme.onSurface.withValues(alpha: .6),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
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
import 'package:batchloreskitchen/Logins/login.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Log extends StatefulWidget {
  const Log({super.key});
  static String verify = '';

  @override
  State<Log> createState() => _LogState();
}

class _LogState extends State<Log> with WidgetsBindingObserver {
  late String code;
  late String number;
  final _formKey = GlobalKey<FormState>();

  // Variables to track keyboard state
  bool _isKeyboardVisible = false;
  double _containerHeight = 375.h;



  // Replace the existing _requestPermissions method with this improved version
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Use Future.delayed to ensure the widget is mounted
    Future.delayed(Duration.zero, () {
      if (mounted) {
      
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Detect keyboard visibility
  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    if (mounted) {
      setState(() {
        _isKeyboardVisible = bottomInset > 0;
        _containerHeight = _isKeyboardVisible ? 500.h : 400.h; // Adjust height dynamically
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false, // Disable automatic resizing
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
                        const Spacer(),
                        // Form Container with AnimatedContainer
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: 400.w,
                          height: _containerHeight, // Dynamically adjusted height
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
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Welcome Text
                                Padding(
                                  padding: EdgeInsets.only(top: 25.h, left: 3.w),
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
                                      )
                                          .animate()
                                          .fade(duration: 700.ms, delay: 200.ms)
                                          .scale(duration: 700.ms, curve: Curves.easeOut),
                                      SizedBox(height: 8.h),
                                      Text(
                                        "Enter your phone number to continue",
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontSize: 16.sp,
                                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                                          fontFamily: "poppins",
                                        ),
                                      ).animate().fade(duration: 700.ms, delay: 400.ms),
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
                                      ).animate().fade(duration: 500.ms, delay: 600.ms),
                                      SizedBox(height: 8.h),
                                      SizedBox(
                                        height: 50.h, // Increased height
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
                                      ).animate().slideY(duration: 500.ms, begin: 1, end: 0),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 30.h),
                                // Get OTP Button
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 48.h,
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
                                                  content: const Text('OTP sent successfully'),
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
                                          color: theme.colorScheme.surface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ).animate().fade(duration: 500.ms, delay: 800.ms),
                                // Terms and Conditions
                                SizedBox(height: 27.h),
                                Padding(
                                  padding: EdgeInsets.only(top: 20.h),
                                  child: Text(
                                    "By continuing, you agree to our Terms & Conditions",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 14.sp,
                                      color: theme.colorScheme.onSurface.withAlpha(150),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ).animate().fade(duration: 500.ms, delay: 1000.ms),
                              ],
                            ),
                          ),
                        ),
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
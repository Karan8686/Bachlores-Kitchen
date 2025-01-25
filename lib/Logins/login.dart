import 'package:batchloreskitchen/Onboard/PageView.dart';
import 'package:batchloreskitchen/widgets/widget_support.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:batchloreskitchen/Pages/NavigationBar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:batchloreskitchen/Logins/NewL.dart';
import 'dart:async';
import 'package:vibration/vibration.dart';

class Login extends StatefulWidget {
  final String p;
  final String c;

  const Login({
    Key? key,
    required this.p,
    required this.c,
  }) : super(key: key);

  static bool h = false;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final String sms = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _timer;
  int _secondsRemaining = 30;
  bool _otpResent = false;
  bool _isLoading = false;
  AnimationController? _animationController;
  Animation<Offset>? _animation;
  bool _otpError = false;
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupFocusNodes();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0),
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_animationController!);
  }

  void _setupFocusNodes() {
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          setState(() => _otpError = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController?.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void startCountdown(BuildContext context) {
    if (_isLoading) return;

    setState(() {
      _secondsRemaining = 30;
      _isLoading = true;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        setState(() => _isLoading = false);
        _resendOTP();
      }
    });
  }

  Future<void> _resendOTP() async {
    if (!_otpResent && !_isLoading) {
      await _sendNewOTP();
      setState(() => _otpResent = true);
    }
  }

  Widget _buildOTPFields(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SlideTransition(
        position: _animation!,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 45.w,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: _otpError
                          ? theme.colorScheme.error.withOpacity(0.1)
                          : theme.shadowColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _otpControllers[index],
                  focusNode: _focusNodes[index],
                  maxLength: 1,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _otpError ? theme.colorScheme.error : theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    counterText: "",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: _otpError ? theme.colorScheme.error : theme.colorScheme.outline,
                        width: _otpError ? 2.0 : 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: _otpError
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: _otpError ? theme.colorScheme.error : theme.colorScheme.outline,
                        width: _otpError ? 2.0 : 1.0,
                      ),
                    ),
                    filled: true,
                    fillColor: _otpError
                        ? theme.colorScheme.error.withOpacity(0.05)
                        : theme.colorScheme.surface,
                  ),
                  onChanged: (value) => _handleOTPInput(value, index),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }


  void _handleOTPInput(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() => _otpError = false);

    // Auto-verify when all fields are filled
    if (_otpControllers.every((controller) =>
    controller.text.isNotEmpty)) {
      _verifyOTP();
    }
  }

  Widget _buildResendButton(ThemeData theme) {
    return GestureDetector(
      onTap: () {
        if (!_otpResent && !_isLoading) {
          startCountdown(context);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: (!_otpResent && !_isLoading)
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surface,
          border: Border.all(
            color: (!_otpResent && !_isLoading)
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.refresh,
              size: 16.sp,
              color: (!_otpResent && !_isLoading)
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
            SizedBox(width: 8.w),
            Text(
              _isLoading
                  ? "$_secondsRemaining seconds"
                  : "Resend Code",
              style: theme.textTheme.bodySmall?.copyWith(
                color: (!_otpResent && !_isLoading)
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Stack(
          children: [
            // Top Background Container
            Container(
              height: 375.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer,
                  ],
                ),
              ),
              child: Image.asset(
                "images/log3.jpg",
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
            // Main Content Container
            Container(
              height: 530.h,
              margin: EdgeInsets.only(top: 280.h),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 10.r,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  _buildHeader(theme),
                  SizedBox(height: 40.h),
                  Text(
                    "Verify Your Number",
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Enter the code sent to ${widget.p}",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  _buildOTPFields(theme),
                  SizedBox(height: 20.h),
                  Center(child: _buildResendButton(theme)),
                  SizedBox(height: 40.h),
                  _buildVerifyButton(theme),
                  SizedBox(height: 45.h),
                  _buildTermsText(theme),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: theme.shadowColor.withValues(alpha: 0.3),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const Log(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 20.sp,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }




  Widget _buildVerifyButton(ThemeData theme) {
    return Center(
      child: SizedBox(
        height: 50.h,
        width: 200.w,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _verifyOTP,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isLoading
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.r),
            ),
            elevation: 2,
          ),
          child: _isLoading
              ? SizedBox(
            height: 20.h,
            width: 20.w,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.onSurface,
              ),
              strokeWidth: 2,
            ),
          )
              : Text(
            "Verify",
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: 18.sp,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsText(ThemeData theme) {
    return Text(
      "By continuing, you agree to our Terms of Service and Privacy Policy",
      textAlign: TextAlign.center,
      style: theme.textTheme.bodySmall?.copyWith(
        fontSize: 12.sp,
      ),
    );
  }

  Future<void> _verifyOTP() async {
    if (_isLoading) return;

    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      _showError("Please enter complete OTP");
      return;
    }

    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: Log.verify,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const View1(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);

              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end)
                  .chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
        Login.h = true;
      }
    } catch (e) {
      _handleVerificationError();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleVerificationError() {
    setState(() {
      _otpError = true;
      _otpControllers.forEach((controller) => controller.clear());
      _focusNodes[0].requestFocus();
    });

    _triggerErrorFeedback();
    _showError("Incorrect OTP. Please try again.");
  }

  Future<void> _triggerErrorFeedback() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 100, 100, 100]);
    }

    _animationController?.reset();
    _animationController?.forward().then((_) {
      _animationController?.reverse();
    });
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 18.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(8.w),
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _sendNewOTP() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: widget.p,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          _showError("Verification failed. Please try again.");
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            Log.verify = verificationId;
          });
          _showSuccess("New OTP has been sent!");
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      _showError("Failed to send OTP. Please try again.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 18.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(8.w),
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}


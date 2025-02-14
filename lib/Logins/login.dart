import 'package:batchloreskitchen/Onboard/PageView.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:batchloreskitchen/Logins/NewL.dart';
import 'dart:async';
import 'package:vibration/vibration.dart';

class Login extends StatefulWidget {
  const Login({
    Key? key,
    required this.p,
    required this.c,
  }) : super(key: key);

  static bool h = false;

  final String c;
  final String p;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  // Consolidate constants
  static const int _otpLength = 6;
  static const int _countdownDuration = 30;
  static const Duration _animationDuration = Duration(milliseconds: 700);
  static const Duration _otpTimeout = Duration(seconds: 60);
  
  // Group related variables
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  late final AnimationController _animationController;
  late final Animation<Offset> _animation;
  
  final List<FocusNode> _focusNodes = List.generate(_otpLength, (_) => FocusNode());
  final List<TextEditingController> _otpControllers = 
      List.generate(_otpLength, (_) => TextEditingController());

  bool _isLoading = false;
  bool _otpError = false;
  bool _otpResent = false;
  int _secondsRemaining = _countdownDuration;
  Timer? _timer;

  // Change from late final to nullable
  StreamSubscription<User?>? _authStateSubscription;

  @override
  void dispose() {
    _timer?.cancel();
    _authStateSubscription?.cancel();
    _animationController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeFocusNodes();
    // Initialize Firebase Auth state listener with proper error handling
    _authStateSubscription = _auth.authStateChanges().listen(
      (User? user) {
        // Handle auth state changes if needed
      },
      onError: (error) {
        if (mounted) {
          _showError("Authentication error occurred");
        }
      },
    );
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0),
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_animationController);
  }

  void _initializeFocusNodes() {
    for (int i = 0; i < _otpLength; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          setState(() => _otpError = false);
        }
      });
    }
  }

  void startCountdown(BuildContext context) {
    if (_isLoading) return;

    setState(() {
      _secondsRemaining = _countdownDuration;
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
        position: _animation,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_otpLength, (index) {
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
                    fontSize: 18.sp,
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
    if (value.isNotEmpty && index < _otpLength - 1) {
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
              color: theme.colorScheme.primary.withOpacity(0.1),
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
        height: 48.h,
        width: 200.w,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _verifyOTP,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isLoading
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.r),
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
              fontFamily: 'poppins',
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOTP() async {
    if (_isLoading) return;

    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != _otpLength) {
      _showError("Please enter complete OTP");
      return;
    }

    try {
      if (!mounted) return;
      setState(() => _isLoading = true);
      
      final credential = PhoneAuthProvider.credential(
        verificationId: Log.verify,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);

      if (!mounted) return;
      
      await _navigateToNextScreen();
      Login.h = true;
      
    } catch (e) {
      if (!mounted) return;
      _handleVerificationError();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateToNextScreen() {
    return Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const View1(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeInOut)).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  void _handleVerificationError() {
    setState(() {
      _otpError = true;
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    });

    _triggerErrorFeedback();
    _showError("Incorrect OTP. Please try again.");
  }

  Future<void> _triggerErrorFeedback() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 100, 100, 100]);
    }

    _animationController.reset();
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  void _showMessage({
    required String message,
    required bool isError,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18.sp
            ),
            SizedBox(width: 8.w),
            Expanded(child: Text(message, style: TextStyle(fontSize: 14.sp))),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(8.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  void _showError(String message) => _showMessage(message: message, isError: true);
  void _showSuccess(String message) => _showMessage(message: message, isError: false);

  Future<void> _sendNewOTP() async {
    if (_isLoading) return;

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: widget.p,
        verificationCompleted: (PhoneAuthCredential credential) {
          if (mounted) {
            // Handle auto verification if needed
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            _showError("Verification failed: ${e.message}");
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            setState(() {
              Log.verify = verificationId;
            });
            _showSuccess("New OTP has been sent!");
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (mounted) {
            // Handle timeout if needed
          }
        },
        timeout: _otpTimeout,
      );
    } catch (e) {
      if (mounted) {
        _showError("Failed to send OTP. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
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
                SizedBox(height: 20.h),
                Text(
                  "Verify Your Number",
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 30.sp,
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
                SizedBox(height: 25.h),
                
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: theme.shadowColor.withOpacity(0.3),
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
    );
  }
}


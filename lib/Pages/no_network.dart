import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoNetworkScreen extends StatelessWidget {
  const NoNetworkScreen({Key? key}) : super(key: key);

  Future<void> _retryConnection(BuildContext context) async {
    final result = await Connectivity().checkConnectivity();
    if (result != ConnectivityResult.none) {
      // Force rebuild of NetworkAwareWidget
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => 
            const CircularProgressIndicator()), 
          (route) => false
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200.w,
                height: 200.w,
                child: Lottie.asset(
                  'images/nonet.json',
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'No Internet Connection',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Please check your internet connection and try again.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                
                onPressed: () => _retryConnection(context),
                icon: const Icon(Icons.refresh,color: Colors.white,),
                
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  
                  padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

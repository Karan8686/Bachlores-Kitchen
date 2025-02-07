import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RecentlyOrderedPage extends StatelessWidget {
  const RecentlyOrderedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Recently Ordered', style: TextStyle(color: colorScheme.onPrimary,fontFamily: "poppins")),
        backgroundColor: colorScheme.primary,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildRecentOrderItem(
            context,
            'Mediterranean sunshine bowl',
            'Savory Street Eats',
            '15 min ago',
            'images/SaladQ.png',
          ),
          SizedBox(height: 16.h),
          _buildRecentOrderItem(
            context,
            'Spicy Chicken Wrap',
            'Wrap & Roll',
            '2 days ago',
            'images/SaladQ2.png',
          ),
          SizedBox(height: 16.h),
          _buildRecentOrderItem(
            context,
            'Veggie Supreme Pizza',
            'Pizza Paradise',
            '1 week ago',
            'images/SaladQ2.png',
          ),
        ].animate(interval: 200.ms).fadeIn().slideX(),
      ),
    );
  }

  Widget _buildRecentOrderItem(BuildContext context, String name, String restaurant, String timeAgo, String imagePath) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              bottomLeft: Radius.circular(16.r),
            ),
            child: Image.asset(
              imagePath,
              width: 100.w,
              height: 100.w,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    restaurant,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    timeAgo,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.replay, color: colorScheme.primary),
            onPressed: () {
              // TODO: Implement reorder functionality
            },
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:batchloreskitchen/Pages/theme.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  Widget _buildFavoriteItem(BuildContext context, String name, String restaurant, String rating, String imagePath) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: .1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
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
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                        fontFamily: "poppins"
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    restaurant,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Icon(Icons.star, color: colorScheme.primary, size: 18.w),
                      SizedBox(width: 4.w),
                      Text(
                        rating,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.favorite, color: colorScheme.primary),
            onPressed: () {

            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Favorites', style: TextStyle(color: colorScheme.onPrimary, fontFamily: "poppins")),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          _buildFavoriteItem(
            context,
            'Mediterranean sunshine bowl',
            'Savory Street Eats',
            '4.6',
            'images/SaladQ.png',
          ),
          SizedBox(height: 20.h),
          _buildFavoriteItem(
            context,
            'Spicy Chicken Wrap',
            'Wrap & Roll',
            '4.8',
            'images/SaladQ2.png',
          ),
          SizedBox(height: 20.h),
          _buildFavoriteItem(
            context,
            'Veggie Supreme Pizza',
            'Pizza Paradise',
            '4.5',
            'images/SaladQ3.png',
          ),
        ].animate(interval: 200.ms).fadeIn().slideX(),
      ),
    );
  }
}


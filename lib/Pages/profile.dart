import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(colorScheme),
              _buildProfileInfo(colorScheme),
              _buildStats(colorScheme),
              _buildMenuItems(colorScheme),
            ].animate(interval: 200.ms).fadeIn().slideY(begin: 0.2),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(FluentIcons.ios_arrow_24_filled),
            onPressed: () => Navigator.pop(context),
            color: colorScheme.primary,
          ),
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
          ),
          IconButton(onPressed:() {

          }, icon:Icon(FluentIcons.emoji_smile_slight_20_regular)
          )

        ],
      ),
    );
  }

  Widget _buildProfileInfo(ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50.r,
            backgroundImage: const AssetImage(''),
          ),
          SizedBox(height: 16.h),
          Text(
            'Karan',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '+91 7021511537',
            style: TextStyle(
              fontSize: 16.sp,
              color: colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 16.h),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Orders', '28', colorScheme),
            _buildStatItem('Reviews', '14', colorScheme),
            _buildStatItem('Points', '2850', colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, ColorScheme colorScheme) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems(ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          _buildMenuItem(
            FluentIcons.history_24_regular,
            'Order History',
            colorScheme,
          ),
          _buildMenuItem(
            FluentIcons.payment_24_regular,
            'Payment Methods',
            colorScheme,
          ),
          _buildMenuItem(
            FluentIcons.location_24_regular,
            'Delivery Addresses',
            colorScheme,
          ),
          _buildMenuItem(
            FluentIcons.heart_24_regular,
            'Favorites',
            colorScheme,
          ),
          _buildMenuItem(
            FluentIcons.person_support_24_regular,
            'Help & Support',
            colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, ColorScheme colorScheme,) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8.h),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          icon,
          color: colorScheme.primary,
          size: 24.w,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: colorScheme.onBackground,
        ),
      ),
      trailing: Icon(
        FluentIcons.chevron_right_24_regular,
        color: colorScheme.onBackground.withOpacity(0.6),
      ),
      onTap: () {

      },
    );
  }
}
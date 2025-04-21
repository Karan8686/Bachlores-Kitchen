import 'package:batchloreskitchen/Pages/favourate.dart';
import 'package:batchloreskitchen/Pages/recent_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:batchloreskitchen/providers/address_provider.dart';
import 'dart:io';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  File? _profileImage;

  Future<void> _pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        _profileImage = File(image.path);
      });
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showSavedAddresses(BuildContext context) {
    final theme = Theme.of(context);
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Saved Addresses',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            if (addressProvider.savedAddresses.isEmpty)
              Center(
                child: Text(
                  'No saved addresses',
                  style: theme.textTheme.bodyLarge,
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                itemCount: addressProvider.savedAddresses.length,
                itemBuilder: (context, index) {
                  final address = addressProvider.savedAddresses[index];
                  return ListTile(
                    leading: Icon(
                      address['type'] == 'Home' ? Icons.home
                      : address['type'] == 'Work' ? Icons.work
                      : Icons.location_on,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(address['address']),
                    subtitle: Text(address['landmark'] ?? ''),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
            icon: const Icon(FluentIcons.ios_arrow_24_filled),
            onPressed: () => Navigator.pop(context),
            color: colorScheme.primary,
          ),
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          IconButton(onPressed:() {

          }, icon:const Icon(FluentIcons.emoji_smile_slight_20_regular)
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
          Stack(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50.r,
                  backgroundImage: _profileImage != null 
                    ? FileImage(_profileImage!) as ImageProvider
                    : const AssetImage('images/logo.jpeg'),
                  child: _profileImage == null 
                    ? Icon(
                        Icons.add_a_photo,
                        size: 30.sp,
                        color: Colors.white54,
                      )
                    : null,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 20.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Karan',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '+91 7021511537',
            style: TextStyle(
              fontSize: 16.sp,
              color: colorScheme.onSurface.withOpacity(0.6),
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
            child: const Text('Edit Profile'),
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
              offset: const Offset(0, 4),
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
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecentOrder()),
            ),
          ),
          _buildMenuItem(
            FluentIcons.payment_24_regular,
            'Payment Methods',
            colorScheme,
            () {},
          ),
          _buildMenuItem(
            FluentIcons.location_24_regular,
            'Delivery Addresses',
            colorScheme,
            () => _showSavedAddresses(context),
          ),
          _buildMenuItem(
            FluentIcons.heart_24_regular,
            'Favorites',
            colorScheme,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesPage()),
            ),
          ),
          _buildMenuItem(
            FluentIcons.person_support_24_regular,
            'Help & Support',
            colorScheme,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, ColorScheme colorScheme, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
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
            color: colorScheme.onSurface,
          ),
        ),
        trailing: Icon(
          FluentIcons.chevron_right_24_regular,
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }
}
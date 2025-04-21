import 'package:batchloreskitchen/Logins/NewL.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  String selectedLanguage = 'English';
  final List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'de', 'name': 'German'},
    {'code': 'hi', 'name': 'Hindi'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('selectedLanguage') ?? 'English';
    setState(() {
      selectedLanguage = savedLanguage;
    });
  }

  Future<void> _changeLanguage(String? newLanguage) async {
    if (newLanguage == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', newLanguage);
    
    setState(() {
      selectedLanguage = newLanguage;
    });

    if (!mounted) return;

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language changed to $newLanguage'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Restart App',
          onPressed: () {
            // Restart app to apply changes
            Navigator.pushNamedAndRemoveUntil(
              context, 
              '/', 
              (route) => false
            );
          },
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
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(FluentIcons.arrow_left_24_regular, color: colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('General', colorScheme),

                        _buildLanguageSetting(colorScheme),


                        SizedBox(height: 24.h),
                        _buildSectionTitle('Notifications', colorScheme),
                        _buildToggleSetting(
                          'Push Notifications',
                          FluentIcons.alert_24_regular,
                          notificationsEnabled,
                              (value) => setState(() => notificationsEnabled = value),
                          colorScheme,
                        ),

                        SizedBox(height: 24.h),
                        _buildSectionTitle('Account', colorScheme),
                        _buildMenuItem(
                          'Privacy Policy',
                          FluentIcons.shield_24_regular,
                          colorScheme,
                        ),
                        _buildMenuItem(
                          'Terms of Service',
                          FluentIcons.document_24_regular,
                          colorScheme,
                        ),

                        const Spacer(),
                        _buildLogoutButton(colorScheme),
                        SizedBox(height: 24.h),
                      ].animate(interval: 70.ms).fadeIn().slideX(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      )
    );
  }

  Widget _buildToggleSetting(
      String title,
      IconData icon,
      bool value,
      Function(bool) onChanged,
      ColorScheme colorScheme,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: colorScheme.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: colorScheme.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        trailing: Icon(FluentIcons.chevron_right_24_regular, color: colorScheme.onSurface.withOpacity(0.6)),
        onTap: () {
          // Handle menu item tap
        },
      ),
    );
  }

  Widget _buildLanguageSetting(ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(FluentIcons.translate_24_regular, color: colorScheme.primary),
        ),
        title: Text(
          'Language',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        trailing: DropdownButton<String>(
          value: selectedLanguage,
          icon: Icon(FluentIcons.chevron_down_24_regular, color: colorScheme.primary),
          underline: const SizedBox(),
          onChanged: _changeLanguage,
          items: supportedLanguages.map<DropdownMenuItem<String>>((language) {
            return DropdownMenuItem<String>(
              value: language['name'],
              child: Text(language['name']!),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Log(),));
                    } catch (e) {
                      print('Error during logout: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to logout. Please try again.')),
                      );
                    }
                  },
                  child: Text('Logout', style: TextStyle(color: colorScheme.secondary)),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        child: Text(
          'Logout',
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.surface
          ),
        ),
      ),
    );
  }
}
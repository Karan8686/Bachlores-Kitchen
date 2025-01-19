import 'package:batchloreskitchen/widgets/restart_widget.dart';
import 'package:flutter/cupertino.dart';

class ThemeAwareWidget extends StatefulWidget {
  final Widget child;

  const ThemeAwareWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ThemeAwareWidget> createState() => _ThemeAwareWidgetState();
}

class _ThemeAwareWidgetState extends State<ThemeAwareWidget> with WidgetsBindingObserver {
  Brightness? _previousBrightness;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _previousBrightness = MediaQuery.platformBrightnessOf(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final currentBrightness = MediaQuery.platformBrightnessOf(context);

    if (_previousBrightness != currentBrightness) {
      _previousBrightness = currentBrightness;

      try {
        // Attempt to handle theme change
        _handleThemeChange(currentBrightness);
      } catch (e) {
        print('Error during theme change: $e');
        // Restart app if needed
        RestartWidget.restartApp(context);
      }
    }

    super.didChangePlatformBrightness();
  }

  void _handleThemeChange(Brightness brightness) {
    // Add any specific theme change logic here
    print('System theme changed to: ${brightness == Brightness.dark ? 'dark' : 'light'}');
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
import 'package:flutter/material.dart';

// Create a restart widget that will be the parent of your app
class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({Key? key, required this.child}) : super(key: key);

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App with Restart'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Listen to platform brightness changes
            Builder(
              builder: (context) {
                // Get the current brightness
                final brightness = MediaQuery.platformBrightnessOf(context);

                // When brightness changes, restart the app
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  try {
                    themeMode:ThemeMode.light;
                    // Your theme change logic here
                    // If something goes wrong, restart the app
                    RestartWidget.restartApp(context);
                  } catch (e) {
                    print('Error during theme change: $e');
                    RestartWidget.restartApp(context);
                  }
                });

                return Text('Current theme: ${brightness.toString()}');
              },
            ),
          ],
        ),
      ),
    );
  }
}
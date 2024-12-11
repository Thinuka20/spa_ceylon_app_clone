import 'package:ZAM_GEMS/pages/invoice.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/login_controller.dart';

void main() => runApp(
  MyApp(),
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      useInheritedMediaQuery: true, // Required for DevicePreview to work properly
      locale: DevicePreview.locale(context), // Set the locale for DevicePreview
      builder: DevicePreview.appBuilder, // Set the app builder for DevicePreview
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

const String url="http://124.43.70.220:7073/Customer";

class BackgroundScaffold extends StatelessWidget {
  final Widget child;

  const BackgroundScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background image with dimming applied only to the background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.jpg'), // Ensure correct path
                  fit: BoxFit.cover, // Cover entire background without overflow
                ),
              ),
              // Add dimming effect here, only for the background
              child: Container(
                color: Colors.black.withOpacity(0.5), // Dimming effect (70% opacity)
              ),
            ),
          ),
          // Foreground content (the page's main content) without dimming
          Positioned.fill(
            child: child, // Content is not dimmed
          ),
        ],
      ),
    );
  }
}

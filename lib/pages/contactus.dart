import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailLauncherPage extends StatelessWidget {
  const EmailLauncherPage({Key? key}) : super(key: key);

  Future<void> launchWebsite() async {
    final Uri url = Uri.parse('https://zamgems.com/elementor-262/');

    try {
      await launchUrl(
        url,
        mode: LaunchMode.inAppWebView, // Changed to inAppWebView
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      );
    } catch (e) {
      debugPrint('Error launching website: $e');
      Get.snackbar(
        'Error',
        'Failed to open website',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Remove the automatic back navigation to prevent GETX routing issue
    WidgetsBinding.instance.addPostFrameCallback((_) {
      launchWebsite();
    });

    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
        ),
      ),
    );
  }
}
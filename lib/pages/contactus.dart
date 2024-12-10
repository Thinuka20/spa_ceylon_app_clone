import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailLauncherPage extends StatelessWidget {
  const EmailLauncherPage({Key? key}) : super(key: key);

  Future<void> launchWebsite() async {
    final Uri url = Uri.parse('https://zamgems.com/elementor-262/');

    try {
      await launchUrl(
        url,
        mode: LaunchMode.inAppWebView,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      );
      Get.back(); // Navigate back after website is closed
    } catch (e) {
      debugPrint('Error launching website: $e');
      Get.snackbar(
        'Error',
        'Failed to open website',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.back(); // Navigate back if there's an error
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      launchWebsite();
    });

    return const SizedBox.shrink(); // Empty widget instead of loading screen
  }
}
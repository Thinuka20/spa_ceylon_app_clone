import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppLauncherPage extends StatelessWidget {
  const WhatsAppLauncherPage({Key? key}) : super(key: key);

  Future<void> launchWhatsApp() async {
    // Replace this with your phone number (include country code without '+')
    const phoneNumber = '94723344451';

    // Create WhatsApp URL
    final Uri whatsappUrl = Uri.parse('whatsapp://send?phone=$phoneNumber');

    // Fallback URL for web (optional)
    final Uri whatsappUrlWeb = Uri.parse('https://wa.me/$phoneNumber');

    try {
      // First try to launch WhatsApp app
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      }
      // If WhatsApp app is not installed, try web version
      else if (await canLaunchUrl(whatsappUrlWeb)) {
        await launchUrl(
          whatsappUrlWeb,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not launch WhatsApp';
      }
      Get.back(); // Navigate back after launching WhatsApp
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
      Get.snackbar(
        'Error',
        'Failed to open WhatsApp',
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
      launchWhatsApp();
    });

    return const SizedBox.shrink();
  }
}
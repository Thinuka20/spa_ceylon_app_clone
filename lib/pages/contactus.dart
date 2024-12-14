import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class WhatsAppLauncherPage extends StatefulWidget {
  const WhatsAppLauncherPage({Key? key}) : super(key: key);

  @override
  State<WhatsAppLauncherPage> createState() => _WhatsAppLauncherPageState();
}

class _WhatsAppLauncherPageState extends State<WhatsAppLauncherPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      launchWhatsApp();
    });
  }

  Future<void> launchWhatsApp() async {
    // Format the phone number properly (remove any spaces or special characters)
    const String phoneNumber = '94723344451';

    try {
      Uri? whatsappUrl;

      if (Platform.isAndroid) {
        // Try Android-specific intent first
        whatsappUrl = Uri.parse("intent://send?phone=$phoneNumber#Intent;scheme=whatsapp;package=com.whatsapp;end");

        final bool canLaunchIntent = await canLaunchUrl(whatsappUrl);
        debugPrint('Can launch Android intent: $canLaunchIntent');

        if (canLaunchIntent) {
          final bool launched = await launchUrl(
            whatsappUrl,
            mode: LaunchMode.externalApplication,
          );

          if (launched) {
            if (mounted) Navigator.of(context).pop();
            return;
          }
        }

        // If intent doesn't work, try direct WhatsApp URL
        whatsappUrl = Uri.parse('whatsapp://send?phone=$phoneNumber');
        final bool canLaunchWhatsapp = await canLaunchUrl(whatsappUrl);
        debugPrint('Can launch WhatsApp URL: $canLaunchWhatsapp');

        if (canLaunchWhatsapp) {
          final bool launched = await launchUrl(
            whatsappUrl,
            mode: LaunchMode.externalApplication,
          );

          if (launched) {
            if (mounted) Navigator.of(context).pop();
            return;
          }
        }

        // As last resort, try web URL
        whatsappUrl = Uri.parse('https://api.whatsapp.com/send?phone=$phoneNumber');
      } else {
        // For iOS and other platforms
        whatsappUrl = Uri.parse('whatsapp://send?phone=$phoneNumber');
      }

      final bool launched = await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw 'Could not launch WhatsApp';
      }

      if (mounted) {
        Navigator.of(context).pop();
      }

    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('WhatsApp not installed or failed to open: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Opening WhatsApp...'),
          ],
        ),
      ),
    );
  }
}
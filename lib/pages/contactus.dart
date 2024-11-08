import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailLauncherPage extends StatelessWidget {
  const EmailLauncherPage({Key? key}) : super(key: key);

  // Method to launch email
  void launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'thinukachanthula1@gmail.com', // Set the recipient's email
      queryParameters: {
        'subject': 'New Inquiry', // Set the email subject
        'body': 'hi', // Set the email body
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showErrorDialog(context, "Could not launch email client.");
      }
    } catch (e) {
      _showErrorDialog(context, "An error occurred: $e");
    }
  }

  // Method to show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Email'),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () => launchEmail(context), // Launch email when home icon is pressed
          ),
        ],
      ),
      body: Center(
        child: Text('Press the home icon to send an email'),
      ),
    );
  }
}

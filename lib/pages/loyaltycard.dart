import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../main.dart';

class LoyaltyCard extends StatelessWidget {
  const LoyaltyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> userData = Get.arguments ?? [];
    final Map<String, dynamic>? firstUser =
    userData.isNotEmpty ? userData[0] : null;
    return BackgroundScaffold(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: RotatedBox(
          quarterTurns: 1,
          child: Center(
            child: Card(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Color(0xFFa2790f), // Blue with full opacity
              child: Container(
                width: double.infinity,
                height: double.infinity, // Adjust height as necessary
                padding: const EdgeInsets.all(20),
                child: Stack(
                  children: [
                    // Rotated User Info on the Left
                    Positioned(
                      left: 5,
                      bottom: 5, // Rotates text to landscape
                      child: Text(
                        "${firstUser?['Name'] ?? 'N/A'}\n${firstUser?['Phone'] ?? 'N/A'}",
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    // Centered Spa Ceylon Logo
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/logo.png',
                            height: 270, // Set the height of the image
                          ),
                        ],
                      ),
                    ),

                    // QR Code at the Bottom Right
                    Positioned(
                      top: 5,
                      right: 70,
                      child: RotatedBox(
                        quarterTurns:
                        3,
                        child: QrImageView(
                          data: '${firstUser?['Phone'] ?? 'N/A'}',  // Replace with your data
                          version: QrVersions.auto,
                          size: 125.0,
                          gapless: false,  // Set to true to disable gaps between squares
                          // You can also customize the background and foreground colors if needed
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),

                    // Close Button at the Bottom Left
                    Positioned(
                      top: 5,
                      right: 5,
                      child: RotatedBox(
                        quarterTurns:
                            3, // This rotates the button 90 degrees clockwise
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, // Text color
                            backgroundColor:
                                Colors.black, // Button background color
                          ),
                          child: const Text("Close"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

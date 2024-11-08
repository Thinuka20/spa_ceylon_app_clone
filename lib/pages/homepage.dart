import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spa_ceylon/pages/history.dart';
import 'package:spa_ceylon/pages/newarrivals.dart';
import 'package:spa_ceylon/pages/offers.dart';
import 'package:spa_ceylon/pages/profile.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/login_controller.dart';
import '../main.dart';
import 'locations.dart';
import 'loyaltycard.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> userData = [];
  Map<String, dynamic>? firstUser;
  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  void _initializeUserData() {
    // Get the list from arguments
    userData = Get.arguments ?? [];
    // Get the first user if available
    firstUser = userData.isNotEmpty ? userData[0] : null;
  }

  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/colourback.jpg',
                          fit: BoxFit.cover,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 30.0),
                          child: Center(
                            child: Image.asset(
                              'assets/logo.png',
                              height: 230,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Text(
                      "AYUBOWAN!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Times New Roman',
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Card(
                          color: Colors.black.withOpacity(0.7),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 0),
                          shape: RoundedRectangleBorder(
                            side:
                                const BorderSide(color: Colors.amber, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              bottom: 40.0,
                              top: 20.0,
                              left: 20.0,
                              right: 20.0,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "${firstUser?['Name'] ?? 'N/A'}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontFamily: 'Times New Roman',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                                Text(
                                  "ID ${firstUser?['FK_CustomerId'] ?? 'N/A'}",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.amber,
                                    fontFamily: 'Times New Roman',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -25,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: SizedBox(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(180, 0),
                                  backgroundColor: Colors.amber,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                onPressed: () {
                                  Get.to(() => LoyaltyCard(),
                                      arguments: Get.arguments);
                                },
                                child: Text(
                                  "${firstUser?['TotalSKYPoints'] ?? '0.00'}",
                                  style: const TextStyle(
                                    fontSize: 35,
                                    color: Colors.black,
                                    fontFamily: 'Times New Roman',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    "SKY Points",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Times New Roman',
                      color: Colors.white,
                    ),
                  ),
                  GridView.count(
                    crossAxisCount: 3,
                    padding: const EdgeInsets.all(8.0),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      buildGridItem("Offers", Icons.local_offer, context,
                          const Offers(), Get.arguments),
                      buildGridItem("New Arrivals", Icons.new_releases, context,
                          const NewArrivals(), Get.arguments),
                      buildGridItem("Profile", Icons.person, context,
                          const Profile(), Get.arguments),
                      buildGridItem("Store Locator", Icons.store, context,
                          const Locations(), Get.arguments),
                      buildGridItem("History", Icons.history, context,
                          const History(), Get.arguments),
                      buildGridItem("Contact Us", Icons.contact_mail, context,
                          const EmailLauncherPage(), Get.arguments),
                    ],
                  ),
                  SizedBox(height: 20), // Add some padding before footer
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            width: double.infinity,
            child: const Text(
              "Powered by Ceylon Innovations",
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGridItem(String title, IconData icon, BuildContext context,
      Widget targetPage, List<dynamic> userData) {
    return GestureDetector(
      onTap: () {
        Get.to(() => targetPage, arguments: userData);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 40, color: Colors.amber),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class EmailLauncherPage extends StatelessWidget {
  const EmailLauncherPage({Key? key}) : super(key: key);

  Future<void> launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'thinukachanthula1@gmail.com', // Replace with your email
      queryParameters: {
        'subject': 'Support Request',
        'body': '',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        Get.snackbar(
          'Error',
          'Could not launch email app',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
      Get.snackbar(
        'Error',
        'Failed to open email app',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Launch email immediately when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      launchEmail();
      // Optional: Go back after launching
      Get.back();
    });

    // You can either return an empty screen or a loading indicator
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

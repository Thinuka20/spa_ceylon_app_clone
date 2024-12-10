import 'dart:convert';
import 'package:ZAM_GEMS/pages/history.dart';
import 'package:ZAM_GEMS/pages/newarrivals.dart';
import 'package:ZAM_GEMS/pages/offers.dart';
import 'package:ZAM_GEMS/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import 'contactus.dart';
import 'locations.dart';
import 'loyaltycard.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  List<dynamic> userData = [];
  Map<String, dynamic>? firstUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get the initial data from arguments to get the phone number
      final args = Get.arguments ?? [];
      if (args.isEmpty || args[0]['phone'] == null) {
        setState(() {
          isLoading = false;
          userData = [];
          firstUser = null;
        });
        return;
      }

      String phone = args[0]['phone'];

      final response = await http.get(
        Uri.parse('$url/customer?phone=$phone'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success' && data['data'] != null && data['data'].isNotEmpty) {
          setState(() {
            userData = data['data'];
            firstUser = userData[0];
            // Instead of setting Get.arguments directly, we'll pass the updated data through navigation
          });
        } else {
          setState(() {
            userData = [];
            firstUser = null;
          });
          Get.snackbar(
            'Error',
            'No user data found',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      Get.snackbar(
        'Error',
        'Failed to load user data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToPage(Widget page) {
    // Pass the current userData to the next page
    Get.to(
          () => page,
      arguments: userData,
      preventDuplicates: false,
    )?.then((value) {
      // When returning, reload the data
      _loadUserData();
    });
  }

  void reloadCurrentPage() {
    // Reload the current page with updated data
    Get.off(
          () => const HomePage(),
      arguments: userData,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: RefreshIndicator(
        onRefresh: () async {
          await _loadUserData();
          reloadCurrentPage(); // Reload the page after data is fetched
        },
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.amber))
            : Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                            margin: const EdgeInsets.only(top: 30.0),
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
                    if (firstUser != null) ...[
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
                                side: const BorderSide(color: Colors.amber, width: 2),
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
                                      "${firstUser?['name'] ?? 'N/A'}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontFamily: 'Times New Roman',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber,
                                      ),
                                    ),
                                    Text(
                                      "ID ${firstUser?['customerId'] ?? 'N/A'}",
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
                                      minimumSize: const Size(180, 0),
                                      backgroundColor: Colors.amber,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onPressed: () => navigateToPage(const LoyaltyCard()),
                                    child: Text(
                                      "${(firstUser?['totalSkyPoints'] ?? 0.00).toStringAsFixed(2)}",
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
                    ],
                    GridView.count(
                      crossAxisCount: 3,
                      padding: const EdgeInsets.all(8.0),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        buildGridItem("Offers", Icons.local_offer, context, const Offers()),
                        buildGridItem("New Arrivals", Icons.new_releases, context, const NewArrivals()),
                        buildGridItem("Profile", Icons.person, context, const Profile()),
                        buildGridItem("Store Locator", Icons.store, context, const Locations()),
                        buildGridItem("History", Icons.history, context, const History()),
                        buildGridItem("Contact Us", Icons.contact_mail, context, const EmailLauncherPage()),
                      ],
                    ),
                    const SizedBox(height: 20),
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
      ),
    );
  }

  Widget buildGridItem(String title, IconData icon, BuildContext context, Widget targetPage) {
    return GestureDetector(
      onTap: () => navigateToPage(targetPage),
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


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


import '../main.dart'; // Ensure this imports the necessary files/widgets

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {

  @override
  Widget build(BuildContext context) {
    final List<dynamic> invoiceData = Get.arguments ?? [];
    List<Widget> invoiceWidgets = [];
    for (var invoice in invoiceData) {
      String formattedDate = '';
      if (invoice['pDate'] != null) {
        // Parse the date
        DateTime dateTime = DateTime.parse(invoice['pDate']);

        // Format the date to 'yyyy-MM-dd' or any format you like
        formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
      }
      invoiceWidgets.add(

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date: $formattedDate',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '+${invoice['SKYPoints']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '-${invoice['rPoints']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Invoice No: ${invoice['SaleID']}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Location: ${invoice['Outlet']}',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Price: ${invoice['Amount']}',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return BackgroundScaffold(
      child: DefaultTabController(
        length: 2, // Number of tabs
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            title: const TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(
                  child: Text(
                    "Point Statement", // First tab text
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Customize text color
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "Rate Me", // Second tab text
                    style: TextStyle(
                      fontSize: 15, // Larger font size for Tab 2
                      fontWeight: FontWeight.w600, // Semi-bold text
                      color: Colors.white, // Custom red color for Tab 2
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Yellow Container for Headers
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Invoice\nDetails',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 100), // Adjust this value as needed
                            child: Text(
                              'Earned\nPoints',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            'Redeemed\nPoints',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Transaction Card
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: invoiceWidgets,
                        ),
                      ),
                    )

                  ],
                ),
              ),
              const Center(), // Content for second tab
            ],
          ),
        ),
      ),
    );
  }
}

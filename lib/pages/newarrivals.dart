import 'package:flutter/material.dart';

import '../main.dart'; // Ensure this imports the necessary files/widgets

class NewArrivals extends StatelessWidget {
  const NewArrivals({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
        child:AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,// Set transparent to show the image
          title: const Text("New Arrivals"),
        )
    );
  }
}

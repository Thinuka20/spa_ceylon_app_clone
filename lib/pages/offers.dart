import 'package:flutter/material.dart';
import '../main.dart';

class Offers extends StatelessWidget {
  const Offers({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          title: const Text("My Offers"),
        ),
        body: const Center(
          child: Text(
            "Not Available",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Times New Roman',
            ),
          ),
        ),
      ),
    );
  }
}
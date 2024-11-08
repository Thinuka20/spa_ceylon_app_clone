import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Ensure GetX is imported
import 'package:spa_ceylon/pages/register.dart';

import '../controllers/login_controller.dart';
import '../main.dart'; // Ensure this imports the necessary files/widgets

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController()); // Instantiate the controller
    return BackgroundScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 250, // Set the height of the container
            width: double.infinity, // Optional: Set width to fill the parent
            child: Stack(
              fit: StackFit.expand, // Make the stack fill the container
              children: [
                Image.asset(
                  'assets/colourback.jpg',
                  fit: BoxFit
                      .cover, // Ensure the image covers the entire container
                ),
                Container(
                  margin: EdgeInsets.only(top: 30.0),
                  child: Center(
                    child: Image.asset(
                      'assets/logo.png',
                      height: 230, // Set the height of the image
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          const SizedBox(height: 20),

          // Enter Mobile Number TextField
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              onChanged: (value) {
                controller.mobileNumber.value = value; // Update mobile number on change
              },
              style: const TextStyle(color: Colors.white), // Font color white
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone,
                    color: Colors.white), // Icon color white
                label: const Text(
                  "Mobile Number",
                  style: TextStyle(color: Colors.white),
                ),
                hintText: 'Enter Mobile Number',
                hintStyle: const TextStyle(
                    color: Colors.white), // Hint text in a lighter white shade
                filled: false,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(
                      color: Colors.white, width: 2.0), // White border
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(
                      color: Colors.white, width: 0.5), // White border on focus
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Login Button
          SizedBox(
            // width: 180.0, // Full-width button
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber, // Set the button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                controller.login(); // Call the login method when pressed
              },
              child: const Text(
                'LOGIN',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Sign up text with clickable "SignUp"
          RichText(
            text: TextSpan(
              text: "Don't you have an account? ",
              style: const TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
              children: [
                TextSpan(
                  text: 'SignUp',
                  style: const TextStyle(
                    color: Colors.amber, // Link color
                    fontStyle: FontStyle.normal,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupPage()),
                    );
                  },
                ),
              ],
            ),
          ),

          const Spacer(),

          // Powered by myPOS at the bottom
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(
              'Powered by Ceylon Innovations',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
          ),
        ],
      ),
    );
  }
}

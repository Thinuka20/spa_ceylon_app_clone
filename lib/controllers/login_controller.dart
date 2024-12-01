import 'dart:async';
import 'dart:io';
import 'package:ZAM_GEMS/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../pages/homepage.dart';
import '../pages/loginpage.dart';

class UserDataManager {
  static const String _key = 'user_data';

  // Save the data from login response
  static Future<void> saveUserDataList(List<dynamic> userList) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(userList);
    await prefs.setString(_key, jsonString);
  }

  // Load the saved data
  static Future<dynamic> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);

    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  // Check if user data exists
  static Future<bool> hasUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_key);
  }

  // Clear user data on logout
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

class LoginController extends GetxController {
  static const int timeoutSeconds = 30;

  final mobileNumber = ''.obs;
  final isLoading = false.obs;

  // Add retry functionality
  final _retryAttempts = 3;
  final _retryDelay = const Duration(seconds: 2);

  Future<void> login() async {
    if (!_validateInput()) return;

    isLoading.value = true;
    int attempts = 0;

    while (attempts < _retryAttempts) {
      try {
        attempts++;
        await _attemptLogin();
        break; // Success, exit the retry loop

      } catch (e) {
        print("Error during login attempt $attempts: $e");

        if (attempts == _retryAttempts || e is FormatException) {
          _handleError(e);
          break;
        }

        // Wait before retrying
        await Future.delayed(_retryDelay);
      }
    }

    isLoading.value = false;
  }

  bool _validateInput() {
    if (mobileNumber.value.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter mobile number",
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
    return true;
  }

  Future<void> _attemptLogin() async {
    final uri = Uri.parse('$url/customer');

    final response = await http.get(
      Uri.parse('$uri?phone=${mobileNumber.value}'),
      headers: {
        'Accept-Encoding': 'gzip'
      },
    ).timeout(
      Duration(seconds: timeoutSeconds),
      onTimeout: () => throw TimeoutException('Connection timeout after $timeoutSeconds seconds'),
    );

    print("API Response Status: ${response.statusCode}");
    print("API Response Body: ${response.body}");

    if (response.statusCode != 200) {
      throw HttpException('Server returned status code: ${response.statusCode}');
    }

    final responseData = json.decode(response.body) as Map<String, dynamic>;

    if (responseData['status'] == 'success' && responseData['data'] != null) {
      print("Login successful");
      final List<dynamic> transactions = responseData['data'];
      await UserDataManager.saveUserDataList(transactions);
      await Get.off(() => HomePage(), arguments: transactions);
    } else {
      throw Exception(responseData['message'] ?? "No user found for this number");
    }
  }

  void _handleError(dynamic error) {
    String message;

    if (error is TimeoutException) {
      message = 'Connection timeout. Please check your internet connection.';
    } else if (error is FormatException) {
      message = 'Invalid response from server. Please try again.';
    } else if (error is HttpException) {
      message = error.message;
    } else {
      message = 'An unexpected error occurred. Please try again.';
    }

    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: UserDataManager.loadUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFa2790f),
                backgroundColor: Color(0xFF000000),
              ),
            ),
          );
        }

        // Navigate based on saved data
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (snapshot.hasData && snapshot.data != null) {
            // If we have saved data, go to HomePage
            Get.off(() => HomePage(), arguments: snapshot.data);
          } else {
            // If no saved data, go to LoginPage
            Get.off(() => LoginPage());
          }
        });

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
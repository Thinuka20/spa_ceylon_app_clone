import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart';
import 'loginpage.dart';

class NationalityData {
  final String id;
  final String name;

  NationalityData({required this.id, required this.name});
}

class CityData {
  final String id;
  final String name;

  CityData({required this.id, required this.name});
}

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String? selectedNationalityId;
  String? selectedCityId;
  NationalityData? selectedNationality;
  CityData? selectedCity;
  bool isLoadingNationalities = true;
  bool isLoadingCities = true;
  List<NationalityData> nationalities = [];
  List<CityData> cities = [];

  @override
  void initState() {
    super.initState();
    _loadNationalities();
    _loadCities();
  }

  Future<void> _loadNationalities() async {
    try {
      final response = await http.get(
          Uri.parse('$url/getNationalities.php'));
      final jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        setState(() {
          // Assuming your nationality column is named 'nationality'
          // Adjust the field name if different
          nationalities = (jsonData['data'] as List).map((item) => NationalityData(
            id: item['nationality_id'].toString(),
            name: item['nationality_name'].toString(),
          )).toList();

          // Set the selected nationality based on the ID from userData
          if (selectedNationalityId != null) {
            selectedNationality = nationalities.firstWhere(
                  (nat) => nat.id == selectedNationalityId,
              orElse: () => nationalities.first,
            );
          }
          isLoadingNationalities = false;
        });
      }
    } catch (e) {
      print('Error loading nationalities: $e');
      setState(() {
        isLoadingNationalities = false;
      });
    }
  }

  Future<void> _loadCities() async {
    try {
      final response = await http
          .get(Uri.parse('$url/getCities.php'));
      final jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        setState(() {
          cities = (jsonData['data'] as List).map((item) => CityData(
            id: item['city_id'].toString(),
            name: item['city_name'].toString(),
          )).toList();

          // Set the selected city based on the ID from userData
          if (selectedCityId != null) {
            selectedCity = cities.firstWhere(
                  (city) => city.id == selectedCityId,
              orElse: () => cities.first,
            );
          }
          isLoadingCities = false;
        });
      }
    } catch (e) {
      print('Error loading cities: $e');
      setState(() {
        isLoadingCities = false;
      });
    }
  }

  String? _gender = 'Male';
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _reenterEmailController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers when not needed to avoid memory leaks
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _reenterEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
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
                        height: 230,
                        // Set the height of the image
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5), // Form background
                  borderRadius: BorderRadius.circular(10), // Rounded edges
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          labelText: 'Full Name:',
                          hintText: 'Enter your full name',
                        ),
                        const SizedBox(height: 10),
                        // Mobile Field
                        _buildTextField(
                          labelText: 'Mobile:',
                          hintText: 'Enter your mobile number',
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 10),
                        // Email Field
                        _buildTextField(
                          labelText: 'Mail:',
                          hintText: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 10),
                        // Re-enter Email Field
                        _buildTextField(
                          labelText: 'Mail (Re-enter):',
                          hintText: 'Re-enter your email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 10),
                        // Nationality Dropdown
                        _buildDropdownField('Nationality', nationalities),
                        _buildDropdownField('City', cities),
                        const SizedBox(height: 10),
                        // Gender Selection
                        const Text(
                          'Gender:',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Male'),
                                value: 'Male',
                                activeColor: Colors.amber,
                                groupValue: _gender,
                                onChanged: (value) {
                                  setState(() {
                                    _gender = value;
                                  });
                                },
                                visualDensity: VisualDensity
                                    .compact, // Reduces the vertical padding
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Female'),
                                value: 'Female',
                                activeColor: Colors.amber,
                                groupValue: _gender,
                                onChanged: (value) {
                                  setState(() {
                                    _gender = value;
                                  });
                                },
                                visualDensity: VisualDensity
                                    .compact, // Reduces the vertical padding
                              ),
                            ),
                          ],
                        ),

                        // Signup Button
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
                  // Handle login action
                },
                child: const Text(
                  'SIGNUP',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Sign up text with clickable "SignUp"
            RichText(
              text: TextSpan(
                text: "Already have an account? ",
                style: const TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
                children: [
                  TextSpan(
                    text: 'Login',
                    style: const TextStyle(
                      color: Colors.amber, // Link color
                      fontStyle: FontStyle.normal,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                    // Handle sign-up action
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

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
      ),
    );
  }

  // Reusable TextFormField with consistent styling
  Widget _buildTextField({
    required String labelText,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    String? initialValue,
  }) {
    return TextFormField(
      decoration: _buildInputDecoration(labelText, hintText: hintText),
      keyboardType: keyboardType,
      initialValue: initialValue,
    );
  }

  // Input decoration for TextFormFields
  InputDecoration _buildInputDecoration(String labelText, {String? hintText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: const TextStyle(color: Colors.black, fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
            color: Colors.amber, width: 1.5), // Color when input is focused
      ),
    );
  }
  Widget _buildDropdownField(String label, List<dynamic> items) {
    bool isLoading = label == 'Nationality' ? isLoadingNationalities : isLoadingCities;
    dynamic selectedValue = label == 'Nationality' ? selectedNationality : selectedCity;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDE7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: isLoading
                  ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.amber,
                    strokeWidth: 2,
                  ),
                ),
              )
                  : DropdownButton<dynamic>(
                value: selectedValue,
                isExpanded: true,
                underline: SizedBox(), // Removes the underline
                hint: Text(
                  'Select $label',
                  style: const TextStyle(color: Colors.black),
                ),
                icon: const Icon(Icons.arrow_drop_down),
                items: items.map((item) {
                  return DropdownMenuItem<dynamic>(
                    value: item,
                    child: Text(label == 'Nationality'
                        ? (item as NationalityData).name
                        : (item as CityData).name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    if (label == 'Nationality') {
                      selectedNationality = value as NationalityData;
                      selectedNationalityId = value.id;
                    } else {
                      selectedCity = value as CityData;
                      selectedCityId = value.id;
                    }
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

}

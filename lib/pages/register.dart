import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart';
import 'loginpage.dart';
import 'package:intl/intl.dart';

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
  String? _gender = 'Male';
  String? _maritalStatus = 'Single';
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNationalities();
    _loadCities();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _nicController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _loadNationalities() async {
    try {
      final response = await http.get(Uri.parse('$url/nationalities'));
      final jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        setState(() {
          nationalities = (jsonData['data'] as List).map((item) => NationalityData(
            id: item['nationality_id'].toString(),
            name: item['nationality_name'].toString(),
          )).toList();
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
      final response = await http.get(Uri.parse('$url/cities'));
      final jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        setState(() {
          cities = (jsonData['data'] as List).map((item) => CityData(
            id: item['city_id'].toString(),
            name: item['city_name'].toString(),
          )).toList();
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

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedNationalityId == null || selectedCityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select nationality and city')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$url/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'Name': _fullNameController.text,
          'Phone': _mobileController.text,
          'Email': _emailController.text,
          'Address': _addressController.text,
          'NIC': _nicController.text,
          'DOB': _selectedDate?.toIso8601String(),
          'Gender': _gender == 'Male' ? 1 : 2,
          'MaritalStatus': _maritalStatus == 'Single' ? 1 : 2,
          'Nationality': selectedNationalityId,
          'City': int.parse(selectedCityId!)
        }),
      );

      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful')),
        );
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    }
  }

  Widget _buildTextField({
    required String labelText,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? controller,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _buildInputDecoration(labelText, hintText: hintText),
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      validator: (value) {
        if (value?.isEmpty ?? true) return '$labelText is required';
        if (labelText.contains('Mail') &&
            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
          return 'Invalid email format';
        }
        if (labelText.contains('Mobile') &&
            !RegExp(r'^[0-9+]+$').hasMatch(value!)) {
          return 'Invalid mobile number';
        }
        return null;
      },
    );
  }

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
        borderSide: const BorderSide(color: Colors.amber, width: 1.5),
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
                underline: const SizedBox(),
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

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
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
    Padding(
    padding: const EdgeInsets.all(16.0),
    child: Container(
    decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.5),
    borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
    padding: const EdgeInsets.all(15.0),
    child: Form(
    key: _formKey,
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    _buildTextField(
    labelText: 'Full Name',
    hintText: 'Enter your full name',
    controller: _fullNameController,
    ),
    const SizedBox(height: 10),
    _buildTextField(
    labelText: 'Mobile',
    hintText: 'Enter your mobile number',
    keyboardType: TextInputType.phone,
    controller: _mobileController,
    ),
    const SizedBox(height: 10),
    _buildTextField(
    labelText: 'Mail',
    hintText: 'Enter your email',
    keyboardType: TextInputType.emailAddress,
    controller: _emailController,
    ),
    const SizedBox(height: 10),
    _buildTextField(
    labelText: 'Address',
    hintText: 'Enter your address',
    controller: _addressController,
    ),
    const SizedBox(height: 10),
    _buildTextField(
    labelText: 'NIC',
    hintText: 'Enter your NIC',
    controller: _nicController,
    ),
    const SizedBox(height: 10),
    _buildTextField(
    labelText: 'Birthday',
    controller: _dobController,
    readOnly: true,
    onTap: () => _selectDate(context),
    ),
    const SizedBox(height: 10),
    _buildDropdownField('Nationality', nationalities),
    _buildDropdownField('City', cities),
    const SizedBox(height: 10),
    const Text(
    'Gender:',
    style: TextStyle(fontSize: 13, color: Colors.black),
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
    visualDensity: VisualDensity.compact,
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
    visualDensity: VisualDensity.compact,
    ),
    ),
    ],
    ),
    const Text(
    'Status:',
    style: TextStyle(fontSize: 13, color: Colors.black),
    ),
    Row(
    children: [
    Expanded(
    child: RadioListTile<String>(
    title: const Text('Married'),
    value: 'Married',
    activeColor: Colors.amber,
    groupValue: _maritalStatus,
    onChanged: (value) {
    setState(() {
    _maritalStatus = value;
    });
    },
    visualDensity: VisualDensity.compact,
    ),
    ),
    Expanded(
    child: RadioListTile<String>(
    title: const Text('Single'),
    value: 'Single',
    activeColor: Colors.amber,
    groupValue: _maritalStatus,
    onChanged: (value) {
    setState(() {
    _maritalStatus = value;
    });
    },
    visualDensity: VisualDensity.compact,
    ),
    ),
    ],
    ),
    ],
    ),
    ),
    ),
    ),
    ),
    SizedBox(
    child: ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.amber,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
    ),
    ),
    onPressed: _signup,
    child: const Text(
    'SIGNUP',
    style: TextStyle(fontSize: 18, color: Colors.black),
    ),
    ),
    ),
    const SizedBox(height: 10),
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
            color: Colors.amber,
            fontStyle: FontStyle.normal,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
        ),
      ],
    ),
    ),
        const SizedBox(height: 25),
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
}
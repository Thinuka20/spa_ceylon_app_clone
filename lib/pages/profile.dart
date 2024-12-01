import 'dart:convert';
import 'package:ZAM_GEMS/pages/loginpage.dart';
import 'package:ZAM_GEMS/pages/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import 'package:http/http.dart' as http;

class CustomerProfile {
  final String id;
  final String name;
  final String nic;
  final DateTime dob;
  final String phone;
  final double gender;
  final double marital;
  final String address;
  final String email;
  final String nationality;
  final double city;

  CustomerProfile({
    required this.id,
    required this.name,
    required this.nic,
    required this.dob,
    required this.phone,
    required this.gender,
    required this.marital,
    required this.address,
    required this.email,
    required this.nationality,
    required this.city,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nic': nic,
    'dob': dob.toIso8601String(), // Convert DateTime to string
    'phone': phone,
    'gender': gender,
    'marital': marital,
    'address': address,
    'email': email,
    'nationality': nationality,
    'city': city,
  };
}

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

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? userID;
  String selectedGender = 'Male';
  String selectedMaritalStatus = 'Single';
  String? selectedNationalityId;
  String? selectedCityId;
  NationalityData? selectedNationality;
  CityData? selectedCity;
  bool isLoadingNationalities = true;
  bool isLoadingCities = true;
  List<NationalityData> nationalities = [];
  List<CityData> cities = [];
  late final Map<String, TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    final List<dynamic> userData = Get.arguments ?? [];
    final Map<String, dynamic>? firstUser =
        userData.isNotEmpty ? userData[0] : null;

    // Initialize values from userData
    if (firstUser != null) {
      userID = firstUser['customerId']?.toString() ?? '0';
      selectedNationalityId = firstUser['nationality']?.toString();
      selectedCityId = firstUser['city']?.toString();
      // Handle gender conversion
      if (firstUser['gender'] != null) {
        int genderValue = firstUser['gender'] is String
            ? int.tryParse(firstUser['gender']) ?? 1
            : firstUser['gender'] ?? 1;
        selectedGender = genderValue == 1 ? 'Male' : 'Female';
      }

      // Handle marital status conversion
      if (firstUser['marital'] != null) {
        int maritalValue = firstUser['marital'] is String
            ? int.tryParse(firstUser['marital']) ?? 1
            : firstUser['marital'] ?? 1;
        selectedMaritalStatus = maritalValue == 1 ? 'Single' : 'Married';
      }
    }

    controllers = {
      'Name': TextEditingController(text: firstUser?['name'] ?? ''),
      'NIC': TextEditingController(text: firstUser?['nic'] ?? ''),
      'Birthday': TextEditingController(text: firstUser?['dob'] != null
          ? DateFormat('yyyy-MM-dd').format(DateTime.parse(firstUser!['dob'].toString()))
          : ''),
      'Mobile': TextEditingController(text: firstUser?['phone'] ?? ''),
      'Address': TextEditingController(text: firstUser?['address'] ?? ''),
      'Email': TextEditingController(text: firstUser?['email'] ?? ''),
    };

    _loadNationalities();
    _loadCities();
  }

  Future<void> _loadNationalities() async {
    try {
      final response = await http.get(
          Uri.parse('$url/nationalities'));
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
          .get(Uri.parse('$url/cities'));
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

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          title: const Text(
            "Profile",
            style: TextStyle(fontSize: 20),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Get.to(() => SettingsPage(), arguments: Get.arguments);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              _buildTextField('Name', '', 'text'),
              _buildTextField('NIC', '', 'text'),
              _buildTextField('Birthday', '', 'date'),
              _buildTextField('Mobile', '', 'phone',),
              _buildRadioField('Gender', selectedGender),
              _buildRadioField('Martial Status', selectedMaritalStatus),
              _buildTextField('Address', '', 'text'),
              _buildDropdownField('Nationality', nationalities),
              _buildDropdownField('City', cities),
              _buildTextField('Email', '', 'email'),
            ],
          ),
        ),
        floatingActionButton: Material(
          elevation: 10,
          shadowColor: Colors.grey,
          shape: const CircleBorder(),
          child: FloatingActionButton(
            onPressed: () async {
              try {
                final profile = CustomerProfile(
                    id: userID ?? '0',
                    name: controllers['Name']?.text ?? '',
                    nic: controllers['NIC']?.text ?? '',
                    dob: DateTime.parse(controllers['Birthday']?.text ?? ''),
                    phone: controllers['Phone']?.text ?? '',
                    gender: double.parse(selectedGender == 'Male' ? '1' : '2'),
                    marital: double.parse(selectedMaritalStatus == 'Single' ? '1' : '2'),
                    address: controllers['Address']?.text ?? '',
                    email: controllers['Email']?.text ?? '',
                    nationality: selectedNationalityId ?? '',
                    city: double.parse(selectedCityId ?? '0')
                );

                final response = await http.post(
                  Uri.parse('$url/profile'),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode(profile.toJson()),
                );

                print('Status code: ${response.statusCode}');
                print('Response body: ${response.body}');
                print('Response headers: ${response.headers}');
                final responseData = jsonDecode(response.body);
                if(response.statusCode == 200 && responseData['status'] == 'success') {
                  // Get.to(() => LoginPage());
                } else {
                  print('Error: ${responseData['message']}');
                }
              } catch (e) {
                print('Error saving profile: $e');
              }
            },
            backgroundColor: Colors.white,
            elevation: 0,
            child: const Icon(Icons.save, size: 40, color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, String initialValue, String keyboardType) {
    // Ensure we have a controller for this field
    if (!controllers.containsKey(label)) {
      controllers[label] = TextEditingController(text: initialValue);
    }

    final controller = controllers[label]!;

    Future<void> _selectDate(BuildContext context) async {
      final DateTime initialDate =
          DateTime.tryParse(controller.text) ?? DateTime.now();
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.amber,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        setState(() {
          controller.text = picked.toString().split(' ')[0];
        });
      }
    }

    TextInputType _getKeyboardType(String type) {
      switch (type) {
        case 'text':
          return TextInputType.text;
        case 'number':
          return TextInputType.number;
        case 'email':
          return TextInputType.emailAddress;
        case 'phone':
          return TextInputType.phone;
        case 'date':
          return TextInputType.datetime;
        default:
          return TextInputType.text;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 140,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(right: 10),
              height: 50,
              padding: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDE7),
                borderRadius: BorderRadius.circular(28),
              ),
              child: TextField(
                keyboardType: _getKeyboardType(keyboardType),
                controller: controller,
                cursorColor: Colors.amber,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(10),
                ),
                onTap: () {
                  if (keyboardType == 'date') {
                    _selectDate(context);
                  }
                },
                readOnly: keyboardType == 'date',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioField(String label, String groupValue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 95,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                if (label == 'Gender') ...[
                  _buildRadioOption('Male', groupValue, (value) {
                    setState(() => selectedGender = value);
                  }),
                  _buildRadioOption('Female', groupValue, (value) {
                    setState(() => selectedGender = value);
                  }),
                ] else ...[
                  _buildRadioOption('Single', groupValue, (value) {
                    setState(() => selectedMaritalStatus = value);
                  }),
                  _buildRadioOption('Married', groupValue, (value) {
                    setState(() => selectedMaritalStatus = value);
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(
      String value, String groupValue, Function(String) onChanged) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Radio<String>(
            value: value,
            groupValue: groupValue,
            activeColor: Colors.amber,
            onChanged: (String? newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
            visualDensity: VisualDensity.compact,
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, List<dynamic> items) {
    bool isLoading = label == 'Nationality' ? isLoadingNationalities : isLoadingCities;
    dynamic selectedValue = label == 'Nationality' ? selectedNationality : selectedCity;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 140,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(right: 10),
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDE7),
                borderRadius: BorderRadius.circular(28),
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


  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<NationalityData?>('selectedNationality', selectedNationality));
  }
}

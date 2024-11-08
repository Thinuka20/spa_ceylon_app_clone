import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spa_ceylon/pages/loginpage.dart';
import 'package:spa_ceylon/pages/settings.dart';
import '../main.dart';
import 'package:http/http.dart' as http;

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
      userID = firstUser['FK_CustomerId']?.toString();
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
      'Name': TextEditingController(text: firstUser?['Name'] ?? ''),
      'NIC': TextEditingController(text: firstUser?['NIC'] ?? ''),
      'Birthday': TextEditingController(text: firstUser?['DOB'] ?? ''),
      'Mobile': TextEditingController(text: firstUser?['Phone'] ?? ''),
      'Telephone (Home)':
          TextEditingController(text: firstUser?['TelephoneH'] ?? ''),
      'Telephone (Office)':
          TextEditingController(text: firstUser?['TelephoneO'] ?? ''),
      'Address': TextEditingController(text: firstUser?['AddressLine1'] ?? ''),
      'Fax': TextEditingController(text: firstUser?['FAX'] ?? ''),
      'Email': TextEditingController(text: firstUser?['email'] ?? ''),
      'Promo Coupon': TextEditingController(text: firstUser?['promo'] ?? ''),
    };

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
              // _buildDropdownField('Title', 'Mr.'),
              _buildTextField('Name', '', 'text'),
              _buildTextField('NIC', '', 'text'),
              _buildTextField('Birthday', '', 'date'),
              _buildTextField('Mobile', '', 'phone'),
              _buildTextField('Telephone (Home)', '', 'phone'),
              _buildTextField('Telephone (Office)', '', 'phone'),
              _buildRadioField('Gender', selectedGender),
              _buildRadioField('Martial Status', selectedMaritalStatus),
              _buildTextField('Address', '', 'text'),
              _buildDropdownField('Nationality', nationalities),
              _buildDropdownField('City', cities),
              _buildTextField('Fax', '', 'phone'),
              _buildTextField('Email', '', 'email'),
              _buildTextField('Promo Coupon', '', 'text'),
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
                // Collect form data
                final formData = {
                  'id': userID,
                  'name': controllers['Name']?.text,
                  'nic': controllers['NIC']?.text,
                  'dob': controllers['Birthday']?.text,
                  'telephoneH': controllers['Telephone (Home)']?.text,
                  'telephoneO': controllers['Telephone (Office)']?.text,
                  'address': controllers['Address']?.text,
                  'fax': controllers['Fax']?.text,
                  'email': controllers['Email']?.text,
                  'promo': controllers['Promo Coupon']?.text,
                  'gender': selectedGender == 'Male' ? 1 : 2,
                  'marital': selectedMaritalStatus == 'Single' ? 1 : 2,
                  'nationality': selectedNationalityId,
                  'city': selectedCityId,
                };

                final response = await http.post(
                  Uri.parse('$url/saveProfile.php'),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode(formData),
                );

                if (response.statusCode == 200) {
                  // Decode the response
                  Get.to(() => LoginPage(),);
                } else {
                  print('Server error: ${response.statusCode}');
                  // Show an error message for non-200 responses
                }
              } catch (e) {
                // Handle errors
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

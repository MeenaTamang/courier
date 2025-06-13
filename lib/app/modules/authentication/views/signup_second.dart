import 'dart:io' as io;
import 'dart:typed_data';

import 'package:courier/app/core/theme/theme.dart';
import 'package:courier/app/modules/authentication/views/authentication_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';



class SignUpSecond extends StatefulWidget {
  final String fullName;
  final String email;
  final String password;
  final String contactNumber;
  final String homeAddress;
  final PageController controller;

  const SignUpSecond({
    required this.fullName,
    required this.email,
    required this.password,
    required this.contactNumber,
    required this.homeAddress,
    required this.controller,
  });

  @override
  State<SignUpSecond> createState() => _SignUpSecondState();
}

class _SignUpSecondState extends State<SignUpSecond> {
  final TextEditingController _vehicleNumberController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _nationalIDNumberController = TextEditingController();

  Uint8List? _vehicleImageBytes;
  Uint8List? _licenseImageBytes;
  Uint8List? _nationalIdImageBytes;
  Uint8List? _profileImageBytes;
  
  String? _vehicleImageName;
  String? _licenseImageName;
  String? _nationalIdImageName;
  String? _profileImageName;

  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  bool _isLoading = false;

  Future<void> _pickImage(String type) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final file = io.File(pickedFile.path);
    final bytes = await file.readAsBytes();
    final name = pickedFile.name;

    setState(() {
      if (type == 'vehicle') {
        _vehicleImageBytes = bytes;
        _vehicleImageName = name;
      } else if (type == 'license') {
        _licenseImageBytes = bytes;
        _licenseImageName = name;
      } else if (type == 'nationalId') {
        _nationalIdImageBytes = bytes;
        _nationalIdImageName = name;
      }else if (type == 'profile') {
      _profileImageBytes = bytes;
      _profileImageName = name;
    }
    });
  }

  Future<void> _registerUser() async {
    if (_vehicleNumberController.text.isEmpty ||
        _licenseNumberController.text.isEmpty ||
        _nationalIDNumberController.text.isEmpty ||
        _vehicleImageBytes == null ||
        _licenseImageBytes == null ||
        _nationalIdImageBytes == null||
        _profileImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and upload images.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      var uri = Uri.parse("http://192.168.49.195:5183/api/registration/create");
      var request = http.MultipartRequest("POST", uri);

      request.fields['FullName'] = widget.fullName;
      request.fields['Email'] = widget.email;
      request.fields['Password'] = widget.password;
      request.fields['ContactNumber'] = widget.contactNumber;
      request.fields['HomeAddress'] = widget.homeAddress;
      request.fields['VehicleRegistrationNumber'] = _vehicleNumberController.text;
      request.fields['LicenseNumber'] = _licenseNumberController.text;
      request.fields['NationalIdNumber'] = _nationalIDNumberController.text;

      request.files.add(http.MultipartFile.fromBytes(
        'VehicleRegistrationNumberImage',
        _vehicleImageBytes!,
        filename: _vehicleImageName ?? 'vehicle.jpg',
      ));
      request.files.add(http.MultipartFile.fromBytes(
        'LicenseNumberImage',
        _licenseImageBytes!,
        filename: _licenseImageName ?? 'license.jpg',
      ));
      request.files.add(http.MultipartFile.fromBytes(
        'NationalIdNumberImage',
        _nationalIdImageBytes!,
        filename: _nationalIdImageName ?? 'national_id.jpg',
      ));
      // Add profile image file
      request.files.add(http.MultipartFile.fromBytes(
        'ProfileImage',
        _profileImageBytes!,
        filename: _profileImageName ?? 'profile.jpg',
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful")),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => AuthenticationView()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onRefresh() async {
    setState(() {
      _vehicleNumberController.clear();
      _licenseNumberController.clear();
      _nationalIDNumberController.clear();
      _vehicleImageBytes = null;
      _licenseImageBytes = null;
      _nationalIdImageBytes = null;
      _vehicleImageName = null;
      _licenseImageName = null;
      _nationalIdImageName = null;
      _profileImageBytes = null;
      _profileImageName = null;

    });

    await Future.delayed(const Duration(milliseconds: 500));
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _licenseNumberController.dispose();
    _nationalIDNumberController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/logsign.jpg"),
              alignment: Alignment.bottomCenter,
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 200),
                  const Text(
                    'Identification Document',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 23,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 50),

                  _buildInputRow(
                    controller: _vehicleNumberController,
                    label: 'Vehicle Registration Number',
                    onUpload: () => _pickImage('vehicle'),
                    showCheck: _vehicleImageBytes != null,
                  ),
                  const SizedBox(height: 25),

                  _buildInputRow(
                    controller: _licenseNumberController,
                    label: 'License Number',
                    onUpload: () => _pickImage('license'),
                    showCheck: _licenseImageBytes != null,
                  ),
                  const SizedBox(height: 25),

                  _buildInputRow(
                    controller: _nationalIDNumberController,
                    label: 'National ID Number',
                    onUpload: () => _pickImage('nationalId'),
                    showCheck: _nationalIdImageBytes != null,
                  ),
                  const SizedBox(height: 25),

                  // New Profile Image Upload Section
                  const Text(
                    'Profile Image',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickImage('profile'),
                        icon: const Icon(Icons.upload),
                        label: const Text('Upload Profile Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MaterialTheme.blueColorScheme().onSecondaryContainer,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (_profileImageBytes != null)
                        const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),

                  const SizedBox(height: 25),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: SizedBox(
                      width: 300,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MaterialTheme.blueColorScheme().onSecondaryContainer,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Create account',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputRow({
    required TextEditingController controller,
    required String label,
    required VoidCallback onUpload,
    required bool showCheck,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: controller,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(width: 1, color: Color.fromARGB(255, 50, 50, 51)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(width: 1, color: Color.fromARGB(255, 50, 50, 51)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(icon: const Icon(Icons.upload), onPressed: onUpload),
        if (showCheck) const Icon(Icons.check_circle, color: Colors.green),
      ],
    );
  }
}

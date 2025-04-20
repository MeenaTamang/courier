import 'dart:convert';

import 'package:courier/app/core/theme/theme.dart';
import 'package:courier/app/modules/Documents/views/documents_view.dart';
import 'package:courier/app/modules/ProfileDetails/views/profile_details_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ProfileView extends StatefulWidget {
   final String userId;  // Declare userId as String if it's returned as String

  const ProfileView({super.key, required this.userId});
  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch worker details using the userId passed to the ProfileView widget
    fetchWorkerDetails(widget.userId);  // Correctly access the userId here
  }

  Future<void> fetchWorkerDetails(String userId) async {
  final url = Uri.parse('http://192.168.49.16:5183/api/workerdetails/getworkerdetails/$userId');

  try {
    print("Fetching worker details for userId: $userId");
    print("URL: $url");

    final response = await http.get(url);
    print("Status Code: ${response.statusCode}");
    print("Response: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      setState(() {
        userData = data;
        isLoading = false;
      });
    } else {
      print("Error: Unexpected status code: ${response.statusCode}");
      throw Exception('Failed to load worker data');
    }
  } catch (e) {
    print('Error fetching worker data: $e');
    setState(() => isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MaterialTheme.blueColorScheme().secondary,
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/firstLayer.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 15),
                  Center(child: _buildAvatar()),
                  const SizedBox(height: 7),
                  _buildProfileInfo(),
                  const SizedBox(height: 15),
                  _buildNavigationIcons(),
                  const SizedBox(height: 25),
                  _buildAdditionalInfo(),
                ],
              ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: MaterialTheme.blueColorScheme().secondaryContainer,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(
        Icons.person,
        size: 80,
        color: Color.fromARGB(255, 70, 69, 75),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      children: [
        Text(
          userData?['fullName'] ?? 'Loading...',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 2),
        Text(
          'License No.: ${userData?['licenseNumber'] ?? 'Loading...'}',
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildNavigationIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _iconBox(Icons.person_outline_rounded, () {
          Get.to(() => const ProfileDetailsView());
        }),
        const SizedBox(width: 24),
        _iconBox(Icons.description_outlined, () {
          Get.to(() => const DocumentsView());
        }),
        const SizedBox(width: 24),
        _iconBox(Icons.logout_outlined, () {
          Get.toNamed('/authentication?index=0');
        }),
      ],
    );
  }

  Widget _iconBox(IconData icon, VoidCallback onTap) {
    return Material(
      color: MaterialTheme.blueColorScheme().secondaryContainer,
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 50,
          height: 50,
          child: Icon(
            icon,
            size: 30,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Column(
      children: [
        _infoRow(Icons.location_on_outlined, 'Address', userData?['homeAddress'] ?? 'Loading...'),
        SizedBox(height: 13),
        _infoRow(Icons.email_outlined, 'Email Address', userData?['email'] ?? 'Loading...'),
        SizedBox(height: 13),
        _infoRow(Icons.perm_identity, 'National ID No.', userData?['nationalIDNumber'] ?? 'Loading...'),
        SizedBox(height: 13),
        _infoRow(Icons.phone_outlined, 'Phone Number', userData?['contactNumber'] ?? 'Loading...'),
      ],
    );
  }

  Widget _infoRow(IconData icon, String title, String info) {
    return Padding(
      padding: const EdgeInsets.only(left: 70.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              Text(
                info,
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

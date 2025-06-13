import 'dart:convert';

import 'package:courier/app/core/theme/theme.dart';
import 'package:courier/app/modules/Documents/views/documents_view.dart';
import 'package:courier/app/modules/Earnings/views/earnings_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    fetchWorkerDetails();
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Get.offAllNamed('/authentication?index=0');
  }

  Future<void> fetchWorkerDetails({bool isRefresh = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      logout();
      return;
    }

    final url = Uri.parse('http://192.168.49.195:5183/api/workerdetails/getworkerdetails');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          userData = data;
          isLoading = false;
        });
        if (isRefresh) _refreshController.refreshCompleted();
      } else {
        throw Exception('Failed to load worker data');
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (isRefresh) _refreshController.refreshFailed();
      print('Error fetching worker data: $e');
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
            : SmartRefresher(
                controller: _refreshController,
                onRefresh: () => fetchWorkerDetails(isRefresh: true),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Center(child: _buildAvatar()),
                      const SizedBox(height: 27),
                      _buildProfileInfo(),
                      const SizedBox(height: 25),
                      _buildNavigationIcons(),
                      const SizedBox(height: 25),
                      _buildAdditionalInfo(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
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
      child:  ClipOval(
      child: userData != null &&
              userData!['profileImagePath'] != null &&
              userData!['profileImagePath'].toString().isNotEmpty
          ? Image.network(
              'http://192.168.49.195:5183/${userData!['profileImagePath']}',
              fit: BoxFit.cover,
              width: 120,
              height: 120,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.person,
                size: 80,
                color: Color.fromARGB(255, 70, 69, 75),
              ),
            )
          : const Icon( 
              Icons.person,
              size: 80,
              color: Color.fromARGB(255, 70, 69, 75),
            ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      children: [
        Text(
          userData?['fullName'] ?? 'Loading...',
          style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 2),
        Text(
          'License No.: ${userData?['licenseNumber'] ?? 'Loading...'}',
          style: const TextStyle(fontSize: 15, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildNavigationIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _iconBox(Icons.cases_outlined, () {
          Get.to(() => EarningsView());
        }),
        const SizedBox(width: 24),
        _iconBox(Icons.description_outlined, () {
          Get.to(() => DocumentsView(
                licenseImagePath: userData?['licenseNumberImagePath'],
                nidImagePath: userData?['nationalIdNumberImagePath'],
                vehicleImagePath: userData?['vehicleRegistrationNumberImagePath'],
              ));
        }),
        const SizedBox(width: 24),
        _iconBox(Icons.logout_outlined, logout),
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
        const SizedBox(height: 23),
        _infoRow(Icons.email_outlined, 'Email Address', userData?['email'] ?? 'Loading...'),
        const SizedBox(height: 23),
        _infoRow(Icons.perm_identity, 'National ID No.', userData?['nationalIdNumber'] ?? 'Loading...'),
        const SizedBox(height: 23),
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

import 'package:courier/app/core/theme/theme.dart';
import 'package:courier/app/modules/Documents/views/documents_view.dart';
import 'package:courier/app/modules/ProfileDetails/views/profile_details_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: MaterialTheme.blueColorScheme().primary,
      appBar: AppBar(
        backgroundColor: MaterialTheme.blueColorScheme().secondary,
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/firstLayer.jpg'),
            fit: BoxFit.cover,
          ),
        ),

        child: Column(
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
        Obx(() => Text(
          controller.user.value.fullname ?? 'Loading...',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        )),
        const SizedBox(height: 2),
        Obx(() => Text(
          'License No.: ${controller.user.value.licenseNumber ?? 'Loading...'}',
          style: const TextStyle(fontSize: 14, color: Colors.black),
        )),

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
          // Future implementation for Menu Options
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
        Obx(() => _infoRow(Icons.location_on_outlined, 'Address', controller.user.value.homeAddress ?? 'Loading...')),
        Obx(() => _infoRow(Icons.email_outlined, 'Email Address', controller.user.value.email ?? 'Loading...')),
        Obx(() => _infoRow(Icons.perm_identity, 'National ID No.', controller.user.value.nationalIDNumber ?? 'Loading...')),
        Obx(() => _infoRow(Icons.phone_outlined, 'Phone Number', controller.user.value.contactNumber ?? 'Loading...')),
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
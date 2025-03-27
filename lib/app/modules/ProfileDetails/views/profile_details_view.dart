import 'package:courier/app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_details_controller.dart';

class ProfileDetailsView extends GetView<ProfileDetailsController> {
  const ProfileDetailsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaterialTheme.blueColorScheme().primary,
      appBar: AppBar(
        backgroundColor: MaterialTheme.blueColorScheme().secondary,
        title: const Text('Profile Details'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ProfileDetailsView plus maps',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

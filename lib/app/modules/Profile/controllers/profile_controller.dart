import 'package:courier/app/data/models/user_model.dart';
import 'package:courier/app/data/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final Rx<UserModel> user = UserModel().obs;
  final RxBool isLoading = false.obs;

  // Simulate email from login — ideally get it from a global state
  final String loggedInUserEmail = 'johndoe@example.com';

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    isLoading.value = true;
    try {
      final ApiService apiService = ApiService();
      final userData = await apiService.getUserData(loggedInUserEmail);
      user.value = userData;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load profile data: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

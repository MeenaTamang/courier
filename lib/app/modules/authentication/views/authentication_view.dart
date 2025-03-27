import 'package:courier/app/modules/authentication/views/login_screen.dart';
import 'package:courier/app/modules/authentication/views/signup_screen.dart';
import 'package:courier/app/modules/authentication/views/signup_second.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AuthenticationView extends StatefulWidget {
  const AuthenticationView({super.key});

  @override
  State<AuthenticationView> createState() => _AuthenticationViewState();
}

class _AuthenticationViewState extends State<AuthenticationView> {
  late PageController controller;

  @override
  void initState() {
    super.initState();
    int initialPage = int.tryParse(Get.parameters['index'] ?? '0') ?? 0;
    controller = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        controller: controller,
        itemBuilder: (context, index) {
          if (index == 0) {
            return LoginScreen(controller: controller);
          } else if (index == 1) {
            return SignUpScreen(controller: controller);
          } else {
            return SignUpSecond(controller: controller);
          }
        },
      ),
    );
  }
}

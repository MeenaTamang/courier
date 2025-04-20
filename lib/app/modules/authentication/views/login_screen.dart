import 'dart:async';
import 'dart:convert';

import 'package:courier/app/core/theme/theme.dart';
import 'package:courier/app/modules/Profile/controllers/profile_controller.dart';
import 'package:courier/app/modules/bottomNavBar/views/bottom_nav_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller});
  final PageController controller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //to fetch the data to profile_view.dart
  final ProfileController profileController = Get.put(ProfileController());

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _isLoading = false;

  Future<void> loginUser() async {
    try {
      setState(() => _isLoading = true);

      final url = "http://192.168.49.16:5183/api/login/login";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "email": _emailController.text,
          "password": _passController.text,
        }),
      ).timeout(const Duration(seconds: 10));

      final jsonData = jsonDecode(response.body);

      if (jsonData["success"] == true) {
        // Convert userId to String
        // final String userId = jsonData["data"]; // because "data" itself IS the userId (UUID)
        String userId = jsonData["data"]; // or jsonData["data"]["userId"] if it's nested

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavBarView(userId: userId), //  Pass as String
          ),
        );
      } else {
        final String message = jsonData["message"] ?? "Login failed";
        final List<dynamic> errors = jsonData["errors"] ?? [];
        String displayMessage = message + (errors.isNotEmpty ? "\n${errors.join('\n')}" : "");

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(displayMessage)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/logsign.jpg"),
          alignment: Alignment.bottomCenter,
          fit: BoxFit.cover,
              ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 200),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Welcome Text
                      const Text(
                        'Courier Counter',
                        style: TextStyle(
                          color: Color.fromARGB(255, 50, 50, 51),
                          fontSize: 30,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Log in to your account',
                        style: TextStyle(
                          color: Color.fromARGB(255, 50, 50, 51),
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Email TextField
                      TextField(
                        controller: _emailController,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Color.fromARGB(255, 50, 50, 51),
                          ),
                          labelText: 'Enter your email',
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              width: 1,
                              color: Color.fromARGB(255, 50, 50, 51),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              width: 1,
                              color: Color.fromARGB(255, 50, 50, 51),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
            
                      // Password TextField
                      TextField(
                        controller: _passController,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: Color.fromARGB(255, 50, 50, 51),
                          ),
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              width: 1,
                              color: Color.fromARGB(255, 50, 50, 51),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              width: 1,
                              color: Color.fromARGB(255, 50, 50, 51),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
            
                      // Log In Button
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                        child: SizedBox(
                          width: 300,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading
                              ? null
                              : () async {
                                  await loginUser();
                                },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MaterialTheme.blueColorScheme().onSecondaryContainer,
                            ),
                            child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Log In',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 15,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                          ),
                        ),
                      ),
            
            
                      const SizedBox(height: 15),
            
                      // Sign Up Navigation
                      Row(
                        children: [
                          const Text(
                            'Don’t have an account?',
                            style: TextStyle(
                              color: Color.fromARGB(255, 50, 50, 51),
                              fontSize: 13,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 2.5),
                          InkWell(
                            onTap: () {
                              widget.controller.animateToPage(1,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease);
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color.fromARGB(255, 80, 128, 219),
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
            
                      // Forgot Password Link
                      const Text(
                        'Forget Password?',
                        style: TextStyle(
                          color: Color.fromARGB(255, 80, 128, 219),
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  }
}

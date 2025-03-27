import 'dart:async';
import 'dart:convert';

import 'package:courier/app/core/theme/theme.dart';
import 'package:courier/app/modules/bottomNavBar/views/bottom_nav_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// impot 'package:courier/app/core/config/api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller});
  final PageController controller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _isLoading = false;

  // Function to send login data to the API
  Future<void> loginUser() async {
  try {
    setState(() => _isLoading = true);
    
    final url = "http://192.168.18.7:5183/api/login/login";
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: jsonEncode({
        "email": _emailController.text,
        "password": _passController.text,
      }),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TimeoutException('Request timed out'),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavBarView()),
      );
    } else {
      String message = "Login Failed: ${response.statusCode}";
      if (response.statusCode == 401) {
        message = "Invalid email or password";
      } else if (response.statusCode == 500) {
        message = "Server error occurred";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaterialTheme.blueColorScheme().primary,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/images/bg.png"),
                alignment: Alignment.bottomCenter,
                fit: BoxFit.cover
              ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 45),
                child: Image.asset(
                  "assets/images/car1.png",
                  width: 330,
                  height: 300,
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            backgroundColor: MaterialTheme.blueColorScheme().surfaceTint,
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
                              color: Color.fromARGB(255, 243, 187, 55),
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
                        color: Color.fromARGB(255, 243, 187, 55),
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

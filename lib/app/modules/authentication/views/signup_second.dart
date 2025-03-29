import 'dart:convert';

import 'package:courier/app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class SignUpSecond extends StatefulWidget {
  final String fullName;
  final String email;
  final String password;
  final String contactNumber;
  final String homeAddress;
  // final PageController pageController;


  final PageController controller;
  // final String userId;

  const SignUpSecond({
    required this.fullName,
    required this.email,
    required this.password,
    required this.contactNumber,
    required this.homeAddress,
    // required this.pageController,
    required this.controller,
  });
  
  @override
  State<SignUpSecond> createState() => _SignUpSecondState();
}

class _SignUpSecondState extends State<SignUpSecond> {
  final TextEditingController _vehicleNumberController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _nationalIDNumberController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    // Clean up all TextEditingControllers
    _vehicleNumberController.dispose();
    _licenseNumberController.dispose();
    _nationalIDNumberController.dispose();
    
    super.dispose();
  }

  bool _validateForm() {
    if (_vehicleNumberController.text.isEmpty ||
        _licenseNumberController.text.isEmpty ||
        _nationalIDNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields"))
      );
      return false;
    }
    return true;
  }


    Future<void> _registerUser() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://192.168.18.7:5183/api/registration/create'),
        headers: {
          "Content-Type": "application/json"},
        body: jsonEncode({
          "fullName": widget.fullName,
          "email": widget.email,
          "password": widget.password,
          "contactNumber": widget.contactNumber,
          "homeAddress": widget.homeAddress,
          "vehicleRegistrationNumber": _vehicleNumberController.text.trim(),
          "licenseNumber": _licenseNumberController.text.trim(),
          "nationalIdNumber": _nationalIDNumberController.text.trim(),
        }),
      );

      if (response.body.isEmpty) throw Exception("Empty response from server");

      final data = jsonDecode(response.body);
      if (data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Complete!")),
        );
        Navigator.pop(context);
      } else {
        throw Exception(data["message"] ?? "Registration failed");
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
                image:DecorationImage(image:AssetImage("assets/images/bg.png"),
                alignment: Alignment.bottomCenter,
                fit: BoxFit.cover
                ),
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 15),
                child: Image.asset(
                  "assets/images/car1.png",
                    width: 270,
                    height: 275,
                ),
              ),
          
              // const SizedBox(
              //   height: 18,
              // ),
          
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  textDirection: TextDirection.ltr,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Identification Document',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 23,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
          
                    //Vehicle Number
                    SizedBox(
                      height: 40,
                      child: TextField(
                        controller: _vehicleNumberController,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Vehicle Registration Number',
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
                    ),

                  const SizedBox(
                      height: 25,
                    ),

                    //license number
                    SizedBox(
                      height: 40,
                      child: TextField(
                        controller: _licenseNumberController,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'License Number',
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
                    ),
          
                    const SizedBox(
                      height: 25,
                    ),
                    

                    //National ID Number
                    SizedBox(
                      height: 40,
                      child: TextField(
                            controller: _nationalIDNumberController,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontSize: 13,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'National ID Number',
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
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    //Create Account Button
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      child: SizedBox(
                        width: 300,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : _registerUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MaterialTheme.blueColorScheme().surfaceTint,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Create account',
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

                    const SizedBox(
                      height: 15,
                    ),

                    //Already have an account
                    Row(
                      children: [
                        const Text(
                          ' have an account?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromARGB(255, 50, 50, 51),
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(
                          width: 2.5,
                        ),
                        InkWell(
                          onTap: () {
                            widget.controller.animateToPage(0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease);
                          },
                          child: const Text(
                            'Log In ',
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
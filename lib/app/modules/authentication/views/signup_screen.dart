import 'package:courier/app/core/theme/theme.dart';
import 'package:flutter/material.dart';

import 'signup_second.dart';



class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required this.controller});
  final PageController controller;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // final PageController _pageController = PageController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _homeAddressController = TextEditingController();

  bool _isLoading = false;
    // String? userId; // Store user ID for the second screen

    @override
    void dispose() {
      // Clean up all TextEditingControllers
      _fullnameController.dispose();
      _emailController.dispose();
      _passController.dispose();
      _contactNumberController.dispose();
      _homeAddressController.dispose();
      
      super.dispose();
    }

    bool _validateForm() {
      if (_fullnameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _passController.text.isEmpty ||
          _contactNumberController.text.isEmpty ||
          _homeAddressController.text.isEmpty) {
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
        // Gather data but don't call API yet, just pass it to the next screen
        String fullName = _fullnameController.text.trim();
        String email = _emailController.text.toLowerCase().trim();
        String password = _passController.text;
        String contactNumber = _contactNumberController.text.trim();
        String homeAddress = _homeAddressController.text.trim();

        // Navigate to the second screen and pass collected data along with userId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpSecond(
              fullName: fullName,
              email: email,
              password: password,
              contactNumber: contactNumber,
              homeAddress: homeAddress, controller: PageController(),
            ),
          ),
        );
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
              image:DecorationImage(
                image:AssetImage("assets/images/bg.png"),
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
                      'Personal Detail',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 27,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
          
                    //fullname textfield
                    SizedBox(
                      height: 40,
                      child: TextField(
                        controller: _fullnameController,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.person_outlined,
                            color: Color.fromARGB(255, 50, 50, 51),
                          ),
                          labelText: 'Full Name',
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
                      height: 16,
                    ),

                    //email
                    SizedBox(
                      height: 40,
                      child: TextField(
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
                          color: Color.fromARGB(255, 50, 50, 51),),
                          labelText: 'Email',
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
                      height: 16,
                    ),
                    
                    //password
                    SizedBox(
                      height: 40,
                      child: TextField(
                            controller: _passController,
                            obscureText: true,
                            obscuringCharacter: '*',
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
                                color: Color.fromARGB(255, 50, 50, 51),),
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
                    ),
                    const SizedBox(
                      height: 16,
                    ),

                    //contact
                    SizedBox(
                      height: 40,
                      child: TextField(
                            controller: _contactNumberController,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontSize: 13,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                color: Color.fromARGB(255, 50, 50, 51),),
                              labelText: 'Contact Number',
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
                      height: 16,
                    ),

                    //homeAddress
                    SizedBox(
                      height: 40,
                      child: TextField(
                            controller: _homeAddressController,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontSize: 13,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(
                                Icons.location_on_outlined,
                                color: Color.fromARGB(255, 50, 50, 51),),
                              labelText: 'Home Address',
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

                    //next button
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
                                  'Next',
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

                    //already have an account
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
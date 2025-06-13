import 'package:courier/app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'signup_second.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required this.controller});
  final PageController controller;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _homeAddressController = TextEditingController();

  final _fullnameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _contactFocus = FocusNode();
  final _addressFocus = FocusNode();

  final RefreshController _refreshController = RefreshController(initialRefresh: false);


  bool _isLoading = false;

  // Regex patterns for validation
  static final RegExp _noNumbersRegex = RegExp(r'^[^0-9]*$');

  // Track touched fields
  final _touchedFields = <String>{};

  @override
  void initState() {
    super.initState();

    _fullnameFocus.addListener(() => _validateOnFocusLost('fullname'));
    _emailFocus.addListener(() => _validateOnFocusLost('email'));
    _passwordFocus.addListener(() => _validateOnFocusLost('password'));
    _contactFocus.addListener(() => _validateOnFocusLost('contact'));
    _addressFocus.addListener(() => _validateOnFocusLost('address'));
  }

  void _validateOnFocusLost(String field) {
    if (!_getFocusNodeByName(field).hasFocus) {
      setState(() {
        _touchedFields.add(field);
      });
    }
  }

  FocusNode _getFocusNodeByName(String name) {
    switch (name) {
      case 'fullname':
        return _fullnameFocus;
      case 'email':
        return _emailFocus;
      case 'password':
        return _passwordFocus;
      case 'contact':
        return _contactFocus;
      case 'address':
        return _addressFocus;
      default:
        return FocusNode();
    }
  }

   // Validation methods
  String? validateFullName(String? value) {
    if (!_touchedFields.contains('fullname')) return null;
    if (value == null || value.isEmpty) return 'Please enter your full name';
    if (value.contains(RegExp(r'[0-9]'))) return 'Name should not contain numbers';
    if (value.length < 2) return 'Name must be at least 2 characters long';
    return null;
  }

  String? validateEmail(String? value) {
    if (!_touchedFields.contains('email')) return null;
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailPattern.hasMatch(value)) return 'Invalid email format';
    return null;
  }

  String? validatePassword(String? value) {
    if (!_touchedFields.contains('password')) return null;
    if (value == null || value.isEmpty) return 'Please enter your password';
    final passwordPattern = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&]).{8,}$');
    if (!passwordPattern.hasMatch(value)) {
      return 'Password must be 8+ chars, include letter, number & symbol';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (!_touchedFields.contains('contact')) return null;
    if (value == null || value.isEmpty) return 'Please enter your phone number';
    final phonePattern = RegExp(r'^\d{10}$');
    if (!phonePattern.hasMatch(value)) return 'Phone number must be 10 digits';
    return null;
  }

  String? validateHomeAddress(String? value) {
    if (!_touchedFields.contains('address')) return null;
    if (value == null || value.isEmpty) return 'Please enter your home address';
    return null;
  }

  // @override
  // void dispose() {
  //   _fullnameController.dispose();
  //   _emailController.dispose();
  //   _passwordController.dispose();
  //   _contactNumberController.dispose();
  //   _homeAddressController.dispose();

  //   _fullnameFocus.dispose();
  //   _emailFocus.dispose();
  //   _passwordFocus.dispose();
  //   _contactFocus.dispose();
  //   _addressFocus.dispose();

  //   super.dispose();
  // }

  Future<void> _registerUser() async {
    setState(() {
      _touchedFields.addAll(['fullname', 'email', 'password', 'contact', 'address']);
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpSecond(
            fullName: _fullnameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            contactNumber: _contactNumberController.text.trim(),
            homeAddress: _homeAddressController.text.trim(),
            controller: PageController(),
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

void _onRefresh() async {
    setState(() {
      _formKey.currentState?.reset();
      _fullnameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _contactNumberController.clear();
      _homeAddressController.clear();
      _touchedFields.clear();
    });

    await Future.delayed(const Duration(milliseconds: 500));
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _contactNumberController.dispose();
    _homeAddressController.dispose();
    _fullnameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _contactFocus.dispose();
    _addressFocus.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/firstLayer.jpg"),
              alignment: Alignment.bottomCenter,
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/secondLayer.png"),
                  alignment: Alignment.bottomCenter,
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 200),
                      const Text('Personal Detail', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 25),
                      _buildTextField('Full Name', Icons.person_outlined, _fullnameController, _fullnameFocus, validateFullName, inputFormatters: [FilteringTextInputFormatter.allow(_noNumbersRegex)]),
                      const SizedBox(height: 16),
                      _buildTextField('Email', Icons.email_outlined, _emailController, _emailFocus, validateEmail),
                      const SizedBox(height: 16),
                      _buildTextField('Password', Icons.lock_outline_rounded, _passwordController, _passwordFocus, validatePassword, obscureText: true),
                      const SizedBox(height: 16),
                      _buildTextField('Contact Number', Icons.phone_outlined, _contactNumberController, _contactFocus, validatePhoneNumber, keyboardType: TextInputType.phone),
                      const SizedBox(height: 16),
                      _buildTextField('Home Address', Icons.location_on_outlined, _homeAddressController, _addressFocus, validateHomeAddress),
                      const SizedBox(height: 25),
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                        child: SizedBox(
                          width: 300,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _registerUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MaterialTheme.blueColorScheme().onSecondaryContainer,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Next', style: TextStyle(fontSize: 15)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          const Text(' have an account?', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 2.5),
                          InkWell(
                            onTap: () => widget.controller.animateToPage(0, duration: const Duration(milliseconds: 500), curve: Curves.ease),
                            child: const Text('Log In', style: TextStyle(color: Color.fromARGB(255, 80, 128, 219), fontSize: 13)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller,
    FocusNode focusNode,
    String? Function(String?) validator, {
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 50, 50, 51)),
        labelText: label,
        labelStyle: const TextStyle(fontSize: 15),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(width: 1, color: Color.fromARGB(255, 50, 50, 51)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(width: 1, color: Color.fromARGB(255, 50, 50, 51)),
        ),
      ),
    );
  }
}
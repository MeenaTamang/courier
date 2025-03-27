import 'package:courier/app/core/theme/theme.dart';
import 'package:courier/app/modules/home/views/background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
  Size size = MediaQuery.of(context).size;

    return Background(
      child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: size.height * 0.73),

      
                Material(
                  color: Colors.transparent, // Keeps the Material widget from changing the background
                  child: InkWell(
                    onTap: () {
                      Get.toNamed('/authentication?index=1');
                    },
                    // onTap: () {
                    //   controller.animateToPage(
                    //     1,
                    //     duration: const Duration(milliseconds: 300),
                    //     curve: Curves.easeInOut,
                    //   );
                    // },
                    borderRadius: BorderRadius.circular(20), // Ensures ripple effect follows the shape
                    child: Ink(
                      height: 40,
                      width: 160,
                      decoration: BoxDecoration(
                        color: MaterialTheme.blueColorScheme().surfaceTint,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          "Create an account",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: 25,
                ),

                Material(
                  color: Colors.transparent, // Keeps the Material widget from changing the background
                  child: InkWell(
                    onTap: () {
                      Get.toNamed('/authentication?index=0');
                    },
                    borderRadius: BorderRadius.circular(20), // Ensures ripple effect follows the shape
                    child: Ink(
                      height: 40,
                      width: 160,
                      decoration: BoxDecoration(
                        color: MaterialTheme.blueColorScheme().surfaceTint,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          "Login ",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        
        

      ],
    ),
    );
  }
}

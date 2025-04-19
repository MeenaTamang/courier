import 'package:flutter/material.dart';


class Background extends StatelessWidget {
  final Widget child; // Accepts child widget

  const Background({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size; // Get screen size

    return SizedBox.expand(
      child: Stack(
        children: [
          //Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background.jpg',
          fit: BoxFit.cover,
          ),
          ),

          Positioned.fill(child: SafeArea(child: child,
          ),
          ),

        ],
      ),
    );
  }
}

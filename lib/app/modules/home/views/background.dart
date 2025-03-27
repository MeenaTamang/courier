import 'package:courier/app/core/theme/theme.dart';
import 'package:flutter/material.dart';


class Background extends StatelessWidget {
  final Widget child; // Accepts child widget

  const Background({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; // Get screen size

    return Container(
      color: MaterialTheme.blueColorScheme().primary,
      height: size.height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Background Image at Bottom
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              "assets/images/rd_img.png",
              width: size.width,
            ),
          ),

          //delivery_scooty center
          Positioned(
            bottom: size.height * 0.4 , // Move it up from bottom
            left: size.width * 0.2,    // Adjust horizontal position
            child: Image.asset(
              "assets/images/deliveryCenter.png",
            width: size.width * 0.6,  // Adjust width to make it smaller
              ),
          ),


          // Logo Image at Center Top
          Positioned(
            top: 160,
            left: 20,
            child: Image.asset(
              "assets/icons/fullLogo.png",
              height: size.height * 0.17,
            ),
          ),

          // Yellow Image at Top Right
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              "assets/images/img_yellow.png",
              width: size.width * 0.6,
            ),
          ),

          // Child Widget (Body Content)
          child,
        ],
      ),
    );
  }
}

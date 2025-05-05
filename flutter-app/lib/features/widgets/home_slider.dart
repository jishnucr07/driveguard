import 'package:flutter/material.dart';
import 'package:forked_slider_button/forked_slider_button.dart';

class CustomSliderButton extends StatelessWidget {
  final Future<bool?> Function() func;
  final String imagePath;
  const CustomSliderButton(
      {super.key, required this.func, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return SliderButton(
      dismissible: false,
      // disable: true,
      width: 240,
      height: 90,
      action: func,
      label: const Text(
        "Swipe to Start",
        style: TextStyle(
          color: Color(0xff4a4a4a),
          fontWeight: FontWeight.w500,
          fontSize: 17,
        ),
      ),
      icon: SizedBox(
        height: 20,
        width: 20,
        child: Image.asset(imagePath),
      ),
    );
  }
}

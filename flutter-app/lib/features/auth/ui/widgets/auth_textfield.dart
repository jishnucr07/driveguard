import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hinText;
  final bool isPassword;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hinText,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hinText,
        hintStyle: GoogleFonts.saira(
          color: const Color.fromARGB(255, 106, 106, 106),
          fontWeight: FontWeight.w500,
        ),
        contentPadding:
            EdgeInsets.symmetric(vertical: 20, horizontal: 12), // Adjust height
        enabledBorder: OutlineInputBorder(
          // No border when unfocused
          borderSide: BorderSide.none, // Hide border
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          // Show border when focused
          borderSide: BorderSide(
              color: const Color.fromARGB(255, 23, 106, 174),
              width: 2), // Customize border
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true, // Add background color
        fillColor: const Color.fromARGB(255, 23, 106, 174).withOpacity(0.1),
        // Background color when unfocused
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return ""; // Empty error message
        }
        return null;
      },
    );
  }
}

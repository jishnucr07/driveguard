import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthButton extends StatelessWidget {
  final VoidCallback onTap;
  final String buttonText;

  const AuthButton({
    super.key,
    required this.onTap,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 10, 93, 209),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 13, 105, 235)
                  .withOpacity(0.3), // Shadow color
              blurRadius: 12, // Spread of the shadow
              offset: Offset(5, 10), // Shadow offset (x, y)
            ),
          ],
        ),
        child: Center(
          child: Text(
            buttonText,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17),
          ),
        ),
      ),
    );
  }
}

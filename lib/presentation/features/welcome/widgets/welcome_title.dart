import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeTitle extends StatelessWidget {
  const WelcomeTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'AgriConnect',
      style: GoogleFonts.montserrat(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.2,
      ),
    );
  }
}

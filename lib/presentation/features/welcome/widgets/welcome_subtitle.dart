import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeSubtitle extends StatelessWidget {
  const WelcomeSubtitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Connectons l'agriculture",
      style: GoogleFonts.montserrat(
        fontSize: 18,
        color: Colors.white70,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

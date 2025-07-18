import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterTitle extends StatelessWidget {
  final String title;
  const RegisterTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.1,
      ),
      textAlign: TextAlign.center,
    );
  }
}

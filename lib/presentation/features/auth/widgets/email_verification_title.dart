import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmailVerificationTitle extends StatelessWidget {
  final String title;
  const EmailVerificationTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

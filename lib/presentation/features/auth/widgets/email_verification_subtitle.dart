import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmailVerificationSubtitle extends StatelessWidget {
  final String subtitle;
  const EmailVerificationSubtitle({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Text(
      subtitle,
      style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 16),
      textAlign: TextAlign.center,
    );
  }
}

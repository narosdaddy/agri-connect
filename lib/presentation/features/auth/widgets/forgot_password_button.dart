import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordButton extends StatelessWidget {
  final VoidCallback onPressed;
  const ForgotPasswordButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          'Mot de passe oublié ?',
          style: GoogleFonts.montserrat(color: Colors.white),
        ),
      ),
    );
  }
}

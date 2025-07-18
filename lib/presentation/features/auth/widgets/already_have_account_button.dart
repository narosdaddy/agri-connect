import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AlreadyHaveAccountButton extends StatelessWidget {
  final VoidCallback onPressed;
  const AlreadyHaveAccountButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Déjà un compte ? ',
          style: GoogleFonts.montserrat(color: Colors.white70),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            'Se connecter',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

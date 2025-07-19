import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agri_marketplace/presentation/features/auth/pages/phone_auth_screen.dart';

class WelcomePhoneButton extends StatelessWidget {
  const WelcomePhoneButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PhoneAuthScreen()),
        );
      },
      icon: const Icon(Icons.phone, color: Colors.white),
      label: Text(
        'Continuer avec numéro de téléphone',
        style: GoogleFonts.montserrat(color: Colors.white),
      ),
    );
  }
}

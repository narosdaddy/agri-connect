import 'package:flutter/material.dart';
import 'package:agri_marketplace/presentation/features/auth/pages/login_screen.dart';
import 'package:agri_marketplace/presentation/features/auth/pages/register_screen.dart';
import 'package:agri_marketplace/presentation/features/auth/pages/phone_auth_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agri_marketplace/presentation/features/welcome/widgets/welcome_logo.dart';
import 'package:agri_marketplace/presentation/features/welcome/widgets/welcome_title.dart';
import 'package:agri_marketplace/presentation/features/welcome/widgets/welcome_subtitle.dart';
import 'package:agri_marketplace/presentation/features/welcome/widgets/welcome_login_button.dart';
import 'package:agri_marketplace/presentation/features/welcome/widgets/welcome_register_button.dart';
import 'package:agri_marketplace/presentation/features/welcome/widgets/welcome_phone_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _WelcomeBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Spacer(),
                  WelcomeLogo(),
                  SizedBox(height: 30),
                  WelcomeTitle(),
                  SizedBox(height: 10),
                  WelcomeSubtitle(),
                  Spacer(),
                  WelcomeLoginButton(),
                  SizedBox(height: 15),
                  WelcomeRegisterButton(),
                  SizedBox(height: 20),
                  WelcomePhoneButton(),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget d'arrière-plan extrait (potentiellement partagé)
class _WelcomeBackground extends StatelessWidget {
  const _WelcomeBackground();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.18,
          child: Image.network(
            'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF4CAF50).withOpacity(0.85),
                const Color(0xFF81C784).withOpacity(0.85),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

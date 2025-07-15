import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'phone_auth_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond avec motif de feuilles en opacité faible
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
                colors: [Color(0xFF4CAF50).withOpacity(0.85), Color(0xFF81C784).withOpacity(0.85)],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  // Logo AgriConnect
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.agriculture,
                      size: 60,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'AgriConnect',
                    style: GoogleFonts.montserrat(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Connectons l\'agriculture',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  // Boutons
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    LoginScreen(),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return SlideTransition(
                                position: animation.drive(
                                  Tween(
                                    begin: Offset(1.0, 0.0),
                                    end: Offset.zero,
                                  ),
                                ),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF4CAF50),
                        elevation: 6,
                        shadowColor: Color(0xFF4CAF50).withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        'Se connecter',
                        style: GoogleFonts.montserrat(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    RegisterScreen(),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return SlideTransition(
                                position: animation.drive(
                                  Tween(
                                    begin: Offset(1.0, 0.0),
                                    end: Offset.zero,
                                  ),
                                ),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        shadowColor: Colors.black12,
                        elevation: 0,
                      ),
                      child: Text(
                        'Créer un compte',
                        style: GoogleFonts.montserrat(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhoneAuthScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.phone, color: Colors.white),
                    label: Text(
                      'Continuer avec numéro de téléphone',
                      style: GoogleFonts.montserrat(color: Colors.white),
                    ),
                  ),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';
import '../routes.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'email_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
                colors: [Color(0xFF4CAF50).withOpacity(0.85), Color(0xFF81C784).withOpacity(0.85)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Rejoignez AgriConnect',
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    // Nom
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nom complet',
                        labelStyle: GoogleFonts.montserrat(),
                        prefixIcon: Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.95),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre nom';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: GoogleFonts.montserrat(),
                        prefixIcon: Icon(Icons.email),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.95),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    // Téléphone
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Numéro de téléphone',
                        labelStyle: GoogleFonts.montserrat(),
                        prefixIcon: Icon(Icons.phone),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.95),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numéro';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    // Mot de passe
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        labelStyle: GoogleFonts.montserrat(),
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.95),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un mot de passe';
                        }
                        if (value.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    // Confirmation mot de passe
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirmer le mot de passe',
                        labelStyle: GoogleFonts.montserrat(),
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.95),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    // Bouton d'inscription
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: Provider.of<AuthService>(context, listen: false).isLoading ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          elevation: 6,
                          shadowColor: Color(0xFF4CAF50).withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Provider.of<AuthService>(context, listen: false).isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'S\'inscrire',
                                style: GoogleFonts.montserrat(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);

      print('Données d\'inscription :');
      print('Nom: ${_nameController.text.trim()}');
      print('Email: ${_emailController.text.trim()}');
      print('Téléphone: ${_phoneController.text.trim()}');

      bool success = await authService.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      print('Résultat de l\'inscription : $success');

      if (success) {
        // Naviguer vers la page de vérification de code
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(
              email: _emailController.text.trim(),
            ),
          ),
        );
      }
    }
  }
}

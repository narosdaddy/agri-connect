import 'package:agri_marketplace/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'forgot_password_screen.dart';
import '../routes.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

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
                    SizedBox(height: 40),
                    Icon(Icons.agriculture, size: 80, color: Color(0xFF4CAF50)),
                    SizedBox(height: 20),
                    Text(
                      'Bon retour !',
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),
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
                          return 'Veuillez entrer un email valide';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
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
                          return 'Veuillez entrer votre mot de passe';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    // Mot de passe oublié
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Mot de passe oublié ?',
                          style: GoogleFonts.montserrat(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    // Bouton de connexion
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: Provider.of<AuthService>(context, listen: false).isLoading ? null : _signIn,
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
                                'Connexion',
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

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);

      bool success = await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (success) {
        // Récupérer les informations utilisateur pour déterminer le rôle
        final userInfo = await authService.getUserInfo();
        if (userInfo != null) {
          final userRole = userInfo['role']?.toString().toUpperCase() ?? 'ACHETEUR';
          // Navigation selon le rôle
          if (userRole == 'PRODUCTEUR') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.producerDashboard,
              (route) => false,
            );
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          }
        }
      }
    }
  }
}

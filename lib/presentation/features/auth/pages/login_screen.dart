import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agri_marketplace/presentation/features/auth/provider/auth_provider.dart';
import 'package:agri_marketplace/presentation/features/auth/pages/forgot_password_screen.dart';
import 'package:agri_marketplace/presentation/routes/routes.dart';
import 'package:agri_marketplace/data/models/auth_model.dart';
import 'package:agri_marketplace/presentation/features/home/provider/profile_provider.dart';
import 'package:agri_marketplace/presentation/features/auth/widgets/login_logo.dart';
import 'package:agri_marketplace/presentation/features/auth/widgets/login_title.dart';
import 'package:agri_marketplace/presentation/features/auth/widgets/forgot_password_button.dart';
import 'package:agri_marketplace/shared/widgets/custom_text_form_field.dart';
import 'package:agri_marketplace/shared/widgets/primary_button.dart';

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
    final authProvider = Provider.of<AuthProvider>(context);
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
                colors: [
                  const Color(0xFF4CAF50).withOpacity(0.85),
                  const Color(0xFF81C784).withOpacity(0.85),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    const LoginLogo(),
                    const SizedBox(height: 20),
                    const LoginTitle(title: 'Bon retour !'),
                    const SizedBox(height: 40),
                    CustomTextFormField(
                      controller: _emailController,
                      labelText: 'Email',
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Veuillez entrer un email valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      controller: _passwordController,
                      labelText: 'Mot de passe',
                      prefixIcon: Icons.lock,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre mot de passe';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    ForgotPasswordButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    PrimaryButton(
                      label: 'Connexion',
                      onPressed: authProvider.isLoading ? null : _signIn,
                      loading: authProvider.isLoading,
                    ),
                    if (authProvider.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          authProvider.error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      final loginRequest = LoginRequest(
        email: _emailController.text.trim(),
        motDePasse: _passwordController.text.trim(),
      );
      final authResponse = await authProvider.signIn(loginRequest);
      if (authResponse != null && authProvider.token != null) {
        await profileProvider.fetchMyProfile();
        if (profileProvider.error == null) {
          final userRole = authResponse.role?.toUpperCase() ?? 'ACHETEUR';
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
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(profileProvider.error!)));
        }
      }
    }
  }
}

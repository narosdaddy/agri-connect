import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agri_marketplace/presentation/features/auth/provider/auth_provider.dart';
import 'package:agri_marketplace/data/models/auth_model.dart';
import 'package:agri_marketplace/presentation/features/auth/widgets/email_verification_logo.dart';
import 'package:agri_marketplace/presentation/features/auth/widgets/email_verification_title.dart';
import 'package:agri_marketplace/presentation/features/auth/widgets/email_verification_subtitle.dart';
import 'package:agri_marketplace/shared/widgets/primary_button.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  const EmailVerificationScreen({Key? key, required this.email})
    : super(key: key);

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _codeSent = true;

  void _verifyCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final request = EmailVerificationRequest(code: _codeController.text.trim());
    bool success = await authProvider.verifyEmailCode(request);
    if (success) {
      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte vérifié avec succès ! Connectez-vous.'),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Code incorrect ou expiré. Vérifiez votre email.';
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _resendCode() async {
    setState(() {
      _codeSent = false;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.resendVerificationEmail(widget.email);
    setState(() {
      _codeSent = true;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Nouveau code envoyé à ${widget.email}')),
    );
  }

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
                colors: [
                  const Color(0xFF4CAF50).withOpacity(0.85),
                  const Color(0xFF81C784).withOpacity(0.85),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const EmailVerificationLogo(),
                    const SizedBox(height: 20),
                    const EmailVerificationTitle(
                      title: 'Vérification de l\'email',
                    ),
                    const SizedBox(height: 10),
                    const EmailVerificationSubtitle(
                      subtitle: 'Un code à 6 chiffres a été envoyé à :',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        letterSpacing: 8,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.95),
                        hintText: '------',
                        hintStyle: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(
                          color: Colors.grey.shade400,
                          fontSize: 22,
                          letterSpacing: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                        ),
                      ),
                      onChanged: (val) {
                        if (val.length == 6) FocusScope.of(context).unfocus();
                      },
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Valider',
                      onPressed: _isLoading ? null : _verifyCode,
                      loading: _isLoading,
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: _codeSent ? _resendCode : null,
                      child: Text(_codeSent ? 'Renvoyer le code' : 'Envoi...'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        textStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
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
}

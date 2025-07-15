import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  const EmailVerificationScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
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
    final authService = Provider.of<AuthService>(context, listen: false);
    bool success = await authService.verifyEmailCode(_codeController.text.trim());
    if (success) {
      // Rediriger vers la page de connexion après succès
      Navigator.popUntil(context, (route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Compte vérifié avec succès ! Connectez-vous.')),
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
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.resendVerificationEmail(widget.email);
    setState(() {
      _codeSent = true;
    });
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
                colors: [Color(0xFF4CAF50).withOpacity(0.85), Color(0xFF81C784).withOpacity(0.85)],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.mark_email_read, size: 70, color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      'Vérification de l\'email',
                      style: GoogleFonts.montserrat(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Un code à 6 chiffres a été envoyé à :',
                      style: GoogleFonts.montserrat(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.email,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: GoogleFonts.montserrat(fontSize: 22, letterSpacing: 8),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.95),
                        hintText: '------',
                        hintStyle: GoogleFonts.montserrat(color: Colors.grey.shade400, fontSize: 22, letterSpacing: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 18),
                      ),
                      onChanged: (val) {
                        if (val.length == 6) FocusScope.of(context).unfocus();
                      },
                    ),
                    if (_errorMessage != null) ...[
                      SizedBox(height: 10),
                      Text(
                        _errorMessage!,
                        style: GoogleFonts.montserrat(color: Colors.redAccent, fontWeight: FontWeight.w500),
                      ),
                    ],
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF4CAF50),
                          elevation: 6,
                          shadowColor: Color(0xFF4CAF50).withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Color(0xFF4CAF50))
                            : Text(
                                'Valider',
                                style: GoogleFonts.montserrat(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 18),
                    TextButton(
                      onPressed: _codeSent ? _resendCode : null,
                      child: Text(
                        _codeSent ? 'Renvoyer le code' : 'Envoi...'
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
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
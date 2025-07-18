import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:agri_marketplace/presentation/routes/routes.dart';
import 'package:agri_marketplace/presentation/features/auth/provider/auth_provider.dart';
import 'package:agri_marketplace/presentation/features/auth/widgets/phone_auth_logo.dart';
import 'package:agri_marketplace/presentation/features/auth/widgets/phone_auth_title.dart';
import 'package:agri_marketplace/presentation/features/auth/widgets/change_phone_button.dart';
import 'package:agri_marketplace/shared/widgets/custom_text_form_field.dart';
import 'package:agri_marketplace/shared/widgets/primary_button.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  String _generatedOTP = ''; // OTP généré pour le mode développement

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion par téléphone'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 50),
                  const PhoneAuthLogo(),
                  const SizedBox(height: 20),
                  PhoneAuthTitle(
                    title: _otpSent ? 'Vérification OTP' : 'Connexion rapide',
                  ),
                  const SizedBox(height: 40),
                  if (!_otpSent) ...[
                    CustomTextFormField(
                      controller: _phoneController,
                      labelText: 'Numéro de téléphone (+228...)',
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numéro de téléphone';
                        }
                        if (!RegExp(r'^\+[1-9]\d{1,14}$').hasMatch(value)) {
                          return 'Format invalide. Utilisez: +22812345678';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    PrimaryButton(
                      label: 'Envoyer le code',
                      onPressed: authProvider.isLoading ? null : _sendOTP,
                      loading: authProvider.isLoading,
                    ),
                  ] else ...[
                    const Text(
                      'Entrez le code reçu par SMS',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // PinCodeTextField reste inline car dépendant du package et de la logique OTP
                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      controller: _otpController,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(5),
                        fieldHeight: 50,
                        fieldWidth: 40,
                        activeFillColor: Colors.white,
                        inactiveFillColor: Colors.grey,
                        selectedFillColor: Colors.grey[200],
                        activeColor: Color(0xFF4CAF50),
                        inactiveColor: Colors.grey,
                        selectedColor: Color(0xFF4CAF50),
                      ),
                      enableActiveFill: true,
                      onCompleted: (value) {
                        _verifyOTP();
                      },
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 30),
                    PrimaryButton(
                      label: 'Vérifier le code',
                      onPressed: authProvider.isLoading ? null : _verifyOTP,
                      loading: authProvider.isLoading,
                    ),
                    const SizedBox(height: 20),
                    ChangePhoneButton(
                      onPressed: () {
                        setState(() {
                          _otpSent = false;
                          _otpController.clear();
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _sendOTP() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.sendOTP(
        _phoneController.text.trim(),
        onOTPSent: (otp) {
          setState(() {
            _generatedOTP = otp;
            _otpSent = true;
          });
        },
      );
    }
  }

  void _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer le code OTP')),
      );
      return;
    }
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyOTP(
      _phoneController.text.trim(),
      _otpController.text.trim(),
    );
    if (success) {
      if (!mounted) return;
      // Navigation selon le rôle (à adapter selon ta logique)
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code OTP incorrect. Réessayez.')),
      );
      _otpController.clear();
    }
  }
}

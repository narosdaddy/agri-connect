import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../services/auth_service.dart';
import '../routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        title: Text('Connexion par téléphone'),
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 50),
                  Icon(Icons.phone_android, size: 80, color: Color(0xFF4CAF50)),
                  SizedBox(height: 20),
                  Text(
                    _otpSent ? 'Vérification OTP' : 'Connexion rapide',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),

                  if (!_otpSent) ...[
                    // Numéro de téléphone
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Numéro de téléphone (+228...)',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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
                    SizedBox(height: 30),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: authService.isLoading ? null : _sendOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child:
                            authService.isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                  'Envoyer le code',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                  ] else ...[
                    // Champ OTP
                    Text(
                      'Entrez le code reçu par SMS',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
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
                        inactiveFillColor: Colors.grey[100],
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
                    SizedBox(height: 30),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: authService.isLoading ? null : _verifyOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child:
                            authService.isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                  'Vérifier le code',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _otpSent = false;
                          _otpController.clear();
                        });
                      },
                      child: Text(
                        'Changer de numéro',
                        style: TextStyle(color: Color(0xFF4CAF50)),
                      ),
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
      final authService = Provider.of<AuthService>(context, listen: false);
      
      try {
        authService.setLoading(true);
        
        // Vérifier si le numéro de téléphone existe déjà dans les utilisateurs inscrits
        final prefs = await SharedPreferences.getInstance();
        
        // Récupérer tous les utilisateurs inscrits (en mode développement)
        final savedPhone = prefs.getString('user_phone');
        final testBuyerPhone = prefs.getString('test_buyer_phone') ?? '+22812345678';
        final testProducerPhone = prefs.getString('test_producer_phone') ?? '+22887654321';
        
        final phoneToCheck = _phoneController.text.trim();
        
        print('🔍 Vérification du numéro: $phoneToCheck');
        print('📱 Numéros enregistrés:');
        print('- Utilisateur inscrit: $savedPhone');
        print('- Acheteur test: $testBuyerPhone');
        print('- Producteur test: $testProducerPhone');
        
        // Vérifier si le numéro correspond à un utilisateur existant
        bool phoneExists = false;
        String userRole = '';
        String userName = '';
        
        if (phoneToCheck == savedPhone && savedPhone != null) {
          // Utilisateur nouvellement inscrit
          phoneExists = true;
          userRole = prefs.getString('user_role') ?? 'ACHETEUR';
          userName = prefs.getString('user_name') ?? 'Utilisateur';
          print('✅ Numéro trouvé: Utilisateur inscrit ($userName - $userRole)');
        } else if (phoneToCheck == testBuyerPhone) {
          // Utilisateur acheteur de test
          phoneExists = true;
          userRole = 'ACHETEUR';
          userName = prefs.getString('test_buyer_name') ?? 'Acheteur Test';
          print('✅ Numéro trouvé: Acheteur test ($userName - $userRole)');
        } else if (phoneToCheck == testProducerPhone) {
          // Utilisateur producteur de test
          phoneExists = true;
          userRole = 'PRODUCTEUR';
          userName = prefs.getString('test_producer_name') ?? 'Producteur Test';
          print('✅ Numéro trouvé: Producteur test ($userName - $userRole)');
        } else {
          print('❌ Numéro non trouvé: $phoneToCheck');
        }
        
        if (!phoneExists) {
          authService.showToast("Ce numéro de téléphone n'est pas enregistré. Veuillez d'abord vous inscrire.");
          authService.setLoading(false);
          return;
        }
        
        // Simuler l'envoi d'OTP en mode développement
        await Future.delayed(Duration(seconds: 2));
        
        // Générer un OTP de test (6 chiffres)
        _generatedOTP = (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();
        
        print('🔧 MODE DÉVELOPPEMENT: OTP généré: $_generatedOTP');
        print('📱 Numéro de téléphone: $phoneToCheck');
        print('👤 Utilisateur: $userName ($userRole)');
        
        // Afficher l'OTP dans une boîte de dialogue pour les tests
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Code OTP (Mode Développement)'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Code envoyé au $phoneToCheck:'),
                SizedBox(height: 10),
                Text(
                  _generatedOTP,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Utilisateur: $userName ($userRole)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _otpSent = true;
                  });
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
        
        authService.showToast("Code OTP envoyé! (Mode développement)");
        
      } catch (e) {
        authService.showToast("Erreur lors de l'envoi du code: $e");
      } finally {
        authService.setLoading(false);
      }
    }
  }

  void _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer le code OTP')),
      );
      return;
    }
    
    final authService = Provider.of<AuthService>(context, listen: false);
    
    try {
      authService.setLoading(true);
      
      // Simuler la vérification d'OTP en mode développement
      await Future.delayed(Duration(seconds: 1));
      
      if (_otpController.text == _generatedOTP) {
        // OTP correct - authentification réussie
        print('🔧 MODE DÉVELOPPEMENT: OTP vérifié avec succès');
        
        // Récupérer les informations utilisateur selon le numéro de téléphone
        final prefs = await SharedPreferences.getInstance();
        final phoneToCheck = _phoneController.text.trim();
        final savedPhone = prefs.getString('user_phone');
        final testBuyerPhone = prefs.getString('test_buyer_phone') ?? '+22812345678';
        final testProducerPhone = prefs.getString('test_producer_phone') ?? '+22887654321';
        
        String userRole = 'ACHETEUR';
        String userName = 'Utilisateur Téléphone';
        String userEmail = '${phoneToCheck}@phone.auth';
        
        if (phoneToCheck == savedPhone && savedPhone != null) {
          // Utilisateur nouvellement inscrit
          userRole = prefs.getString('user_role') ?? 'ACHETEUR';
          userName = prefs.getString('user_name') ?? 'Utilisateur';
          userEmail = prefs.getString('user_email') ?? userEmail;
        } else if (phoneToCheck == testBuyerPhone) {
          // Utilisateur acheteur de test
          userRole = 'ACHETEUR';
          userName = prefs.getString('test_buyer_name') ?? 'Acheteur Test';
          userEmail = prefs.getString('test_buyer_email') ?? 'acheteur@test.com';
        } else if (phoneToCheck == testProducerPhone) {
          // Utilisateur producteur de test
          userRole = 'PRODUCTEUR';
          userName = prefs.getString('test_producer_name') ?? 'Producteur Test';
          userEmail = prefs.getString('test_producer_email') ?? 'producteur@test.com';
        }
        
        // Sauvegarder les informations utilisateur
        await prefs.setString('user_phone', phoneToCheck);
        await prefs.setString('user_name', userName);
        await prefs.setString('user_email', userEmail);
        await prefs.setString('user_role', userRole);
        await prefs.setBool('is_logged_in', true);
        
        authService.showToast("Connexion par téléphone réussie! (Mode développement)");
        
        // Navigation selon le rôle
        String targetRoute = userRole == 'PRODUCTEUR' 
            ? AppRoutes.producerDashboard 
            : AppRoutes.home;
            
        Navigator.pushNamedAndRemoveUntil(
          context,
          targetRoute,
          (route) => false, // Supprime toutes les routes précédentes
        );
        
      } else {
        // OTP incorrect
        authService.showToast("Code OTP incorrect. Réessayez.");
        _otpController.clear();
      }
      
    } catch (e) {
      authService.showToast("Erreur lors de la vérification: $e");
    } finally {
      authService.setLoading(false);
    }
  }
}

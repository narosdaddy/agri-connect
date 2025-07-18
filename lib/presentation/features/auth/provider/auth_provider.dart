import 'package:flutter/material.dart';
import 'package:agri_marketplace/data/sources/auth_service.dart';
import 'package:agri_marketplace/data/models/auth_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  AuthResponse? _userInfo;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authService);

  AuthResponse? get userInfo => _userInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _userInfo?.token;

  Future<AuthResponse?> signIn(LoginRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _authService.login(request);
      _userInfo = result;
      // Injecte le JWT dans les headers de Dio
      if (result.token != null) {
        _authService.dio.options.headers['Authorization'] =
            'Bearer ${result.token}';
        print('JWT stocké après login: Bearer ${result.token}');
      }
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = 'Erreur lors de la connexion';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<AuthResponse?> signUp(RegisterRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _authService.register(request);
      _userInfo = result;
      // Injecte le JWT dans les headers de Dio
      if (result.token != null) {
        _authService.dio.options.headers['Authorization'] =
            'Bearer ${result.token}';
        print('JWT stocké après inscription: Bearer ${result.token}');
      }
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = 'Erreur lors de l\'inscription';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> verifyEmail(EmailVerificationRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.verifyEmail(request);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la vérification de l\'email';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.forgotPassword(email);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la demande de réinitialisation';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.resetPassword(data);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la réinitialisation';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyEmailCode(EmailVerificationRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _authService.verifyEmailCode(request);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = "Erreur lors de la vérification du code";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> resendVerificationEmail(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.resendVerificationEmail(email);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors de l'envoi du code";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = "Erreur lors de l'envoi du lien";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> sendOTP(String phone, {Function(String otp)? onOTPSent}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final otp = await _authService.sendOTP(phone);
      _isLoading = false;
      notifyListeners();
      if (onOTPSent != null) onOTPSent(otp);
    } catch (e) {
      _error = "Erreur lors de l'envoi du code OTP";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOTP(String phone, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _authService.verifyOTP(phone, otp);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = "Erreur lors de la vérification du code OTP";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void showToast(String message) {
    // À implémenter selon la logique de toast/snackbar globale de l'app
  }

  void signOut() {
    _userInfo = null;
    notifyListeners();
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _accessToken;
  Map<String, dynamic> _userInfo = {};

  String? get accessToken => _accessToken;
  Map<String, dynamic> get userInfo => _userInfo;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void showToast(String message) {
    debugPrint(message);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  Future<void> _saveUserInfo(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_info', jsonEncode(user));
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('jwt_token');
    final userStr = prefs.getString('user_info');
    if (userStr != null) {
      _userInfo = jsonDecode(userStr);
    }
    notifyListeners();
  }

  // REGISTER
  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authRegister}'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );
      setLoading(false);
      return response.statusCode == 201;
    } catch (e) {
      showToast('Erreur lors de l\'inscription: $e');
      setLoading(false);
      return false;
    }
  }

  // LOGIN
  Future<bool> signIn(String email, String password) async {
    setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authLogin}'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({'email': email, 'password': password}),
      );
      setLoading(false);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['token'];
        await _saveToken(_accessToken!);
        _userInfo = data['user'] ?? {};
        await _saveUserInfo(_userInfo);
        notifyListeners();
        return true;
      } else {
        showToast("Identifiants invalides");
        return false;
      }
    } catch (e) {
      showToast('Erreur de connexion: $e');
      setLoading(false);
      return false;
    }
  }

  // VÉRIFICATION DE L'EMAIL
  Future<bool> verifyEmailCode(String code) async {
    setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authVerify}'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({'code': code}),
      );
      setLoading(false);
      return response.statusCode == 200;
    } catch (e) {
      showToast('Erreur lors de la vérification: $e');
      setLoading(false);
      return false;
    }
  }

  // RENVoyer l'email de vérification
  Future<bool> resendVerificationEmail(String email) async {
    setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authResendVerification}?email=$email'),
        headers: ApiConfig.defaultHeaders,
      );
      setLoading(false);
      return response.statusCode == 200;
    } catch (e) {
      showToast('Erreur lors de l\'envoi de l\'email de vérification: $e');
      setLoading(false);
      return false;
    }
  }

  // GET USER PROFILE (requête protégée)
  Future<Map<String, dynamic>?> getUserInfo() async {
    if (_accessToken == null) return null;
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authProfile}'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $_accessToken',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _userInfo = data;
        await _saveUserInfo(data);
        notifyListeners();
        return data;
      }
    } catch (e) {
      showToast('Erreur lors de la récupération du profil: $e');
    }
    return null;
  }

  // EXEMPLE DE REQUÊTE PROTÉGÉE
  Future<http.Response> getProtected(String endpoint) async {
    return await http.get(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: {
        ...ApiConfig.defaultHeaders,
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      },
    );
  }

  // LOGOUT
  Future<void> signOut() async {
    _accessToken = null;
    _userInfo = {};
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_info');
    notifyListeners();
  }
}

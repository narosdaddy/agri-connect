import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../models/auth_model.dart';

class AuthService {
  final Dio dio;
  AuthService(this.dio);

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await dio.post(ApiConfig.login, data: request.toJson());
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await dio.post(ApiConfig.register, data: request.toJson());
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> refreshToken(String refreshToken) async {
    final response = await dio.post(
      ApiConfig.refreshToken,
      data: {'refreshToken': refreshToken},
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<void> verifyEmail(EmailVerificationRequest request) async {
    await dio.post(ApiConfig.verifyEmail, data: request.toJson());
  }

  Future<void> forgotPassword(String email) async {
    await dio.post(ApiConfig.forgotPassword, data: {'email': email});
  }

  Future<void> resetPassword(Map<String, dynamic> data) async {
    await dio.post(ApiConfig.resetPassword, data: data);
  }

  Future<void> phoneAuth(Map<String, dynamic> data) async {
    await dio.post(ApiConfig.phoneAuth, data: data);
  }

  Future<bool> verifyEmailCode(EmailVerificationRequest request) async {
    final response = await dio.post(
      ApiConfig.verifyEmail,
      data: request.toJson(),
    );
    // Supposons que l'API retourne un booléen ou un code de succès
    return response.statusCode == 200;
  }

  Future<void> resendVerificationEmail(String email) async {
    await dio.post(ApiConfig.resendVerificationEmail, data: {'email': email});
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    final response = await dio.post(
      ApiConfig.forgotPassword,
      data: {'email': email},
    );
    return response.statusCode == 200;
  }

  Future<String> sendOTP(String phone) async {
    final response = await dio.post(ApiConfig.sendOTP, data: {'phone': phone});
    // Supposons que l'API retourne l'OTP pour le mode dev
    return response.data['otp'] as String;
  }

  Future<bool> verifyOTP(String phone, String otp) async {
    final response = await dio.post(
      ApiConfig.verifyOTP,
      data: {'phone': phone, 'otp': otp},
    );
    return response.statusCode == 200;
  }
}

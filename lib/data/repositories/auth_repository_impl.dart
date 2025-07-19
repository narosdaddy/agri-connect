import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';
import '../sources/auth_service.dart';
import '../models/auth_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService service;
  User? _currentUser;
  AuthRepositoryImpl(this.service);

  @override
  Future<User> login(String email, String password) async {
    final response = await service.login(
      LoginRequest(email: email, motDePasse: password),
    );
    final user = UserModel.fromJson(response.toJson());
    _currentUser = user;
    return user;
  }

  @override
  Future<User> register(String email, String password) async {
    // Pour RegisterRequest il faut aussi le nom et le téléphone, à adapter selon l'appelant
    final response = await service.register(
      RegisterRequest(
        nom: '', // À compléter selon le contexte d'appel
        email: email,
        telephone: '', // À compléter selon le contexte d'appel
        motDePasse: password,
      ),
    );
    final user = UserModel.fromJson(response.toJson());
    _currentUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    // Optionnel: appeler un endpoint logout si disponible
  }

  @override
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }
}

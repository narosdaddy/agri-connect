import '../repositories/auth_repository.dart';
import '../entities/user.dart';

class Login {
  final AuthRepository repository;
  const Login(this.repository);

  Future<User> call(String email, String password) {
    return repository.login(email, password);
  }
}

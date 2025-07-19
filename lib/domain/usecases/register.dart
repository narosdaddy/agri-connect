import '../repositories/auth_repository.dart';
import '../entities/user.dart';

class Register {
  final AuthRepository repository;
  const Register(this.repository);

  Future<User> call(String email, String password) {
    return repository.register(email, password);
  }
}

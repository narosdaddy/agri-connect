import '../repositories/auth_repository.dart';
import '../entities/user.dart';

class GetCurrentUser {
  final AuthRepository repository;
  const GetCurrentUser(this.repository);

  Future<User?> call() {
    return repository.getCurrentUser();
  }
}

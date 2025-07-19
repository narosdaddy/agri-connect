import '../repositories/profile_repository.dart';
import '../entities/profile.dart';

class GetProfile {
  final ProfileRepository repository;
  const GetProfile(this.repository);

  Future<Profile> call() {
    return repository.getProfile();
  }
}

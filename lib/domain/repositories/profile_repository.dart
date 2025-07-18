import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile> getProfile();
  Future<void> demandeEvolutionProducteur(Map<String, dynamic> request);
}

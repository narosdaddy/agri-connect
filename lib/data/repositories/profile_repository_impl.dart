import '../../domain/repositories/profile_repository.dart';
import '../../domain/entities/profile.dart';
import '../models/profile_model.dart';
import '../models/user_model.dart';
import '../sources/profile_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService service;
  ProfileRepositoryImpl(this.service);

  @override
  Future<Profile> getProfile() async {
    final model = await service.getProfile();
    return model as Profile;
  }

  @override
  Future<void> demandeEvolutionProducteur(Map<String, dynamic> request) async {
    await service.demandeEvolutionProducteur(request);
  }
}

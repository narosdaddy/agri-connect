import '../../domain/repositories/partenaire_logistique_repository.dart';
import '../../domain/entities/partenaire_logistique.dart';
import '../models/partenaire_logistique_model.dart';
import '../sources/partenaire_logistique_service.dart';

class PartenaireLogistiqueRepositoryImpl
    implements PartenaireLogistiqueRepository {
  final PartenaireLogistiqueService service;
  PartenaireLogistiqueRepositoryImpl(this.service);

  @override
  Future<PartenaireLogistique> createPartenaire(
    PartenaireLogistique partenaire,
  ) async {
    final model = await service.createPartenaire(partenaire.toJson());
    return model;
  }

  @override
  Future<PartenaireLogistique?> getPartenaireById(String id) async {
    return await service.getPartenaireById(id);
  }

  @override
  Future<List<PartenaireLogistique>> getAllPartenaires() async {
    return await service.getAllPartenaires();
  }

  @override
  Future<void> activatePartenaire(String id) async {
    await service.activatePartenaire(id);
  }

  @override
  Future<void> deactivatePartenaire(String id) async {
    await service.deactivatePartenaire(id);
  }

  @override
  Future<void> deletePartenaire(String id) async {
    await service.deletePartenaire(id);
  }
}

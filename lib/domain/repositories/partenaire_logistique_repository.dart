import '../entities/partenaire_logistique.dart';

abstract class PartenaireLogistiqueRepository {
  Future<PartenaireLogistique> createPartenaire(
    PartenaireLogistique partenaire,
  );
  Future<PartenaireLogistique?> getPartenaireById(String id);
  Future<List<PartenaireLogistique>> getAllPartenaires();
  Future<void> activatePartenaire(String id);
  Future<void> deactivatePartenaire(String id);
  Future<void> deletePartenaire(String id);
}

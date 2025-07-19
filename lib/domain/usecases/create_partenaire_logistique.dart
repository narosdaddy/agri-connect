import '../repositories/partenaire_logistique_repository.dart';
import '../entities/partenaire_logistique.dart';

class CreatePartenaireLogistique {
  final PartenaireLogistiqueRepository repository;
  const CreatePartenaireLogistique(this.repository);

  Future<PartenaireLogistique> call(PartenaireLogistique partenaire) {
    return repository.createPartenaire(partenaire);
  }
}

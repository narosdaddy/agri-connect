import '../repositories/livraison_repository.dart';
import '../entities/livraison.dart';

class CreateLivraison {
  final LivraisonRepository repository;
  const CreateLivraison(this.repository);

  Future<Livraison> call(Livraison livraison) {
    return repository.createLivraison(livraison);
  }
}

import '../../domain/repositories/livraison_repository.dart';
import '../../domain/entities/livraison.dart';
import '../models/livraison_model.dart';
import '../sources/livraison_service.dart';

class LivraisonRepositoryImpl implements LivraisonRepository {
  final LivraisonService service;
  LivraisonRepositoryImpl(this.service);

  @override
  Future<Livraison> createLivraison(Livraison livraison) async {
    final model = await service.createLivraison(livraison.toJson());
    return model;
  }

  @override
  Future<Livraison?> getLivraisonById(String id) async {
    return await service.getLivraisonById(id);
  }

  @override
  Future<List<Livraison>> getLivraisonsByCommande(String commandeId) async {
    return await service.getLivraisonsByCommande(commandeId);
  }

  @override
  Future<List<Livraison>> getLivraisonsByPartenaire(String partenaireId) async {
    return await service.getLivraisonsByPartenaire(partenaireId);
  }

  @override
  Future<Livraison> updateLivraisonStatus(String id, String statut) async {
    return await service.updateLivraisonStatus(id, statut);
  }

  @override
  Future<void> deleteLivraison(String id) async {
    await service.deleteLivraison(id);
  }
}

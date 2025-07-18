import '../entities/livraison.dart';

abstract class LivraisonRepository {
  Future<Livraison> createLivraison(Livraison livraison);
  Future<Livraison?> getLivraisonById(String id);
  Future<List<Livraison>> getLivraisonsByCommande(String commandeId);
  Future<List<Livraison>> getLivraisonsByPartenaire(String partenaireId);
  Future<Livraison> updateLivraisonStatus(String id, String statut);
  Future<void> deleteLivraison(String id);
}

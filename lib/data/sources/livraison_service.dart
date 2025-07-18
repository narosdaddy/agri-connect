import 'package:dio/dio.dart';
import '../models/livraison_model.dart';

class LivraisonService {
  final Dio dio;
  LivraisonService(this.dio);

  Future<LivraisonModel> createLivraison(Map<String, dynamic> data) async {
    final response = await dio.post('/livraisons', data: data);
    return LivraisonModel.fromJson(response.data);
  }

  Future<LivraisonModel?> getLivraisonById(String id) async {
    final response = await dio.get('/livraisons/$id');
    if (response.data == null) return null;
    return LivraisonModel.fromJson(response.data);
  }

  Future<List<LivraisonModel>> getLivraisonsByCommande(
    String commandeId,
  ) async {
    final response = await dio.get('/livraisons/commande/$commandeId');
    return (response.data as List)
        .map((json) => LivraisonModel.fromJson(json))
        .toList();
  }

  Future<List<LivraisonModel>> getLivraisonsByPartenaire(
    String partenaireId,
  ) async {
    final response = await dio.get('/livraisons/partenaire/$partenaireId');
    return (response.data as List)
        .map((json) => LivraisonModel.fromJson(json))
        .toList();
  }

  Future<LivraisonModel> updateLivraisonStatus(String id, String statut) async {
    final response = await dio.patch(
      '/livraisons/$id',
      data: {'statut': statut},
    );
    return LivraisonModel.fromJson(response.data);
  }

  Future<void> deleteLivraison(String id) async {
    await dio.delete('/livraisons/$id');
  }
}

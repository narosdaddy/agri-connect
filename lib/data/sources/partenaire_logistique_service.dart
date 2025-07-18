import 'package:dio/dio.dart';
import '../models/partenaire_logistique_model.dart';

class PartenaireLogistiqueService {
  final Dio dio;
  PartenaireLogistiqueService(this.dio);

  Future<PartenaireLogistiqueModel> createPartenaire(
    Map<String, dynamic> data,
  ) async {
    final response = await dio.post('/partenaires-logistiques', data: data);
    return PartenaireLogistiqueModel.fromJson(response.data);
  }

  Future<PartenaireLogistiqueModel?> getPartenaireById(String id) async {
    final response = await dio.get('/partenaires-logistiques/$id');
    if (response.data == null) return null;
    return PartenaireLogistiqueModel.fromJson(response.data);
  }

  Future<List<PartenaireLogistiqueModel>> getAllPartenaires() async {
    final response = await dio.get('/partenaires-logistiques');
    return (response.data as List)
        .map((json) => PartenaireLogistiqueModel.fromJson(json))
        .toList();
  }

  Future<void> activatePartenaire(String id) async {
    await dio.post('/partenaires-logistiques/$id/activate');
  }

  Future<void> deactivatePartenaire(String id) async {
    await dio.post('/partenaires-logistiques/$id/deactivate');
  }

  Future<void> deletePartenaire(String id) async {
    await dio.delete('/partenaires-logistiques/$id');
  }
}

import '../../domain/entities/partenaire_logistique.dart';

class PartenaireLogistiqueModel extends PartenaireLogistique {
  const PartenaireLogistiqueModel({required String id, required String nom})
    : super(id: id, nom: nom);

  factory PartenaireLogistiqueModel.fromJson(Map<String, dynamic> json) =>
      PartenaireLogistiqueModel(
        id: json['id'] as String,
        nom: json['nom'] as String,
      );

  @override
  Map<String, dynamic> toJson() => {'id': id, 'nom': nom};
}

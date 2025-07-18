import '../../domain/entities/livraison.dart';

class LivraisonModel extends Livraison {
  const LivraisonModel({
    required String id,
    String? commandeId,
    String? partenaireId,
    String? statut,
  }) : super(
         id: id,
         commandeId: commandeId,
         partenaireId: partenaireId,
         statut: statut,
       );

  factory LivraisonModel.fromJson(Map<String, dynamic> json) => LivraisonModel(
    id: json['id'] as String,
    commandeId: json['commandeId'] as String?,
    partenaireId: json['partenaireId'] as String?,
    statut: json['statut'] as String?,
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'commandeId': commandeId,
    'partenaireId': partenaireId,
    'statut': statut,
  };
}

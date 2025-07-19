class Livraison {
  final String id;
  final String? commandeId;
  final String? partenaireId;
  final String? statut;

  const Livraison({
    required this.id,
    this.commandeId,
    this.partenaireId,
    this.statut,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'commandeId': commandeId,
    'partenaireId': partenaireId,
    'statut': statut,
  };
}

class PartenaireLogistique {
  final String id;
  final String nom;

  const PartenaireLogistique({required this.id, required this.nom});

  Map<String, dynamic> toJson() => {'id': id, 'nom': nom};
}

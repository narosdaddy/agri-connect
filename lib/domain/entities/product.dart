class Product {
  final String id;
  final String nom;
  final String? description;
  final double? prix;
  final String? categorieId;
  final int? quantite;
  final String? producteurId;
  final String? imageUrl;
  final bool? bio;
  final String? origine;
  final String? dateCreation;

  const Product({
    required this.id,
    required this.nom,
    this.description,
    this.prix,
    this.categorieId,
    this.quantite,
    this.producteurId,
    this.imageUrl,
    this.bio,
    this.origine,
    this.dateCreation,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'description': description,
    'prix': prix,
    'categorieId': categorieId,
    'quantite': quantite,
    'producteurId': producteurId,
    'imageUrl': imageUrl,
    'bio': bio,
    'origine': origine,
    'dateCreation': dateCreation,
  };
}

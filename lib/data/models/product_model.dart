import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required String id,
    required String nom,
    String? description,
    double? prix,
    String? categorieId,
    int? quantite,
    String? producteurId,
    String? imageUrl,
    bool? bio,
    String? origine,
    String? dateCreation,
  }) : super(
         id: id,
         nom: nom,
         description: description,
         prix: prix,
         categorieId: categorieId,
         quantite: quantite,
         producteurId: producteurId,
         imageUrl: imageUrl,
         bio: bio,
         origine: origine,
         dateCreation: dateCreation,
       );

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'] as String,
    nom: json['nom'] as String,
    description: json['description'] as String?,
    prix:
        (json['prix'] is int)
            ? (json['prix'] as int).toDouble()
            : json['prix'] as double?,
    categorieId: json['categorieId'] as String?,
    quantite: json['quantite'] as int?,
    producteurId: json['producteurId'] as String?,
    imageUrl: json['imageUrl'] as String?,
    bio: json['bio'] as bool?,
    origine: json['origine'] as String?,
    dateCreation: json['dateCreation'] as String?,
  );

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

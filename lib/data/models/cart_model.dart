import '../../domain/entities/cart.dart';

class CartModel extends Cart {
  const CartModel({
    required String id,
    required String acheteurId,
    required List<CartElement> elements,
  }) : super(id: id, acheteurId: acheteurId, elements: elements);

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
    id: json['id'] as String,
    acheteurId: json['acheteurId'] as String,
    elements:
        (json['elements'] as List<dynamic>)
            .map(
              (e) => CartElement(
                produitId: e['produitId'] as String,
                quantite: e['quantite'] as int,
              ),
            )
            .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'acheteurId': acheteurId,
    'elements':
        elements
            .map((e) => {'produitId': e.produitId, 'quantite': e.quantite})
            .toList(),
  };
}

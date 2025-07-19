class Order {
  final String id;
  final String? statut;
  final String? acheteurId;
  final String? producteurId;
  final List<OrderElement>? elements;
  final double? total;
  final String? dateCreation;

  const Order({
    required this.id,
    this.statut,
    this.acheteurId,
    this.producteurId,
    this.elements,
    this.total,
    this.dateCreation,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'statut': statut,
    'acheteurId': acheteurId,
    'producteurId': producteurId,
    'elements': elements?.map((e) => e.toJson()).toList(),
    'total': total,
    'dateCreation': dateCreation,
  };
}

class OrderElement {
  final String produitId;
  final int quantite;

  const OrderElement({required this.produitId, required this.quantite});

  Map<String, dynamic> toJson() => {
    'produitId': produitId,
    'quantite': quantite,
  };
}

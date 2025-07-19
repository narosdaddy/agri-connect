import '../../domain/entities/order.dart';

class OrderModel extends Order {
  const OrderModel({
    required String id,
    String? statut,
    String? acheteurId,
    String? producteurId,
    List<OrderElement>? elements,
    double? total,
    String? dateCreation,
  }) : super(
         id: id,
         statut: statut,
         acheteurId: acheteurId,
         producteurId: producteurId,
         elements: elements,
         total: total,
         dateCreation: dateCreation,
       );

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'] as String,
    statut: json['statut'] as String?,
    acheteurId: json['acheteurId'] as String?,
    producteurId: json['producteurId'] as String?,
    elements:
        (json['elements'] as List<dynamic>?)
            ?.map(
              (e) => OrderElement(
                produitId: e['produitId'] as String,
                quantite: e['quantite'] as int,
              ),
            )
            .toList(),
    total:
        (json['total'] is int)
            ? (json['total'] as int).toDouble()
            : json['total'] as double?,
    dateCreation: json['dateCreation'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'statut': statut,
    'acheteurId': acheteurId,
    'producteurId': producteurId,
    'elements':
        elements
            ?.map((e) => {'produitId': e.produitId, 'quantite': e.quantite})
            .toList(),
    'total': total,
    'dateCreation': dateCreation,
  };
}

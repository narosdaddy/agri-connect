import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required String id,
    String? commandeId,
    double? montant,
    String? statut,
    String? methode,
  }) : super(
         id: id,
         commandeId: commandeId,
         montant: montant,
         statut: statut,
         methode: methode,
       );

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
    id: json['id'] as String,
    commandeId: json['commandeId'] as String?,
    montant:
        (json['montant'] is int)
            ? (json['montant'] as int).toDouble()
            : json['montant'] as double?,
    statut: json['statut'] as String?,
    methode: json['methode'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'commandeId': commandeId,
    'montant': montant,
    'statut': statut,
    'methode': methode,
  };
}

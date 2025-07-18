class Payment {
  final String id;
  final String? commandeId;
  final double? montant;
  final String? statut;
  final String? methode;

  const Payment({
    required this.id,
    this.commandeId,
    this.montant,
    this.statut,
    this.methode,
  });
}

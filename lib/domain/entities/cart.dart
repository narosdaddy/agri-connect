class Cart {
  final String id;
  final String acheteurId;
  final List<CartElement> elements;

  const Cart({
    required this.id,
    required this.acheteurId,
    required this.elements,
  });
}

class CartElement {
  final String produitId;
  final int quantite;

  const CartElement({required this.produitId, required this.quantite});
}

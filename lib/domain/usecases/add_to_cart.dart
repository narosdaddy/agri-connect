import '../repositories/cart_repository.dart';
import '../entities/cart.dart';

class AddToCart {
  final CartRepository repository;
  const AddToCart(this.repository);

  Future<Cart> call(String acheteurId, String produitId, int quantite) {
    return repository.addToCart(acheteurId, produitId, quantite);
  }
}

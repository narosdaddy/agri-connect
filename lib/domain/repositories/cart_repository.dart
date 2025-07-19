import '../entities/cart.dart';

abstract class CartRepository {
  Future<Cart> addToCart(String acheteurId, String produitId, int quantite);
  Future<Cart?> getCart(String acheteurId);
  Future<void> removeFromCart(String acheteurId, String produitId);
  Future<void> clearCart(String acheteurId);
}

import '../../domain/repositories/cart_repository.dart';
import '../../domain/entities/cart.dart';
import '../models/cart_model.dart';
import '../sources/cart_service.dart';

class CartRepositoryImpl implements CartRepository {
  final CartService service;
  CartRepositoryImpl(this.service);

  @override
  Future<Cart> addToCart(
    String acheteurId,
    String produitId,
    int quantite,
  ) async {
    final model = await service.addToCart(produitId, quantite);
    return model;
  }

  @override
  Future<Cart?> getCart(String acheteurId) async {
    final model = await service.getCart();
    return model;
  }

  @override
  Future<void> removeFromCart(String acheteurId, String produitId) async {
    await service.removeFromCart(produitId);
  }

  @override
  Future<void> clearCart(String acheteurId) async {
    await service.clearCart();
  }
}

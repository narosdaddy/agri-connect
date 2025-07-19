import '../repositories/cart_repository.dart';
import '../entities/cart.dart';

class GetCart {
  final CartRepository repository;
  const GetCart(this.repository);

  Future<Cart?> call(String acheteurId) {
    return repository.getCart(acheteurId);
  }
}

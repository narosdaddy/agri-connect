import '../repositories/product_repository.dart';

class DeleteProduct {
  final ProductRepository repository;
  const DeleteProduct(this.repository);

  Future<void> call(String productId, String producteurId) {
    return repository.deleteProduct(productId, producteurId);
  }
}

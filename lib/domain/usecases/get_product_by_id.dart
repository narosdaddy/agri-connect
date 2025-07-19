import '../repositories/product_repository.dart';
import '../entities/product.dart';

class GetProductById {
  final ProductRepository repository;
  const GetProductById(this.repository);

  Future<Product?> call(String productId) {
    return repository.getProductById(productId);
  }
}

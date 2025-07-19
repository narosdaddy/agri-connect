import '../repositories/product_repository.dart';
import '../entities/product.dart';

class GetAllProducts {
  final ProductRepository repository;
  const GetAllProducts(this.repository);

  Future<List<Product>> call({
    int page = 0,
    int size = 20,
    String? sortBy,
    String? sortDir,
  }) {
    return repository.getAllProducts(
      page: page,
      size: size,
      sortBy: sortBy,
      sortDir: sortDir,
    );
  }
}

import '../entities/product.dart';

abstract class ProductRepository {
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String productId, String producteurId);
  Future<Product?> getProductById(String productId);
  Future<List<Product>> getAllProducts({
    int page,
    int size,
    String? sortBy,
    String? sortDir,
  });
  Future<List<Product>> searchProducts({
    String? categorie,
    bool? bio,
    double? prixMin,
    double? prixMax,
    String? nom,
    String? origine,
    int? page,
    int? size,
  });
  Future<List<Product>> getProductsByProducer(
    String producteurId, {
    int? page,
    int? size,
  });
  Future<List<Product>> getPopularProducts({int? page, int? size});
  Future<List<Product>> getRecentProducts({int? page, int? size});
  Future<List<Product>> getOutOfStockProducts();
  Future<void> uploadProductImage(
    String productId,
    String producteurId,
    String filePath,
  );
  Future<void> deleteProductImage(
    String productId,
    String imageUrl,
    String producteurId,
  );
  Future<void> updateProductStock(
    String productId,
    int nouvelleQuantite,
    String producteurId,
  );
  Future<bool> checkProductAvailability(String productId, int quantiteDemandee);
}

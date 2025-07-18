import '../../domain/repositories/product_repository.dart';
import '../../domain/entities/product.dart';
import '../models/product_model.dart';
import '../sources/product_service.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductService service;
  ProductRepositoryImpl(this.service);

  @override
  Future<Product> createProduct(Product product) async {
    final model = await service.addProduct(
      ProductModel(
        id: product.id,
        nom: product.nom,
        description: product.description,
        prix: product.prix,
        categorieId: product.categorieId,
        quantite: product.quantite,
        producteurId: product.producteurId,
        imageUrl: product.imageUrl,
        bio: product.bio,
        origine: product.origine,
        dateCreation: product.dateCreation,
      ),
    );
    return model;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final model = await service.updateProduct(
      product.id,
      ProductModel(
        id: product.id,
        nom: product.nom,
        description: product.description,
        prix: product.prix,
        categorieId: product.categorieId,
        quantite: product.quantite,
        producteurId: product.producteurId,
        imageUrl: product.imageUrl,
        bio: product.bio,
        origine: product.origine,
        dateCreation: product.dateCreation,
      ),
    );
    return model;
  }

  @override
  Future<void> deleteProduct(String productId, String producteurId) async {
    await service.deleteProduct(productId);
  }

  @override
  Future<Product?> getProductById(String productId) async {
    return await service.getProductById(productId);
  }

  @override
  Future<List<Product>> getAllProducts({
    int page = 0,
    int size = 20,
    String? sortBy,
    String? sortDir,
  }) async {
    await service.fetchProducts();
    return service.getProducts();
  }

  @override
  Future<List<Product>> searchProducts({
    String? categorie,
    bool? bio,
    double? prixMin,
    double? prixMax,
    String? nom,
    String? origine,
    int? page,
    int? size,
  }) async {
    // À adapter selon l'API (exemple basique)
    await service.fetchProducts();
    return service.getProducts().where((p) {
      final matchesCategorie = categorie == null || p.categorieId == categorie;
      final matchesBio = bio == null || p.bio == bio;
      final matchesPrixMin = prixMin == null || (p.prix ?? 0) >= prixMin;
      final matchesPrixMax = prixMax == null || (p.prix ?? 0) <= prixMax;
      final matchesNom =
          nom == null || p.nom.toLowerCase().contains(nom.toLowerCase());
      final matchesOrigine =
          origine == null ||
          (p.origine ?? '').toLowerCase().contains(origine.toLowerCase());
      return matchesCategorie &&
          matchesBio &&
          matchesPrixMin &&
          matchesPrixMax &&
          matchesNom &&
          matchesOrigine;
    }).toList();
  }

  @override
  Future<List<Product>> getProductsByProducer(
    String producteurId, {
    int? page,
    int? size,
  }) async {
    await service.fetchProducts();
    return service
        .getProducts()
        .where((p) => p.producteurId == producteurId)
        .toList();
  }

  @override
  Future<List<Product>> getPopularProducts({int? page, int? size}) async {
    await service.fetchProducts();
    // À adapter selon l'API, ici on retourne les produits triés par quantité vendue (exemple fictif)
    return service.getProducts();
  }

  @override
  Future<List<Product>> getRecentProducts({int? page, int? size}) async {
    await service.fetchProducts();
    // À adapter selon l'API, ici on retourne les produits triés par dateCreation (exemple fictif)
    return service.getProducts();
  }

  @override
  Future<List<Product>> getOutOfStockProducts() async {
    await service.fetchProducts();
    return service.getProducts().where((p) => (p.quantite ?? 0) == 0).toList();
  }

  @override
  Future<void> uploadProductImage(
    String productId,
    String producteurId,
    String filePath,
  ) async {
    // À implémenter selon l'API
    throw UnimplementedError();
  }

  @override
  Future<void> deleteProductImage(
    String productId,
    String imageUrl,
    String producteurId,
  ) async {
    // À implémenter selon l'API
    throw UnimplementedError();
  }

  @override
  Future<void> updateProductStock(
    String productId,
    int nouvelleQuantite,
    String producteurId,
  ) async {
    // À implémenter selon l'API
    throw UnimplementedError();
  }

  @override
  Future<bool> checkProductAvailability(
    String productId,
    int quantiteDemandee,
  ) async {
    // À implémenter selon l'API
    throw UnimplementedError();
  }
}

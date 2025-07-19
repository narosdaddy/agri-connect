import '../repositories/product_repository.dart';
import '../entities/product.dart';

class SearchProducts {
  final ProductRepository repository;
  const SearchProducts(this.repository);

  Future<List<Product>> call({
    String? categorie,
    bool? bio,
    double? prixMin,
    double? prixMax,
    String? nom,
    String? origine,
    int? page,
    int? size,
  }) {
    return repository.searchProducts(
      categorie: categorie,
      bio: bio,
      prixMin: prixMin,
      prixMax: prixMax,
      nom: nom,
      origine: origine,
      page: page,
      size: size,
    );
  }
}

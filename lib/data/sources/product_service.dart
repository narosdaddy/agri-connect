import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../models/product_model.dart';

class ProductService {
  final Dio dio;
  ProductService(this.dio);

  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  Future<void> fetchProducts() async {
    final response = await dio.get(ApiConfig.products);
    _products =
        (response.data as List)
            .map((json) => ProductModel.fromJson(json))
            .toList();
  }

  Future<ProductModel> getProductById(String id) async {
    final response = await dio.get(ApiConfig.productById.replaceFirst('{id}', id));
    return ProductModel.fromJson(response.data);
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final response = await dio.get(
      ApiConfig.searchProducts,
      queryParameters: {'q': query},
    );
    return (response.data as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  Future<ProductModel> addProduct(ProductModel product) async {
    final response = await dio.post(
      ApiConfig.products,
      data: product.toJson(),
      queryParameters: {'producteurId': product.producteurId},
    );
    final newProduct = ProductModel.fromJson(response.data);
    _products.add(newProduct);
    return newProduct;
  }

  Future<ProductModel> updateProduct(String id, ProductModel product) async {
    final response = await dio.put(ApiConfig.productById.replaceFirst('{id}', id), data: product.toJson());
    final updated = ProductModel.fromJson(response.data);
    _products = _products.map((p) => p.id == id ? updated : p).toList();
    return updated;
  }

  Future<void> deleteProduct(String id) async {
    await dio.delete(ApiConfig.productById.replaceFirst('{id}', id));
    _products.removeWhere((p) => p.id == id);
  }

  List<ProductModel> getProducts() {
    return _products;
  }
}

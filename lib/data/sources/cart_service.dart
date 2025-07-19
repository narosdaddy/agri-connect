import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../models/cart_model.dart';
import '../../domain/entities/cart.dart';

class CartService {
  final Dio dio;
  CartService(this.dio);

  CartModel? _cart;
  CartModel? get cart => _cart;
  List<CartElement> get cartItems => _cart?.elements ?? [];

  Future<void> fetchCart() async {
    final response = await dio.get(ApiConfig.cart);
    _cart = CartModel.fromJson(response.data);
  }

  Future<CartModel> addToCart(String produitId, int quantite) async {
    final response = await dio.post(
      ApiConfig.cartItems,
      data: {'produitId': produitId, 'quantite': quantite},
    );
    _cart = CartModel.fromJson(response.data);
    return _cart!;
  }

  Future<CartModel> removeFromCart(String produitId) async {
    final response = await dio.delete(ApiConfig.cartItemById.replaceFirst('{id}', produitId));
    _cart = CartModel.fromJson(response.data);
    return _cart!;
  }

  Future<void> clearCart() async {
    await dio.delete(ApiConfig.cart);
    _cart = null;
  }

  Future<void> updateQuantity(String produitId, int quantite) async {
    final response = await dio.put(
      ApiConfig.cartItemById.replaceFirst('{id}', produitId),
      data: {'quantite': quantite},
    );
    _cart = CartModel.fromJson(response.data);
  }

  CartModel? getCart() {
    return _cart;
  }

  double get subtotal => cartItems.fold(
    0,
    (sum, e) => sum + (e.quantite * 0),
  ); // À adapter selon modèle produit
  double get shipping => 0; // À adapter selon logique métier
  double get total => subtotal + shipping;
}

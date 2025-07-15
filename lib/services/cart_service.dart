import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';
import '../config/api_config.dart';

class CartService extends ChangeNotifier {
  static const String baseUrl = 'http://10.0.2.2:8080'; // Émulateur Android
  
  List<Map<String, dynamic>> _cartItems = [];
  String? _promoCode;
  double _promoDiscount = 0.0;
  bool _promoApplied = false;
  bool _isLoading = false;

  List<Map<String, dynamic>> get cartItems => _cartItems;
  String? get promoCode => _promoCode;
  double get promoDiscount => _promoDiscount;
  bool get promoApplied => _promoApplied;
  bool get isLoading => _isLoading;

  int get itemCount => _cartItems.length;

  double get subtotal {
    return _cartItems.fold(0.0, (sum, item) => 
      sum + (double.parse(item['prixUnitaire'].toString()) * (item['quantite'] ?? 1)));
  }

  double get shipping => _cartItems.isEmpty ? 0.0 : 5.0; // Frais de livraison fixes

  double get discount {
    return _promoApplied ? subtotal * _promoDiscount : 0.0;
  }

  double get total => subtotal + shipping - discount;

  // Charger le panier depuis l'API
  Future<void> loadCart() async {
    setLoading(true);
    
    try {
      final authService = AuthService();
      final headers = <String, String>{
        ...ApiConfig.defaultHeaders,
        if (authService.accessToken != null) 'Authorization': 'Bearer ${authService.accessToken!}',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/panier'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _cartItems = List<Map<String, dynamic>>.from(data['elements'] ?? []);
        _promoCode = data['codePromo'];
        _promoDiscount = _promoCode != null ? 0.1 : 0.0; // 10% de remise par défaut
        _promoApplied = _promoCode != null;
        notifyListeners();
      } else if (response.statusCode == 404) {
        // Panier vide
        _cartItems = [];
        _promoCode = null;
        _promoDiscount = 0.0;
        _promoApplied = false;
        notifyListeners();
      } else {
        print('Erreur lors du chargement du panier: ${response.statusCode}');
        print('Réponse: ${response.body}');
      }
    } catch (e) {
      print('Erreur lors du chargement du panier: $e');
    } finally {
      setLoading(false);
    }
  }

  // Ajouter un produit au panier
  Future<bool> addToCart(String productId, int quantity) async {
    setLoading(true);
    
    try {
      final authService = AuthService();
      final headers = <String, String>{
        ...ApiConfig.defaultHeaders,
        if (authService.accessToken != null) 'Authorization': 'Bearer ${authService.accessToken!}',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/panier/elements'),
        headers: headers,
        body: jsonEncode({
          'produitId': productId,
          'quantite': quantity,
        }),
      );

      if (response.statusCode == 201) {
        // Recharger le panier
        await loadCart();
        return true;
      } else {
        print('Erreur lors de l\'ajout au panier: ${response.statusCode}');
        print('Réponse: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erreur lors de l\'ajout au panier: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Modifier la quantité d'un produit
  Future<bool> updateQuantity(String cartItemId, int quantity) async {
    setLoading(true);
    
    try {
      final authService = AuthService();
      final headers = <String, String>{
        ...ApiConfig.defaultHeaders,
        if (authService.accessToken != null) 'Authorization': 'Bearer ${authService.accessToken!}',
      };

      final response = await http.put(
        Uri.parse('$baseUrl/api/v1/panier/elements/$cartItemId'),
        headers: headers,
        body: jsonEncode({
          'quantite': quantity,
        }),
      );

      if (response.statusCode == 200) {
        // Recharger le panier
        await loadCart();
        return true;
      } else {
        print('Erreur lors de la modification de la quantité: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Erreur lors de la modification de la quantité: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Retirer un produit du panier
  Future<bool> removeFromCart(String cartItemId) async {
    setLoading(true);
    
    try {
      final authService = AuthService();
      final headers = <String, String>{
        ...ApiConfig.defaultHeaders,
        if (authService.accessToken != null) 'Authorization': 'Bearer ${authService.accessToken!}',
      };

      final response = await http.delete(
        Uri.parse('$baseUrl/api/v1/panier/elements/$cartItemId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Recharger le panier
        await loadCart();
        return true;
      } else {
        print('Erreur lors de la suppression du panier: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Erreur lors de la suppression du panier: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Vider le panier
  Future<bool> clearCart() async {
    setLoading(true);
    
    try {
      final authService = AuthService();
      final headers = <String, String>{
        ...ApiConfig.defaultHeaders,
        if (authService.accessToken != null) 'Authorization': 'Bearer ${authService.accessToken!}',
      };

      final response = await http.delete(
        Uri.parse('$baseUrl/api/v1/panier/vider'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        _cartItems.clear();
        _promoCode = null;
        _promoDiscount = 0.0;
        _promoApplied = false;
        notifyListeners();
        return true;
      } else {
        print('Erreur lors du vidage du panier: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Erreur lors du vidage du panier: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Appliquer un code promo
  Future<bool> applyPromoCode(String code) async {
    setLoading(true);
    
    try {
      final authService = AuthService();
      final headers = <String, String>{
        ...ApiConfig.defaultHeaders,
        if (authService.accessToken != null) 'Authorization': 'Bearer ${authService.accessToken!}',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/panier/promo/$code'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _promoCode = code;
        _promoDiscount = data['remise'] ?? 0.0;
        _promoApplied = true;
        notifyListeners();
        return true;
      } else {
        print('Erreur lors de l\'application du code promo: ${response.statusCode}');
        print('Réponse: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erreur lors de l\'application du code promo: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Supprimer le code promo
  void removePromoCode() {
    _promoCode = null;
    _promoDiscount = 0.0;
    _promoApplied = false;
    notifyListeners();
  }

  // Vérifier si un produit est dans le panier
  bool isInCart(String productId) {
    return _cartItems.any((item) => item['produit']['id'] == productId);
  }

  // Obtenir la quantité d'un produit dans le panier
  int getItemQuantity(String productId) {
    final item = _cartItems.firstWhere(
      (item) => item['produit']['id'] == productId,
      orElse: () => <String, dynamic>{},
    );
    return item['quantite'] ?? 0;
  }

  // Obtenir l'ID de l'élément du panier pour un produit
  String? getCartItemId(String productId) {
    final item = _cartItems.firstWhere(
      (item) => item['produit']['id'] == productId,
      orElse: () => <String, dynamic>{},
    );
    return item['id'];
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
} 
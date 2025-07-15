import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';
import '../config/api_config.dart';

class OrderService extends ChangeNotifier {
  static const String baseUrl = 'http://10.0.2.2:8080'; // Émulateur Android
  
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _hasMoreData = true;

  List<Map<String, dynamic>> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get hasMoreData => _hasMoreData;

  // Charger les commandes depuis l'API
  Future<void> loadOrders({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _orders.clear();
      _hasMoreData = true;
    }

    if (!_hasMoreData || _isLoading) return;

    setLoading(true);

    try {
      final authService = AuthService();
      final headers = <String, String>{
        ...ApiConfig.defaultHeaders,
        if (authService.accessToken != null) 'Authorization': 'Bearer ${authService.accessToken!}',
      };

      final queryParams = <String, String>{
        'page': _currentPage.toString(),
        'size': '20',
      };

      final uri = Uri.parse('$baseUrl/api/v1/commandes/historique').replace(queryParameters: queryParams);
      
      print('Chargement des commandes: $uri');

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        final newOrders = List<Map<String, dynamic>>.from(data['content'] ?? []);
        
        if (refresh) {
          _orders = newOrders;
        } else {
          _orders.addAll(newOrders);
        }

        _totalPages = data['totalPages'] ?? 0;
        _currentPage = data['number'] ?? 0;
        _hasMoreData = _currentPage < _totalPages - 1;

        notifyListeners();
      } else {
        print('Erreur lors du chargement des commandes: ${response.statusCode}');
        print('Réponse: ${response.body}');
      }
    } catch (e) {
      print('Erreur lors du chargement des commandes: $e');
    } finally {
      setLoading(false);
    }
  }

  // Charger plus de commandes (pagination)
  Future<void> loadMoreOrders() async {
    if (_hasMoreData && !_isLoading) {
      _currentPage++;
      await loadOrders();
    }
  }

  // Créer une nouvelle commande
  Future<Map<String, dynamic>?> createOrder({
    required String methodePaiement,
    required String adresseLivraison,
    required String villeLivraison,
    required String codePostalLivraison,
    required String paysLivraison,
    required String telephoneLivraison,
    String? instructionsLivraison,
    String? codePromo,
  }) async {
    setLoading(true);
    
    try {
      final authService = AuthService();
      final headers = {
        ...ApiConfig.defaultHeaders,
        if (authService.accessToken != null) 'Authorization': 'Bearer ${authService.accessToken!}',
      };

      final requestBody = {
        'methodePaiement': methodePaiement,
        'adresseLivraison': adresseLivraison,
        'villeLivraison': villeLivraison,
        'codePostalLivraison': codePostalLivraison,
        'paysLivraison': paysLivraison,
        'telephoneLivraison': telephoneLivraison,
        'instructionsLivraison': instructionsLivraison,
        'codePromo': codePromo,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/commandes'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        final order = jsonDecode(response.body);
        _orders.insert(0, order); // Ajouter au début de la liste
        notifyListeners();
        return order;
      } else {
        print('Erreur lors de la création de la commande: ${response.statusCode}');
        print('Réponse: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la création de la commande: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  // Obtenir une commande par ID
  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    try {
      final authService = AuthService();
      final headers = {
        ...ApiConfig.defaultHeaders,
        if (authService.accessToken != null) 'Authorization': 'Bearer ${authService.accessToken!}',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/commandes/$orderId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Erreur lors du chargement de la commande: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erreur lors du chargement de la commande: $e');
      return null;
    }
  }

  // Mettre à jour le statut d'une commande (PRODUCTEUR)
  Future<bool> updateOrderStatus(String orderId, String status) async {
    setLoading(true);
    
    try {
      final authService = AuthService();
      final headers = {
        ...ApiConfig.defaultHeaders,
        if (authService.accessToken != null) 'Authorization': 'Bearer ${authService.accessToken!}',
      };

      final response = await http.put(
        Uri.parse('$baseUrl/api/v1/commandes/$orderId/status'),
        headers: headers,
        body: jsonEncode({
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        // Mettre à jour la commande dans la liste locale
        final index = _orders.indexWhere((order) => order['id'] == orderId);
        if (index >= 0) {
          _orders[index]['status'] = status;
          if (status == 'LIVREE') {
            _orders[index]['dateLivraison'] = DateTime.now().toIso8601String();
          }
          notifyListeners();
        }
        return true;
      } else {
        print('Erreur lors de la mise à jour du statut: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Obtenir les commandes par statut
  List<Map<String, dynamic>> getOrdersByStatus(String status) {
    return _orders.where((order) => order['status'] == status).toList();
  }

  // Obtenir les commandes récentes
  List<Map<String, dynamic>> getRecentOrders({int limit = 5}) {
    final sortedOrders = List<Map<String, dynamic>>.from(_orders);
    sortedOrders.sort((a, b) => b['dateCommande'].toString().compareTo(a['dateCommande'].toString()));
    return sortedOrders.take(limit).toList();
  }

  // Calculer les statistiques des commandes
  Map<String, dynamic> getOrderStats() {
    if (_orders.isEmpty) {
      return {
        'totalOrders': 0,
        'totalSpent': 0.0,
        'averageOrderValue': 0.0,
        'pendingOrders': 0,
        'deliveredOrders': 0,
      };
    }

    final totalSpent = _orders.fold(0.0, (sum, order) => sum + (order['total'] ?? 0.0));
    final pendingOrders = _orders.where((order) => order['status'] == 'EN_COURS').length;
    final deliveredOrders = _orders.where((order) => order['status'] == 'LIVREE').length;

    return {
      'totalOrders': _orders.length,
      'totalSpent': totalSpent,
      'averageOrderValue': totalSpent / _orders.length,
      'pendingOrders': pendingOrders,
      'deliveredOrders': deliveredOrders,
    };
  }

  // Obtenir les analytics des commandes (PRODUCTEUR)
  Future<Map<String, dynamic>?> getOrderAnalytics() async {
    try {
      final authService = AuthService();
      final headers = {
        ...ApiConfig.defaultHeaders,
        if (authService.accessToken != null) 'Authorization': 'Bearer ${authService.accessToken!}',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/commandes/analytics'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Erreur lors du chargement des analytics: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erreur lors du chargement des analytics: $e');
      return null;
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Annuler une commande (si l'API le supporte)
  Future<bool> cancelOrder(String orderId) async {
    return await updateOrderStatus(orderId, 'ANNULEE');
  }
} 
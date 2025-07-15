import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';
import '../config/api_config.dart';

class ProductService extends ChangeNotifier {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  String _searchQuery = '';
  String _selectedCategory = 'Tous';
  bool _showOnlyBio = false;
  String _sortBy = 'name'; // 'name', 'price', 'rating', 'date'
  bool _isLoading = false;
  int _currentPage = 0;
  int _totalPages = 0;
  int _totalElements = 0;
  bool _hasMoreData = true;

  List<Map<String, dynamic>> get products => _products;
  List<Map<String, dynamic>> get filteredProducts => _filteredProducts;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get showOnlyBio => _showOnlyBio;
  String get sortBy => _sortBy;
  bool get isLoading => _isLoading;
  bool get hasMoreData => _hasMoreData;

  // Catégories disponibles
  List<String> get categories => ['Tous', ...ApiConfig.productCategories];

  // Initialiser avec des produits exemple (mode développement)
  Future<void> initializeProducts() async {
    if (_products.isEmpty) {
      _products = [
        {
          'id': '1',
          'nom': 'Pommes Bio Golden',
          'prix': '4.50',
          'image': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400',
          'producteur': {'nom': 'Ferme Martin'},
          'categorie': 'FRUITS',
          'description': 'Pommes bio fraîchement cueillies, parfaites pour vos desserts.',
          'unite': 'kg',
          'bio': true,
          'quantiteDisponible': 50,
          'noteMoyenne': 4.8,
          'nombreAvis': 24,
          'disponible': true,
          'origine': 'Lyon',
          'createdAt': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
        },
        {
          'id': '2',
          'nom': 'Tomates Cerises',
          'prix': '6.20',
          'image': 'https://images.unsplash.com/photo-1546470427-e26264be0b4d?w=400',
          'producteur': {'nom': 'Jardins de Provence'},
          'categorie': 'LEGUMES',
          'description': 'Tomates cerises sucrées et juteuses, idéales pour les salades.',
          'unite': 'kg',
          'bio': false,
          'quantiteDisponible': 30,
          'noteMoyenne': 4.6,
          'nombreAvis': 18,
          'disponible': true,
          'origine': 'Marseille',
          'createdAt': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
        },
        {
          'id': '3',
          'nom': 'Carottes Bio',
          'prix': '2.80',
          'image': 'https://images.unsplash.com/photo-1445282768818-728615cc910a?w=400',
          'producteur': {'nom': 'Bio Légumes'},
          'categorie': 'LEGUMES',
          'description': 'Carottes bio croquantes et savoureuses.',
          'unite': 'kg',
          'bio': true,
          'quantiteDisponible': 75,
          'noteMoyenne': 4.7,
          'nombreAvis': 32,
          'disponible': true,
          'origine': 'Nantes',
          'createdAt': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
        },
      ];

      _applyFilters();
      notifyListeners();
    }
  }

  // Charger les produits depuis l'API
  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _products.clear();
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

      // Construire les paramètres de requête
      final queryParams = <String, String>{
        'page': _currentPage.toString(),
        'size': '20',
      };

      if (_selectedCategory != 'Tous') {
        queryParams['categorie'] = _selectedCategory;
      }

      if (_searchQuery.isNotEmpty) {
        queryParams['recherche'] = _searchQuery;
      }

      if (_showOnlyBio) {
        queryParams['bio'] = 'true';
      }

      // Ajouter le tri
      switch (_sortBy) {
        case 'price_low':
          queryParams['tri'] = 'prix';
          queryParams['ordre'] = 'ASC';
          break;
        case 'price_high':
          queryParams['tri'] = 'prix';
          queryParams['ordre'] = 'DESC';
          break;
        case 'rating':
          queryParams['tri'] = 'note';
          queryParams['ordre'] = 'DESC';
          break;
        case 'date':
          queryParams['tri'] = 'date';
          queryParams['ordre'] = 'DESC';
          break;
        default:
          queryParams['tri'] = 'nom';
          queryParams['ordre'] = 'ASC';
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.produits}').replace(queryParameters: queryParams);
      
      print('Chargement des produits: $uri');

      final response = await http.get(uri, headers: headers).timeout(ApiConfig.timeout);

      if (response.statusCode == ApiConfig.ok) {
        final data = jsonDecode(response.body);
        
        final newProducts = List<Map<String, dynamic>>.from(data['content'] ?? []);
        
        if (refresh) {
          _products = newProducts;
        } else {
          _products.addAll(newProducts);
        }

        _totalPages = data['totalPages'] ?? 0;
        _totalElements = data['totalElements'] ?? 0;
        _currentPage = data['number'] ?? 0;
        _hasMoreData = _currentPage < _totalPages - 1;

        _applyFilters();
        notifyListeners();
      } else {
        print('Erreur lors du chargement des produits: ${response.statusCode}');
        print('Réponse: ${response.body}');
      }
    } catch (e) {
      print('Erreur lors du chargement des produits: $e');
    } finally {
      setLoading(false);
    }
  }

  // Rechercher des produits
  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    _currentPage = 0;
    _products.clear();
    _hasMoreData = true;
    await loadProducts();
  }

  // Charger plus de produits (pagination)
  Future<void> loadMoreProducts() async {
    if (_hasMoreData && !_isLoading) {
      _currentPage++;
      await loadProducts();
    }
  }

  // Obtenir un produit par ID
  Future<Map<String, dynamic>?> getProductById(String id) async {
    try {
      final authService = AuthService();
      final headers = {
        ...ApiConfig.defaultHeaders,
        if (authService.accessToken != null) 'Authorization': 'Bearer ${authService.accessToken!}',
      };

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.produits}/$id'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == ApiConfig.ok) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Erreur lors du chargement du produit: $e');
    }
    return null;
  }

  // Obtenir les produits par catégorie
  Future<void> getProductsByCategory(String category) async {
    _selectedCategory = category;
    _currentPage = 0;
    _products.clear();
    _hasMoreData = true;
    await loadProducts();
  }

  // Obtenir les produits d'un producteur
  Future<void> getProductsByProducer(String producerId) async {
    try {
      final authService = AuthService();
      final headers = {
        ...ApiConfig.defaultHeaders,
        if (authService.accessToken != null) 'Authorization': 'Bearer ${authService.accessToken!}',
      };

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.produitsProducteur}/$producerId'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == ApiConfig.ok) {
        final data = jsonDecode(response.body);
        _products = List<Map<String, dynamic>>.from(data['content'] ?? []);
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      print('Erreur lors du chargement des produits du producteur: $e');
    }
  }

  // Ajouter un nouveau produit (PRODUCTEUR)
  Future<bool> addProduct(Map<String, dynamic> product) async {
    try {
      final authService = AuthService();
      final headers = {
        ...ApiConfig.defaultHeaders,
        if (authService.accessToken != null) 'Authorization': 'Bearer ${authService.accessToken!}',
      };

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.produits}'),
        headers: headers,
        body: jsonEncode(product),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == ApiConfig.created) {
        // Recharger les produits
        await loadProducts(refresh: true);
        return true;
      } else {
        print('Erreur lors de l\'ajout du produit: ${response.statusCode}');
        print('Réponse: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erreur lors de l\'ajout du produit: $e');
      return false;
    }
  }

  // Mettre à jour un produit (PRODUCTEUR)
  Future<bool> updateProduct(String id, Map<String, dynamic> product) async {
    try {
      final authService = AuthService();
      final headers = {
        ...ApiConfig.defaultHeaders,
        if (authService.accessToken != null) 'Authorization': 'Bearer ${authService.accessToken!}',
      };

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.produits}/$id'),
        headers: headers,
        body: jsonEncode(product),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == ApiConfig.ok) {
        // Recharger les produits
        await loadProducts(refresh: true);
        return true;
      } else {
        print('Erreur lors de la mise à jour du produit: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du produit: $e');
      return false;
    }
  }

  // Supprimer un produit (PRODUCTEUR)
  Future<bool> deleteProduct(String id) async {
    try {
      final authService = AuthService();
      final headers = {
        ...ApiConfig.defaultHeaders,
        if (authService.accessToken != null) 'Authorization': 'Bearer ${authService.accessToken!}',
      };

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.produits}/$id'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == ApiConfig.ok) {
        // Recharger les produits
        await loadProducts(refresh: true);
        return true;
      } else {
        print('Erreur lors de la suppression du produit: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Erreur lors de la suppression du produit: $e');
      return false;
    }
  }

  // Appliquer les filtres
  void _applyFilters() {
    _filteredProducts = List.from(_products);

    // Filtrer par catégorie
    if (_selectedCategory != 'Tous') {
      _filteredProducts = _filteredProducts
          .where((product) => product['categorie'] == _selectedCategory)
          .toList();
    }

    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      _filteredProducts = _filteredProducts
          .where((product) =>
              product['nom'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product['description'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Filtrer par bio
    if (_showOnlyBio) {
      _filteredProducts = _filteredProducts
          .where((product) => product['bio'] == true)
          .toList();
    }

    // Trier
    _sortProducts();
  }

  // Trier les produits
  void _sortProducts() {
    switch (_sortBy) {
      case 'name':
        _filteredProducts.sort((a, b) => a['nom'].toString().compareTo(b['nom'].toString()));
        break;
      case 'price_low':
        _filteredProducts.sort((a, b) => double.parse(a['prix'].toString()).compareTo(double.parse(b['prix'].toString())));
        break;
      case 'price_high':
        _filteredProducts.sort((a, b) => double.parse(b['prix'].toString()).compareTo(double.parse(a['prix'].toString())));
        break;
      case 'rating':
        _filteredProducts.sort((a, b) => (b['noteMoyenne'] ?? 0.0).compareTo(a['noteMoyenne'] ?? 0.0));
        break;
      case 'date':
        _filteredProducts.sort((a, b) => b['createdAt'].toString().compareTo(a['createdAt'].toString()));
        break;
    }
  }

  // Mettre à jour les filtres
  void updateFilters({
    String? searchQuery,
    String? selectedCategory,
    bool? showOnlyBio,
    String? sortBy,
  }) {
    if (searchQuery != null) _searchQuery = searchQuery;
    if (selectedCategory != null) _selectedCategory = selectedCategory;
    if (showOnlyBio != null) _showOnlyBio = showOnlyBio;
    if (sortBy != null) _sortBy = sortBy;

    _applyFilters();
    notifyListeners();
  }

  // Obtenir les produits bio
  List<Map<String, dynamic>> getOrganicProducts() {
    return _products.where((product) => product['bio'] == true).toList();
  }

  // Obtenir les produits en vedette
  Future<void> getFeaturedProducts() async {
    try {
      final authService = AuthService();
      final headers = {
        ...ApiConfig.defaultHeaders,
        if (authService.accessToken != null) 'Authorization': 'Bearer ${authService.accessToken!}',
      };

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.produitsFeatured}'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == ApiConfig.ok) {
        final data = jsonDecode(response.body);
        _products = List<Map<String, dynamic>>.from(data);
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      print('Erreur lors du chargement des produits en vedette: $e');
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Réinitialiser les filtres
  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = 'Tous';
    _showOnlyBio = false;
    _sortBy = 'name';
    _currentPage = 0;
    _products.clear();
    _hasMoreData = true;
    _applyFilters();
    notifyListeners();
  }
} 
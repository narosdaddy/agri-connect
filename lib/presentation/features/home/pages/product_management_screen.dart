import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agri_marketplace/data/sources/auth_service.dart';
import 'package:agri_marketplace/data/sources/product_service.dart';
import 'package:agri_marketplace/presentation/features/auth/provider/auth_provider.dart';
import 'package:agri_marketplace/presentation/features/home/provider/profile_provider.dart';
import 'package:agri_marketplace/data/models/profile_model.dart';
import 'package:agri_marketplace/data/models/product_model.dart';
import 'package:agri_marketplace/data/models/user_model.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  _ProductManagementScreenState createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  ProfileModel? _userInfo;
  List<ProductModel> _myProducts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortBy = 'name';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final productService = Provider.of<ProductService>(context, listen: false);

    if (authProvider.token != null) {
      await profileProvider.fetchMyProfile();
      final userInfo = profileProvider.profile;
      if (userInfo != null) {
        _userInfo = userInfo;
        print('Profil récupéré (product_management): ${_userInfo?.toJson()}');
      }
    }
    await productService.fetchProducts();

    final myProducts =
        productService.products
            .where((p) => p.producteurId == _userInfo?.id)
            .toList();

    setState(() {
      _myProducts = myProducts;
      _isLoading = false;
    });

    _filterAndSortProducts();
  }

  void _filterAndSortProducts() {
    List<ProductModel> filtered = _myProducts;

    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((product) {
            final name = product.nom.toLowerCase();
            final category = (product.categorieId ?? '').toLowerCase();
            final query = _searchQuery.toLowerCase();
            return name.contains(query) || category.contains(query);
          }).toList();
    }

    filtered.sort((a, b) {
      dynamic aValue;
      dynamic bValue;
      switch (_sortBy) {
        case 'name':
          aValue = a.nom;
          bValue = b.nom;
          break;
        case 'price':
          aValue = a.prix ?? 0.0;
          bValue = b.prix ?? 0.0;
          break;
        case 'quantity':
          aValue = a.quantite ?? 0;
          bValue = b.quantite ?? 0;
          break;
        case 'category':
          aValue = a.categorieId ?? '';
          bValue = b.categorieId ?? '';
          break;
        default:
          aValue = a.nom;
          bValue = b.nom;
      }
      int comparison = 0;
      if (aValue is String && bValue is String) {
        comparison = aValue.toLowerCase().compareTo(bValue.toLowerCase());
      } else if (aValue is num && bValue is num) {
        comparison = aValue.compareTo(bValue);
      }
      return _sortAscending ? comparison : -comparison;
    });

    setState(() {
      _myProducts = filtered;
    });
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: Text(
              'Êtes-vous sûr de vouloir supprimer "${product.nom}" ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      final productService = Provider.of<ProductService>(
        context,
        listen: false,
      );
      await productService.deleteProduct(product.id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.nom} a été supprimé'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _updateStock(ProductModel product, int newQuantity) async {
    final productService = Provider.of<ProductService>(context, listen: false);
    final updatedProduct = ProductModel(
      id: product.id,
      nom: product.nom,
      description: product.description,
      prix: product.prix,
      categorieId: product.categorieId,
      quantite: newQuantity,
      producteurId: product.producteurId,
      imageUrl: product.imageUrl,
      bio: product.bio,
      origine: product.origine,
      dateCreation: product.dateCreation,
    );
    await productService.updateProduct(product.id, updatedProduct);
    await _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock de ${product.nom} mis à jour'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _updatePrice(ProductModel product, double newPrice) async {
    final productService = Provider.of<ProductService>(context, listen: false);
    final updatedProduct = ProductModel(
      id: product.id,
      nom: product.nom,
      description: product.description,
      prix: newPrice,
      categorieId: product.categorieId,
      quantite: product.quantite,
      producteurId: product.producteurId,
      imageUrl: product.imageUrl,
      bio: product.bio,
      origine: product.origine,
      dateCreation: product.dateCreation,
    );
    await productService.updateProduct(product.id, updatedProduct);
    await _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Prix de ${product.nom} mis à jour'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des produits'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/add-product',
              ).then((_) => _loadData());
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
              )
              : Column(
                children: [
                  _buildSearchAndFilter(),
                  Expanded(
                    child:
                        _myProducts.isEmpty
                            ? _buildEmptyState()
                            : _buildProductList(),
                  ),
                ],
              ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher un produit...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _filterAndSortProducts();
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Trier par: '),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _sortBy,
                items: const [
                  DropdownMenuItem(value: 'name', child: Text('Nom')),
                  DropdownMenuItem(value: 'price', child: Text('Prix')),
                  DropdownMenuItem(value: 'quantity', child: Text('Stock')),
                  DropdownMenuItem(value: 'category', child: Text('Catégorie')),
                ],
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                  _filterAndSortProducts();
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                ),
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                  });
                  _filterAndSortProducts();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucun produit trouvé',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez par ajouter votre premier produit',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/add-product',
              ).then((_) => _loadData());
            },
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un produit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myProducts.length,
      itemBuilder: (context, index) {
        final product = _myProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final quantity = product.quantite ?? 0;
    final price = product.prix ?? 0.0;
    final isLowStock = quantity < 10;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      product.imageUrl != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image, size: 30);
                              },
                            ),
                          )
                          : const Icon(Icons.image, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.nom,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.categorieId ?? 'Catégorie inconnue',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${price.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isLowStock
                                      ? Colors.orange[100]
                                      : Colors.green[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Stock: $quantity',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color:
                                    isLowStock
                                        ? Colors.orange[700]
                                        : Colors.green[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        // Navigation vers l'édition
                        break;
                      case 'stock':
                        _showStockDialog(product);
                        break;
                      case 'price':
                        _showPriceDialog(product);
                        break;
                      case 'delete':
                        _deleteProduct(product);
                        break;
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Modifier'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'stock',
                          child: Row(
                            children: [
                              Icon(Icons.inventory, size: 20),
                              SizedBox(width: 8),
                              Text('Modifier le stock'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'price',
                          child: Row(
                            children: [
                              Icon(Icons.euro, size: 20),
                              SizedBox(width: 8),
                              Text('Modifier le prix'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Supprimer',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
            if (isLowStock) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[600], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Stock faible - Recommandé de réapprovisionner',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showStockDialog(ProductModel product) {
    final currentStock = product.quantite ?? 0;
    final controller = TextEditingController(text: currentStock.toString());
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Modifier le stock de ${product.nom}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nouvelle quantité',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newQuantity = int.tryParse(controller.text);
                  if (newQuantity != null && newQuantity >= 0) {
                    Navigator.pop(context);
                    _updateStock(product, newQuantity);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                ),
                child: const Text('Mettre à jour'),
              ),
            ],
          ),
    );
  }

  void _showPriceDialog(ProductModel product) {
    final currentPrice = product.prix ?? 0.0;
    final controller = TextEditingController(text: currentPrice.toString());
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Modifier le prix de ${product.nom}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nouveau prix (€)',
                    border: OutlineInputBorder(),
                    prefixText: '€ ',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newPrice = double.tryParse(controller.text);
                  if (newPrice != null && newPrice >= 0) {
                    Navigator.pop(context);
                    _updatePrice(product, newPrice);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                ),
                child: const Text('Mettre à jour'),
              ),
            ],
          ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agri_marketplace/data/sources/product_service.dart';
import 'package:agri_marketplace/data/models/product_model.dart';
import 'package:agri_marketplace/presentation/features/home/pages/product_details_screen.dart';
import 'package:agri_marketplace/presentation/features/home/widgets/categories_header.dart';
import 'package:agri_marketplace/presentation/features/home/widgets/categories_search_and_filters.dart';
import 'package:agri_marketplace/presentation/features/home/widgets/categories_tab_bar.dart';
import 'package:agri_marketplace/presentation/features/home/widgets/category_product_card.dart';
import 'package:agri_marketplace/presentation/features/home/widgets/categories_empty_state.dart';

class Category {
  final String name;
  final IconData icon;
  final Color color;
  final String image;

  Category({
    required this.name,
    required this.icon,
    required this.color,
    required this.image,
  });
}

class CategoriesScreen extends StatefulWidget {
  final String? role;

  const CategoriesScreen({super.key, this.role});

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedCategory = 'Tous';
  String _searchQuery = '';
  bool _showOnlyOrganic = false;
  String _sortBy = 'name';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<ProductModel> _getFilteredProducts(ProductService productService) {
    List<ProductModel> products = productService.products;

    // Filtrer par catégorie
    if (_selectedCategory != 'Tous') {
      products =
          products
              .where(
                (product) => (product.categorieId ?? '') == _selectedCategory,
              )
              .toList();
    }

    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      products =
          products
              .where(
                (product) =>
                    product.nom.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    (product.description?.toLowerCase() ?? '').contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    // Filtrer par bio
    if (_showOnlyOrganic) {
      products = products.where((product) => product.bio == true).toList();
    }

    // Trier
    switch (_sortBy) {
      case 'name':
        products.sort(
          (a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()),
        );
        break;
      case 'price_low':
        products.sort((a, b) => (a.prix ?? 0).compareTo(b.prix ?? 0));
        break;
      case 'price_high':
        products.sort((a, b) => (b.prix ?? 0).compareTo(a.prix ?? 0));
        break;
      // Pas de note sur ProductModel, ignorer le tri rating ou utiliser prix
      case 'rating':
        break;
    }

    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              CategoriesHeader(
                onSort: _showSortDialog,
                showOnlyOrganic: _showOnlyOrganic,
                onToggleOrganic: () {
                  setState(() {
                    _showOnlyOrganic = !_showOnlyOrganic;
                  });
                },
              ),
              CategoriesSearchAndFilters(
                searchQuery: _searchQuery,
                onSearchChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                showOnlyOrganic: _showOnlyOrganic,
                onClearSearch: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
              ),
              CategoriesTabBar(
                selectedCategory: _selectedCategory,
                categories: const [
                  'Tous',
                  'Légumes',
                  'Fruits',
                  'Céréales',
                  'Légumineuses',
                  'Produits laitiers',
                  'Viandes',
                ],
                onCategorySelected: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              ),
              Expanded(
                child: Consumer<ProductService>(
                  builder: (context, productService, child) {
                    final filteredProducts = _getFilteredProducts(
                      productService,
                    );

                    if (filteredProducts.isEmpty) {
                      return CategoriesEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await productService.fetchProducts();
                      },
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return CategoryProductCard(
                            product: product,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductDetailsScreen(
                                        product: product,
                                      ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Trier par'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSortOption('name', 'Nom', Icons.sort_by_alpha),
              _buildSortOption(
                'price_low',
                'Prix croissant',
                Icons.trending_up,
              ),
              _buildSortOption(
                'price_high',
                'Prix décroissant',
                Icons.trending_down,
              ),
              _buildSortOption('rating', 'Note', Icons.star),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String value, String label, IconData icon) {
    final isSelected = _sortBy == value;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.green[600] : Colors.grey[600],
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? Colors.green[600] : Colors.grey[800],
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: Colors.green[600]) : null,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }
}

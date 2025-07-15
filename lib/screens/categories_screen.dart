import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/product_service.dart';
import 'product_details_screen.dart';

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

class _CategoriesScreenState extends State<CategoriesScreen> with TickerProviderStateMixin {
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
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredProducts(ProductService productService) {
    List<Map<String, dynamic>> products = productService.products;

    // Filtrer par catégorie
    if (_selectedCategory != 'Tous') {
      products = products.where((product) => 
        product['category'] == _selectedCategory
      ).toList();
    }

    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      products = products.where((product) =>
        product['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
        product['description'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Filtrer par bio
    if (_showOnlyOrganic) {
      products = products.where((product) => 
        product['isOrganic'] == true
      ).toList();
    }

    // Trier
    switch (_sortBy) {
      case 'name':
        products.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
        break;
      case 'price_low':
        products.sort((a, b) => (a['price'] ?? 0).compareTo(b['price'] ?? 0));
        break;
      case 'price_high':
        products.sort((a, b) => (b['price'] ?? 0).compareTo(a['price'] ?? 0));
        break;
      case 'rating':
        products.sort((a, b) => (b['rating'] ?? 0).compareTo(a['rating'] ?? 0));
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
              _buildHeader(),
              _buildSearchAndFilters(),
              _buildCategoryTabs(),
              Expanded(
                child: Consumer<ProductService>(
                  builder: (context, productService, child) {
                    final filteredProducts = _getFilteredProducts(productService);
                    
                    if (filteredProducts.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await productService.initializeProducts();
                      },
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          return _buildProductCard(filteredProducts[index]);
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

  Widget _buildHeader() {
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
      child: SafeArea(
        child: Row(
          children: [
            const Text(
              'Produits',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                _showSortDialog();
              },
              icon: const Icon(Icons.sort),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _showOnlyOrganic = !_showOnlyOrganic;
                });
              },
              icon: Icon(
                Icons.eco,
                color: _showOnlyOrganic ? Colors.green[600] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Rechercher un produit...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          if (_showOnlyOrganic)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.eco, color: Colors.green[700], size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Produits bio uniquement',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Consumer<ProductService>(
      builder: (context, productService, child) {
        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: productService.categories.length,
            itemBuilder: (context, index) {
              final category = productService.categories[index];
              final isSelected = _selectedCategory == category;
              
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  selectedColor: Colors.green[100],
                  checkmarkColor: Colors.green[600],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.green[700] : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: product['image'] != null
                        ? Image.network(
                            product['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey[400],
                              );
                            },
                          )
                        : Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                  ),
                ),
                if (product['isOrganic'] == true)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'BIO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Produit',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['producer'] ?? 'Producteur',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product['price']?.toStringAsFixed(2) ?? '0.00'} €/kg',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[600],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber[600],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${product['rating']?.toStringAsFixed(1) ?? '0.0'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun produit trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
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
              _buildSortOption('price_low', 'Prix croissant', Icons.trending_up),
              _buildSortOption('price_high', 'Prix décroissant', Icons.trending_down),
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
      trailing: isSelected
          ? Icon(Icons.check, color: Colors.green[600])
          : null,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../services/order_service.dart';
import 'product_details_screen.dart';
import 'producer_dashboard_screen.dart';
import 'categories_screen.dart';
import 'cart_page.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> _userInfo = {};
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userInfo = await authService.getUserInfo();
    
    if (userInfo != null) {
      _userInfo = userInfo;
      final userRole = _userInfo['role']?.toLowerCase() ?? '';
      final userName = _userInfo['name'] ?? 'Utilisateur';
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
        ),
      );
    }

    final userRole = _userInfo['role']?.toLowerCase() ?? '';
    
    // Si c'est un producteur, afficher le tableau de bord producteur
    if (userRole == 'producteur') {
      return const ProducerDashboardScreen();
    }
    
    // Si c'est un acheteur, afficher l'interface par défaut avec les produits
    // L'acheteur aura accès à tous les produits via l'interface par défaut

    // Interface par défaut pour les utilisateurs non définis et acheteurs
    return Scaffold(
      body: _buildDefaultHomeScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Catégories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Panier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultHomeScreen() {
    final userName = _userInfo['name'] ?? 'Utilisateur';
    final userRole = _userInfo['role']?.toLowerCase() ?? '';
    
    return IndexedStack(
      index: _currentIndex,
      children: [
        // Page d'accueil avec produits
        _buildHomePage(userName, userRole),
        // Page catégories
        const CategoriesScreen(),
        // Page panier
        const CartPage(),
        // Page profil
        const ProfileScreen(),
      ],
    );
  }

  Widget _buildHomePage(String userName, String userRole) {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadUserInfo();
        final cartService = Provider.of<CartService>(context, listen: false);
        final orderService = Provider.of<OrderService>(context, listen: false);
        await cartService.loadCart();
        await orderService.loadOrders();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(userName, userRole),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildQuickStats(),
            const SizedBox(height: 24),
            _buildFeaturedProducts(),
            const SizedBox(height: 24),
            _buildCategoryGrid(),
            const SizedBox(height: 24),
            _buildShoppingTips(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String userName, String userRole) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Icon(
                    userRole == 'producteur' ? Icons.agriculture : Icons.shopping_basket,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour, $userName!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        userRole == 'producteur' 
                          ? 'Gérez vos produits agricoles'
                          : 'Découvrez les meilleurs produits locaux',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Ouvrir les notifications
                  },
                  icon: const Icon(Icons.notifications, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Rechercher des produits...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF4CAF50)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.filter_list, color: Color(0xFF4CAF50)),
              onPressed: () {
                // Ouvrir les filtres
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onSubmitted: (value) {
            // Rechercher les produits
            final productService = Provider.of<ProductService>(context, listen: false);
            productService.updateFilters(searchQuery: value);
          },
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Consumer2<CartService, OrderService>(
      builder: (context, cartService, orderService, child) {
        final cartItems = cartService.cartItems;
        final totalSpent = orderService.orders.fold(0.0, (sum, order) => sum + (order['total'] ?? 0.0));
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.shopping_cart,
                  title: 'Panier',
                  value: '${cartItems.length}',
                  subtitle: 'Articles',
                  color: Colors.blue,
                  onTap: () {
                    setState(() {
                      _currentIndex = 2; // Aller au panier
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.receipt_long,
                  title: 'Commandes',
                  value: '${orderService.orders.length}',
                  subtitle: 'Total',
                  color: Colors.green,
                  onTap: () {
                    // Navigation vers les commandes
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.euro,
                  title: 'Dépensé',
                  value: '${totalSpent.toStringAsFixed(0)}€',
                  subtitle: 'Total',
                  color: Colors.orange,
                  onTap: () {
                    // Navigation vers l'historique
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProducts() {
    return Consumer<ProductService>(
      builder: (context, productService, child) {
        final products = productService.products.take(6).toList();
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Produits en vedette',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentIndex = 1; // Aller aux catégories
                      });
                    },
                    child: Text(
                      'Voir tout',
                      style: TextStyle(color: Colors.green[600]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductCard(product);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: product['image'] != null
                  ? Image.network(
                      product['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.image, size: 40, color: Colors.grey),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(Icons.image, size: 40, color: Colors.grey),
                    ),
            ),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${product['rating']?.toStringAsFixed(1) ?? '0.0'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${product['price']?.toStringAsFixed(2) ?? '0.00'} €',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(product: product),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      'Voir détails',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {'name': 'Légumes', 'icon': Icons.eco, 'color': Colors.green},
      {'name': 'Fruits', 'icon': Icons.apple, 'color': Colors.red},
      {'name': 'Céréales', 'icon': Icons.grain, 'color': Colors.amber},
      {'name': 'Légumineuses', 'icon': Icons.circle, 'color': Colors.brown},
      {'name': 'Produits laitiers', 'icon': Icons.local_drink, 'color': Colors.blue},
      {'name': 'Viandes', 'icon': Icons.restaurant, 'color': Colors.orange},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catégories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(category);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = 1; // Aller aux catégories
        });
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: category['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                category['icon'],
                color: category['color'],
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category['name'],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingTips() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Conseils d\'achat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTipCard(
            icon: Icons.local_shipping,
            title: 'Livraison rapide',
            description: 'Recevez vos produits frais en 24h',
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            icon: Icons.eco,
            title: 'Produits locaux',
            description: 'Soutenez les producteurs locaux',
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            icon: Icons.security,
            title: 'Paiement sécurisé',
            description: 'Transactions 100% sécurisées',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

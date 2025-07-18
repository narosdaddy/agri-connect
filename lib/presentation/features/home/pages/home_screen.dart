import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agri_marketplace/presentation/features/auth/provider/auth_provider.dart';
import 'package:agri_marketplace/data/models/user_model.dart';
import 'package:agri_marketplace/data/sources/auth_service.dart';
import 'package:agri_marketplace/data/sources/cart_service.dart';
import 'package:agri_marketplace/data/sources/product_service.dart';
import 'package:agri_marketplace/data/sources/order_service.dart';
import 'package:agri_marketplace/presentation/features/home/pages/product_details_screen.dart';
import 'package:agri_marketplace/presentation/features/home/pages/producer_dashboard_screen.dart';
import 'package:agri_marketplace/presentation/features/home/pages/categories_screen.dart';
import 'package:agri_marketplace/presentation/features/home/pages/cart_page.dart';
import 'package:agri_marketplace/presentation/features/home/pages/profile_screen.dart';
import 'package:agri_marketplace/presentation/features/home/provider/profile_provider.dart';
import 'package:agri_marketplace/presentation/features/home/widgets/home_header.dart';
import 'package:agri_marketplace/presentation/features/home/widgets/home_search_bar.dart';
import 'package:agri_marketplace/presentation/features/home/widgets/home_stat_card.dart';
import 'package:agri_marketplace/presentation/features/home/widgets/home_product_card.dart';
import 'package:agri_marketplace/presentation/features/home/widgets/home_category_card.dart';
import 'package:agri_marketplace/presentation/features/home/widgets/home_tip_card.dart';
import 'package:agri_marketplace/data/models/product_model.dart';
import 'package:agri_marketplace/data/models/profile_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ProfileModel? _userInfo;
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    if (authProvider.token != null) {
      await profileProvider.fetchMyProfile();
      _userInfo = profileProvider.profile;
      print('Profil récupéré (home_screen): ${_userInfo?.toJson()}');
    }
    setState(() {
      _isLoading = false;
    });
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

    final userRole = _userInfo?.role?.toLowerCase() ?? '';

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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Catégories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Panier',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildDefaultHomeScreen() {
    final userName = _userInfo?.nom ?? 'Utilisateur';
    final userRole = _userInfo?.role?.toLowerCase() ?? '';

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
    final productService = Provider.of<ProductService>(context);
    final List<ProductModel> products = productService.getProducts();
    return RefreshIndicator(
      onRefresh: () async {
        await _loadUserInfo();
        final cartService = Provider.of<CartService>(context, listen: false);
        final orderService = Provider.of<OrderService>(context, listen: false);
        await cartService.getCart();
        await orderService.loadOrders();
        await productService.fetchProducts();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            HomeHeader(userName: userName, userRole: userRole),
            const SizedBox(height: 16),
            const HomeSearchBar(),
            const SizedBox(height: 16),
            // Statistiques (exemple statique, à adapter selon vos données)
            HomeStatCard(
              icon: Icons.shopping_cart,
              title: 'Commandes',
              value: '12',
              subtitle: 'Commandes passées',
              color: Colors.green,
              onTap: () {},
            ),
            const SizedBox(height: 24),
            // Liste des produits
            SizedBox(
              height: 260,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return HomeProductCard(product: product);
                },
              ),
            ),
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

  Widget _buildCategoryGrid() {
    final categories = [
      {'name': 'Légumes', 'icon': Icons.eco, 'color': Colors.green},
      {'name': 'Fruits', 'icon': Icons.apple, 'color': Colors.red},
      {'name': 'Céréales', 'icon': Icons.grain, 'color': Colors.amber},
      {'name': 'Légumineuses', 'icon': Icons.circle, 'color': Colors.brown},
      {
        'name': 'Produits laitiers',
        'icon': Icons.local_drink,
        'color': Colors.blue,
      },
      {'name': 'Viandes', 'icon': Icons.restaurant, 'color': Colors.orange},
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catégories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              return HomeCategoryCard(category: category);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingTips() {
    final tips = [
      {
        'icon': Icons.eco,
        'title': 'Achetez local',
        'description':
            'Soutenez les producteurs locaux pour une alimentation plus saine.',
        'color': Colors.green,
      },
      {
        'icon': Icons.star,
        'title': 'Produits bio',
        'description':
            'Privilégiez les produits issus de l’agriculture biologique.',
        'color': Colors.amber,
      },
      {
        'icon': Icons.shopping_basket,
        'title': 'Commandez en ligne',
        'description': 'Profitez de la livraison à domicile de produits frais.',
        'color': Colors.blue,
      },
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Conseils d’achat',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tips.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final tip = tips[index];
              return HomeTipCard(
                icon: tip['icon'] as IconData,
                title: tip['title'] as String,
                description: tip['description'] as String,
                color: tip['color'] as Color,
              );
            },
          ),
        ),
      ],
    );
  }
}

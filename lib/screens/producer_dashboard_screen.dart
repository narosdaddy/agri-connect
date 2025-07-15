import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/order_service.dart';
import 'add_product_screen.dart';
import 'product_management_screen.dart';
import 'sales_analytics_screen.dart';

class ProducerDashboardScreen extends StatefulWidget {
  const ProducerDashboardScreen({super.key});

  @override
  _ProducerDashboardScreenState createState() => _ProducerDashboardScreenState();
}

class _ProducerDashboardScreenState extends State<ProducerDashboardScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  Map<String, dynamic> _userInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    
    _loadUserInfo();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userInfo = await authService.getUserInfo();
    
    if (userInfo != null) {
      _userInfo = userInfo;
      final userName = _userInfo['name'] ?? 'Producteur';
      
      setState(() {
        _userInfo = userInfo;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
        : RefreshIndicator(
            onRefresh: () async {
              await _loadUserInfo();
              final productService = Provider.of<ProductService>(context, listen: false);
              final orderService = Provider.of<OrderService>(context, listen: false);
              
              await productService.initializeProducts();
              await orderService.loadOrders();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildQuickStats(),
                      const SizedBox(height: 24),
                      _buildActionCards(),
                      const SizedBox(height: 24),
                      _buildRecentOrders(),
                      const SizedBox(height: 24),
                      _buildProductManagement(),
                      const SizedBox(height: 24),
                      _buildAnalyticsPreview(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildHeader() {
    final userName = _userInfo['name'] ?? 'Producteur';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
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
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(
                    Icons.agriculture,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour, $userName!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tableau de bord Producteur',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PRODUCTEUR',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Gérez vos produits et suivez vos ventes',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Consumer2<ProductService, OrderService>(
      builder: (context, productService, orderService, child) {
        final myProducts = productService.products.where((p) => p['producerId'] == _userInfo['email']).toList();
        final myOrders = orderService.orders.where((o) => 
          o['items'].any((item) => myProducts.any((p) => p['id'] == item['id']))
        ).toList();
        
        final totalRevenue = myOrders.fold(0.0, (sum, order) => sum + (order['total'] ?? 0.0));
        final activeProducts = myProducts.where((p) => (p['quantity'] ?? 0) > 0).length;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.inventory,
                  title: 'Produits',
                  value: '${myProducts.length}',
                  subtitle: '$activeProducts actifs',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.shopping_cart,
                  title: 'Commandes',
                  value: '${myOrders.length}',
                  subtitle: 'Cette semaine',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.euro,
                  title: 'Revenus',
                  value: '${totalRevenue.toStringAsFixed(0)}€',
                  subtitle: 'Total',
                  color: Colors.green,
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
  }) {
    return Container(
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
              Icon(Icons.trending_up, color: Colors.green[600], size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions rapides',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.add_circle,
                  title: 'Ajouter un produit',
                  subtitle: 'Mettre en vente',
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddProductScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.inventory_2,
                  title: 'Gérer mes produits',
                  subtitle: 'Modifier/Supprimer',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductManagementScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.analytics,
                  title: 'Analyses',
                  subtitle: 'Voir les statistiques',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SalesAnalyticsScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.local_shipping,
                  title: 'Livraisons',
                  subtitle: 'Gérer les expéditions',
                  color: Colors.orange,
                  onTap: () {
                    // Navigation vers la gestion des livraisons
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Consumer2<ProductService, OrderService>(
      builder: (context, productService, orderService, child) {
        final myProducts = productService.products.where((p) => p['producerId'] == _userInfo['email']).toList();
        final myOrders = orderService.orders.where((o) => 
          o['items'].any((item) => myProducts.any((p) => p['id'] == item['id']))
        ).take(3).toList();
        
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Commandes récentes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigation vers toutes les commandes
                    },
                    child: Text(
                      'Voir tout',
                      style: TextStyle(color: Colors.green[600]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (myOrders.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Aucune commande',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: myOrders.map((order) => _buildOrderItem(order)).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    final status = order['status'] ?? 'En cours';
    final total = order['total']?.toString() ?? '0';
    final date = order['orderDate'] ?? 'Date inconnue';
    
    Color statusColor;
    IconData statusIcon;
    
    switch (status.toLowerCase()) {
      case 'livré':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'en cours':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'annulé':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Commande #${order['id'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$total €',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductManagement() {
    return Consumer<ProductService>(
      builder: (context, productService, child) {
        final myProducts = productService.products.where((p) => p['producerId'] == _userInfo['email']).toList();
        final lowStockProducts = myProducts.where((p) => (p['quantity'] ?? 0) < 10).toList();
        
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Gestion des produits',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductManagementScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Gérer',
                      style: TextStyle(color: Colors.green[600]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildProductStat(
                      icon: Icons.inventory,
                      title: 'Total',
                      value: '${myProducts.length}',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildProductStat(
                      icon: Icons.warning,
                      title: 'Stock faible',
                      value: '${lowStockProducts.length}',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              if (lowStockProducts.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${lowStockProducts.length} produit(s) en stock faible',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductStat({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
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
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsPreview() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Aperçu des analyses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SalesAnalyticsScreen(),
                    ),
                  );
                },
                child: Text(
                  'Voir plus',
                  style: TextStyle(color: Colors.green[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  title: 'Ventes du mois',
                  value: '+12%',
                  subtitle: 'vs mois dernier',
                  color: Colors.green,
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard(
                  title: 'Produits populaires',
                  value: '3',
                  subtitle: 'en top 10',
                  color: Colors.blue,
                  isPositive: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
} 
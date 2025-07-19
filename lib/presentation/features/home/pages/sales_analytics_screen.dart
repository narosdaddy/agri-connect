import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agri_marketplace/presentation/features/auth/provider/auth_provider.dart';
import 'package:agri_marketplace/presentation/features/home/provider/profile_provider.dart';
import 'package:agri_marketplace/data/sources/auth_service.dart';
import 'package:agri_marketplace/data/sources/product_service.dart';
import 'package:agri_marketplace/data/sources/order_service.dart';
import 'package:agri_marketplace/data/models/profile_model.dart';
import 'package:agri_marketplace/data/models/product_model.dart';
import 'package:agri_marketplace/data/models/order_model.dart';
import 'package:agri_marketplace/data/models/user_model.dart';

class SalesAnalyticsScreen extends StatefulWidget {
  const SalesAnalyticsScreen({super.key});

  @override
  _SalesAnalyticsScreenState createState() => _SalesAnalyticsScreenState();
}

class _SalesAnalyticsScreenState extends State<SalesAnalyticsScreen> {
  ProfileModel? _userInfo;
  List<ProductModel> _myProducts = [];
  List<OrderModel> _myOrders = [];
  bool _isLoading = true;
  String _selectedPeriod = 'month';

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
    final orderService = Provider.of<OrderService>(context, listen: false);

    if (authProvider.token != null) {
      await profileProvider.fetchMyProfile();
      final userInfo = profileProvider.profile;
      if (userInfo != null) {
        _userInfo = userInfo;
        print('Profil récupéré (sales_analytics): ${_userInfo?.toJson()}');
        await productService.fetchProducts();
        await orderService.loadOrders();

        final myProducts =
            productService.products
                .where((p) => p.producteurId == userInfo.id)
                .toList();

        final myOrders =
            orderService.orders
                .where(
                  (o) =>
                      o.elements?.any(
                        (item) => myProducts.any((p) => p.id == item.produitId),
                      ) ??
                      false,
                )
                .toList();

        setState(() {
          _myProducts = myProducts;
          _myOrders = myOrders;
          _isLoading = false;
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  double _calculateTotalRevenue() {
    return _myOrders.fold(0.0, (sum, order) => sum + (order.total ?? 0.0));
  }

  int _calculateTotalOrders() {
    return _myOrders.length;
  }

  double _calculateAverageOrderValue() {
    if (_myOrders.isEmpty) return 0.0;
    return _calculateTotalRevenue() / _myOrders.length;
  }

  List<ProductModel> _getTopProducts() {
    final productSales = <String, int>{};
    for (final order in _myOrders) {
      for (final item in order.elements ?? []) {
        final productId = item.produitId;
        final quantity =
            (item.quantite is int)
                ? item.quantite as int
                : (item.quantite as num).toInt();
        productSales[productId] = (productSales[productId] ?? 0) + quantity;
      }
    }
    final sortedProducts =
        _myProducts.where((p) => productSales.containsKey(p.id)).toList();
    sortedProducts.sort((a, b) {
      final aSales = productSales[a.id] ?? 0;
      final bSales = productSales[b.id] ?? 0;
      return bSales.compareTo(aSales);
    });
    return sortedProducts.take(5).toList();
  }

  Map<String, int> _getTopProductsSales() {
    final productSales = <String, int>{};
    for (final order in _myOrders) {
      for (final item in order.elements ?? []) {
        final productId = item.produitId;
        final quantity =
            (item.quantite is int)
                ? item.quantite as int
                : (item.quantite as num).toInt();
        productSales[productId] = (productSales[productId] ?? 0) + quantity;
      }
    }
    return productSales;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyses de ventes'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
              )
              : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildPeriodSelector(),
                      const SizedBox(height: 16),
                      _buildRevenueOverview(),
                      const SizedBox(height: 16),
                      _buildTopProducts(),
                      const SizedBox(height: 16),
                      _buildOrderAnalytics(),
                      const SizedBox(height: 16),
                      _buildProductPerformance(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          const Text(
            'Période d\'analyse',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildPeriodButton('week', 'Semaine')),
              const SizedBox(width: 8),
              Expanded(child: _buildPeriodButton('month', 'Mois')),
              const SizedBox(width: 8),
              Expanded(child: _buildPeriodButton('year', 'Année')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period, String label) {
    final isSelected = _selectedPeriod == period;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueOverview() {
    final totalRevenue = _calculateTotalRevenue();
    final totalOrders = _calculateTotalOrders();
    final averageOrder = _calculateAverageOrderValue();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aperçu des revenus',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildRevenueCard(
                  icon: Icons.euro,
                  title: 'Revenus totaux',
                  value: '${totalRevenue.toStringAsFixed(0)} €',
                  subtitle: 'Toutes les ventes',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRevenueCard(
                  icon: Icons.shopping_cart,
                  title: 'Commandes',
                  value: '$totalOrders',
                  subtitle: 'Total',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRevenueCard(
                  icon: Icons.trending_up,
                  title: 'Panier moyen',
                  value: '${averageOrder.toStringAsFixed(0)} €',
                  subtitle: 'Par commande',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRevenueCard(
                  icon: Icons.inventory,
                  title: 'Produits actifs',
                  value:
                      '${_myProducts.where((p) => (p.quantite ?? 0) > 0).length}',
                  subtitle: 'En stock',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard({
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
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProducts() {
    final topProducts = _getTopProducts();

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
            'Produits les plus vendus',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (topProducts.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.bar_chart_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aucune vente enregistrée',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          else
            Column(
              children:
                  topProducts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final product = entry.value;
                    final productSales = _getTopProductsSales();
                    final sales = productSales[product.id] ?? 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.nom,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  product.categorieId ?? 'Catégorie inconnue',
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
                                '$sales unités',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                              Text(
                                '${(product.prix ?? 0.0).toStringAsFixed(2)} €',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderAnalytics() {
    final recentOrders = _myOrders.take(5).toList();

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
            'Commandes récentes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (recentOrders.isEmpty)
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
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          else
            Column(
              children:
                  recentOrders.map((order) {
                    final status = order.statut ?? 'En cours';
                    final total = order.total ?? 0.0;
                    final date = order.dateCreation ?? 'Date inconnue';

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
                            child: Icon(
                              statusIcon,
                              color: statusColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Commande #${order.id ?? 'N/A'}',
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
                                '${total.toStringAsFixed(2)} €',
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
                  }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildProductPerformance() {
    final lowStockProducts =
        _myProducts.where((p) => (p.quantite ?? 0) < 10).toList();
    final outOfStockProducts =
        _myProducts.where((p) => (p.quantite ?? 0) == 0).toList();

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
            'Performance des produits',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPerformanceCard(
                  icon: Icons.warning,
                  title: 'Stock faible',
                  value: '${lowStockProducts.length}',
                  subtitle: 'Produits',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPerformanceCard(
                  icon: Icons.remove_shopping_cart,
                  title: 'Rupture',
                  value: '${outOfStockProducts.length}',
                  subtitle: 'Produits',
                  color: Colors.red,
                ),
              ),
            ],
          ),
          if (lowStockProducts.isNotEmpty || outOfStockProducts.isNotEmpty) ...[
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
                  Icon(Icons.info, color: Colors.orange[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${lowStockProducts.length + outOfStockProducts.length} produit(s) nécessitent votre attention',
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
  }

  Widget _buildPerformanceCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

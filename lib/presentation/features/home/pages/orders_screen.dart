import 'package:flutter/material.dart';
import 'package:agri_marketplace/presentation/features/home/pages/orders_screen.dart';

class OrdersTrackingScreen extends StatefulWidget {
  final String? role;

  const OrdersTrackingScreen({Key? key, this.role}) : super(key: key);
  // ignore: library_private_types_in_public_api
  // This widget is the root of the Orders Tracking Screen.

  @override
  // ignore: library_private_types_in_public_api
  _OrdersTrackingScreenState createState() => _OrdersTrackingScreenState();
}

class _OrdersTrackingScreenState extends State<OrdersTrackingScreen> {
  String _selectedFilter = 'Toutes';
  String _selectedSort = 'Date récente';

  final List<Order> _orders = [
    Order(
      id: '001',
      productName: 'Tomates fraîches Bio',
      productImage: 'assets/images/tomatoes.jpg',
      quantity: '2 kg',
      totalPrice: 9.50,
      orderDate: DateTime.now().subtract(Duration(days: 1)),
      producerName: 'Ferme des Oliviers',
      status: OrderStatus.enCours,
      deliveryDate: DateTime.now().add(Duration(days: 1)),
      items: [
        OrderItem('Tomates cerises Bio', '1 kg', 4.80),
        OrderItem('Tomates anciennes', '1 kg', 4.70),
      ],
    ),
    Order(
      id: '002',
      productName: 'Panier de légumes de saison',
      productImage: 'assets/images/vegetables.jpg',
      quantity: '1 panier',
      totalPrice: 18.90,
      orderDate: DateTime.now().subtract(Duration(days: 3)),
      producerName: 'Maraîchage du Soleil',
      status: OrderStatus.livree,
      deliveryDate: DateTime.now().subtract(Duration(days: 1)),
      items: [
        OrderItem('Carottes', '500g', 2.40),
        OrderItem('Courgettes', '800g', 3.20),
        OrderItem('Salade verte', '2 pièces', 3.60),
        OrderItem('Radis', '1 botte', 1.80),
        OrderItem('Pommes de terre', '1 kg', 2.90),
        OrderItem('Oignons', '500g', 1.50),
        OrderItem('Persil', '1 botte', 1.20),
        OrderItem('Frais de livraison', '', 2.30),
      ],
    ),
    Order(
      id: '003',
      productName: 'Pommes Golden Bio',
      productImage: 'assets/images/apples.jpg',
      quantity: '3 kg',
      totalPrice: 8.40,
      orderDate: DateTime.now().subtract(Duration(days: 7)),
      producerName: 'Verger de la Vallée',
      status: OrderStatus.enAttente,
      deliveryDate: DateTime.now().add(Duration(days: 2)),
      items: [OrderItem('Pommes Golden Bio', '3 kg', 8.40)],
    ),
    Order(
      id: '004',
      productName: 'Fromage de chèvre artisanal',
      productImage: 'assets/images/cheese.jpg',
      quantity: '500g',
      totalPrice: 12.50,
      orderDate: DateTime.now().subtract(Duration(days: 14)),
      producerName: 'Chèvrerie des Collines',
      status: OrderStatus.annulee,
      deliveryDate: null,
      items: [
        OrderItem('Fromage de chèvre frais', '250g', 6.00),
        OrderItem('Fromage de chèvre affiné', '250g', 6.50),
      ],
    ),
  ];

  List<Order> get filteredOrders {
    List<Order> filtered = _orders;

    // Filtrage par statut
    if (_selectedFilter != 'Toutes') {
      OrderStatus filterStatus = OrderStatus.values.firstWhere(
        (status) => _getStatusText(status) == _selectedFilter,
      );
      filtered =
          filtered.where((order) => order.status == filterStatus).toList();
    }

    // Tri
    if (_selectedSort == 'Date récente') {
      filtered.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    } else if (_selectedSort == 'Date ancienne') {
      filtered.sort((a, b) => a.orderDate.compareTo(b.orderDate));
    } else if (_selectedSort == 'Prix croissant') {
      filtered.sort((a, b) => a.totalPrice.compareTo(b.totalPrice));
    } else if (_selectedSort == 'Prix décroissant') {
      filtered.sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [_buildFiltersSection(), Expanded(child: _buildOrdersList())],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF2E7D32),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          const Icon(Icons.agriculture, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Text(
            'Mes Commandes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${filteredOrders.length} commande(s)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildFilterDropdown()),
              const SizedBox(width: 12),
              Expanded(child: _buildSortDropdown()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
          isExpanded: true,
          icon: const Icon(Icons.filter_list, size: 20),
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          items:
              ['Toutes', 'En attente', 'En cours', 'Livrée', 'Annulée'].map((
                String value,
              ) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedFilter = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSort,
          isExpanded: true,
          icon: const Icon(Icons.sort, size: 20),
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          items:
              [
                'Date récente',
                'Date ancienne',
                'Prix croissant',
                'Prix décroissant',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedSort = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    if (filteredOrders.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(filteredOrders[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune commande trouvée',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeader(order),
          _buildOrderContent(order),
          _buildOrderFooter(order),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Commande #${order.id}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatDate(order.orderDate)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          _buildStatusBadge(order.status),
        ],
      ),
    );
  }

  Widget _buildOrderContent(Order order) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Image du produit
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFF1F8E9),
              border: Border.all(color: const Color(0xFFE8F5E8)),
            ),
            child: const Icon(Icons.eco, color: Color(0xFF4CAF50), size: 40),
          ),
          const SizedBox(width: 16),
          // Détails du produit
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.productName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.producerName,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quantité: ${order.quantity}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    Text(
                      '${order.totalPrice.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderFooter(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (order.deliveryDate != null) ...[
            Row(
              children: [
                Icon(Icons.local_shipping, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  order.status == OrderStatus.livree
                      ? 'Livrée le ${_formatDate(order.deliveryDate!)}'
                      : 'Livraison prévue: ${_formatDate(order.deliveryDate!)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ] else ...[
            Text(
              'Commande annulée',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
          TextButton.icon(
            onPressed: () => _showOrderDetails(order),
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('Détails'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color backgroundColor;
    Color textColor;
    String text = _getStatusText(status);

    switch (status) {
      case OrderStatus.enAttente:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
        break;
      case OrderStatus.enCours:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[700]!;
        break;
      case OrderStatus.livree:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        break;
      case OrderStatus.annulee:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[700]!;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.enAttente:
        return 'En attente';
      case OrderStatus.enCours:
        return 'En cours';
      case OrderStatus.livree:
        return 'Livrée';
      case OrderStatus.annulee:
        return 'Annulée';
    }
  }

  String _formatDate(DateTime date) {
    List<String> months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jun',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOrderDetailsModal(order),
    );
  }

  Widget _buildOrderDetailsModal(Order order) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Détails de la commande #${order.id}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection('Informations générales', [
                    DetailRow('Date de commande', _formatDate(order.orderDate)),
                    DetailRow('Producteur', order.producerName),
                    DetailRow('Statut', _getStatusText(order.status)),
                    if (order.deliveryDate != null)
                      DetailRow(
                        order.status == OrderStatus.livree
                            ? 'Date de livraison'
                            : 'Livraison prévue',
                        _formatDate(order.deliveryDate!),
                      ),
                  ]),
                  const SizedBox(height: 20),
                  _buildDetailSection(
                    'Articles commandés',
                    order.items
                        .map(
                          (item) => DetailRow(
                            item.name +
                                (item.quantity.isNotEmpty
                                    ? ' (${item.quantity})'
                                    : ''),
                            '${item.price.toStringAsFixed(2)} €',
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total de la commande',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${order.totalPrice.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<DetailRow> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children:
                rows.asMap().entries.map((entry) {
                  int index = entry.key;
                  DetailRow row = entry.value;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border:
                          index < rows.length - 1
                              ? Border(
                                bottom: BorderSide(color: Colors.grey[200]!),
                              )
                              : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            row.label,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        Text(
                          row.value,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}

// Modèles de données
enum OrderStatus { enAttente, enCours, livree, annulee }

class Order {
  final String id;
  final String productName;
  final String productImage;
  final String quantity;
  final double totalPrice;
  final DateTime orderDate;
  final String producerName;
  final OrderStatus status;
  final DateTime? deliveryDate;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.totalPrice,
    required this.orderDate,
    required this.producerName,
    required this.status,
    this.deliveryDate,
    required this.items,
  });
}

class OrderItem {
  final String name;
  final String quantity;
  final double price;

  OrderItem(this.name, this.quantity, this.price);
}

class DetailRow {
  final String label;
  final String value;

  DetailRow(this.label, this.value);
}
// Fin du code
// Note: This code is a complete implementation of the Orders Tracking Screen
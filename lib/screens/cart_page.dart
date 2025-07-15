import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/auth_service.dart';

class CartPage extends StatefulWidget {
  final String? role;

  const CartPage({super.key, this.role});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isProcessingOrder = false;

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

  Future<void> _processOrder() async {
    setState(() {
      _isProcessingOrder = true;
    });

    try {
      final cartService = Provider.of<CartService>(context, listen: false);
      final orderService = Provider.of<OrderService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);

      if (cartService.cartItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Votre panier est vide'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Créer la commande
      final order = await orderService.createOrder(
        methodePaiement: 'CARTE_BANCAIRE',
        adresseLivraison: 'Adresse de livraison',
        villeLivraison: 'Ville',
        codePostalLivraison: '75000',
        paysLivraison: 'France',
        telephoneLivraison: '0123456789',
      );

      if (order != null) {
        // Vider le panier
        await cartService.clearCart();
        
        // Afficher le dialogue de confirmation
        _showOrderConfirmationDialog(order);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la création de la commande'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessingOrder = false;
      });
    }
  }

  void _showOrderConfirmationDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600], size: 28),
              const SizedBox(width: 8),
              const Text('Commande confirmée!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Votre commande #${order['id']} a été créée avec succès!',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Total: ${order['total']} €',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${order['status']}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigation vers les commandes
              },
              child: const Text('Voir mes commandes'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Continuer les achats'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          final cartService = Provider.of<CartService>(context, listen: false);
          await cartService.loadCart();
        },
        child: Consumer<CartService>(
          builder: (context, cartService, child) {
            if (cartService.cartItems.isEmpty) {
              return _buildEmptyCart();
            }

            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartService.cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartService.cartItems[index];
                          return _buildCartItem(item, cartService);
                        },
                      ),
                    ),
                    _buildOrderSummary(cartService),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Votre panier est vide',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ajoutez des produits pour commencer vos achats',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Navigation vers les produits
            },
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Découvrir les produits'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
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
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 8),
            const Text(
              'Mon Panier',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Consumer<CartService>(
              builder: (context, cartService, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${cartService.cartItems.length} articles',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, CartService cartService) {
    final name = item['name'] ?? 'Produit';
    final price = item['price']?.toDouble() ?? 0.0;
    final quantity = item['quantity'] ?? 1;
    final total = price * quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          // Image du produit
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: item['image'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image,
                          size: 32,
                          color: Colors.grey[400],
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.image,
                    size: 32,
                    color: Colors.grey[400],
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${price.toStringAsFixed(2)} €/kg',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        cartService.updateQuantity(item['id'], quantity - 1);
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                      iconSize: 20,
                      color: Colors.grey[600],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        quantity.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        cartService.updateQuantity(item['id'], quantity + 1);
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      iconSize: 20,
                      color: Colors.green[600],
                    ),
                    const Spacer(),
                    Text(
                      '${total.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              cartService.removeFromCart(item['id']);
            },
            icon: const Icon(Icons.delete_outline),
            color: Colors.red[400],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartService cartService) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sous-total',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${cartService.subtotal.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Livraison',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${cartService.shipping.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${cartService.total.toStringAsFixed(2)} €',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessingOrder ? null : _processOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isProcessingOrder
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Traitement...'),
                        ],
                      )
                    : const Text(
                        'Valider ma commande',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_marketplace/data/sources/order_service.dart';
import 'package:agri_marketplace/data/sources/cart_service.dart';
import 'package:agri_marketplace/presentation/features/home/pages/producteur_request_screen.dart';
import 'package:agri_marketplace/presentation/features/auth/provider/auth_provider.dart';
import 'package:agri_marketplace/presentation/features/home/provider/profile_provider.dart';
import 'package:agri_marketplace/data/models/auth_model.dart';
import 'package:agri_marketplace/data/models/profile_model.dart';
import 'package:agri_marketplace/data/models/order_model.dart';
import 'package:agri_marketplace/data/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  final String? role;

  const ProfileScreen({super.key, this.role});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  ProfileModel? _userInfo;
  bool _isLoading = true;
  bool _isEditing = false;

  // Contrôleurs pour l'édition
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  ProfileProvider? _profileProvider;

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

    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        await _profileProvider!.fetchMyProfile();
        final userInfo = _profileProvider!.profile;
        if (userInfo != null) {
          _userInfo = userInfo;
          print('Profil récupéré (initState): ${_userInfo?.toJson()}');
          _nameController.text = userInfo.nom;
          _emailController.text = userInfo.email;
          _phoneController.text = userInfo.telephone ?? '';
        }
      }
      setState(() {
        _isLoading = false;
      });
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    if (authProvider.token != null) {
      await profileProvider.fetchMyProfile();
      final userInfo = profileProvider.profile;
      if (userInfo != null) {
        _userInfo = userInfo;
        print('Profil récupéré (_loadUserInfo): ${_userInfo?.toJson()}');
        _nameController.text = userInfo.nom;
        _emailController.text = userInfo.email;
        _phoneController.text = userInfo.telephone ?? '';
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    // Ici on pourrait ajouter la logique pour sauvegarder les modifications
    setState(() {
      _isEditing = false;
    });

    // Mettre à jour les informations locales
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text);
    await prefs.setString('user_email', _emailController.text);
    await prefs.setString('user_phone', _phoneController.text);

    await _loadUserInfo();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil mis à jour avec succès!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
              )
              : RefreshIndicator(
                onRefresh: () async {
                  await _loadUserInfo();
                  final orderService = Provider.of<OrderService>(
                    context,
                    listen: false,
                  );
                  await orderService.loadOrders();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildProfileInfo(),
                        const SizedBox(height: 24),
                        _buildStats(),
                        const SizedBox(height: 24),
                        _buildOrderHistory(),
                        const SizedBox(height: 24),
                        _buildSettings(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildHeader() {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final userName = profileProvider.profile?.nom ?? 'Utilisateur';
    final userRole =
        profileProvider.profile?.role ?? widget.role ?? 'Utilisateur';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Icon(
                    (userRole ?? '').toLowerCase() == 'producteur'
                        ? Icons.agriculture
                        : Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (userRole ?? '').toLowerCase() == 'producteur'
                            ? 'Producteur Agricole'
                            : 'Acheteur',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                  icon: Icon(
                    _isEditing ? Icons.close : Icons.edit,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final userRole =
        profileProvider.profile?.role?.toString().toUpperCase() ?? 'ACHETEUR';
    return Column(
      children: [
        Container(
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
              Text(
                'Informations personnelles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoField(
                icon: Icons.person,
                label: 'Nom complet',
                value: profileProvider.profile?.nom ?? 'Non renseigné',
                controller: _nameController,
                isEditing: _isEditing,
              ),
              const SizedBox(height: 16),
              _buildInfoField(
                icon: Icons.email,
                label: 'Email',
                value: profileProvider.profile?.email ?? 'Non renseigné',
                controller: _emailController,
                isEditing: _isEditing,
              ),
              const SizedBox(height: 16),
              _buildInfoField(
                icon: Icons.phone,
                label: 'Téléphone',
                value: profileProvider.profile?.telephone ?? 'Non renseigné',
                controller: _phoneController,
                isEditing: _isEditing,
              ),
              if (_isEditing) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Sauvegarder'),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (userRole == 'ACHETEUR')
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProducteurRequestScreen(),
                  ),
                );
              },
              icon: Icon(Icons.agriculture),
              label: Text('Devenir Producteur'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 4,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    required String value,
    required TextEditingController controller,
    required bool isEditing,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.green[600], size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              if (isEditing)
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                )
              else
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Consumer2<CartService, OrderService>(
      builder: (context, cartService, orderService, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.shopping_cart,
                  title: 'Articles',
                  value: '${cartService.cartItems.length}',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.receipt_long,
                  title: 'Commandes',
                  value: '${orderService.orders.length}',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.star,
                  title: 'Évaluations',
                  value: '4.8',
                  color: Colors.amber,
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
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildOrderHistory() {
    return Consumer<OrderService>(
      builder: (context, orderService, child) {
        final recentOrders = orderService.orders.take(3).toList();

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
                  Text(
                    'Commandes récentes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
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
                      recentOrders
                          .map((order) => _buildOrderItem(order))
                          .toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderItem(OrderModel order) {
    final status = order.statut ?? 'En cours';
    final total = order.total?.toString() ?? '0';
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
            child: Icon(statusIcon, color: statusColor, size: 20),
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
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

  Widget _buildSettings() {
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
          Text(
            'Paramètres',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Gérer les notifications',
            onTap: () {
              // Navigation vers les paramètres de notifications
            },
          ),
          _buildSettingItem(
            icon: Icons.security,
            title: 'Sécurité',
            subtitle: 'Changer le mot de passe',
            onTap: () {
              // Navigation vers la sécurité
            },
          ),
          _buildSettingItem(
            icon: Icons.help,
            title: 'Aide',
            subtitle: 'Centre d\'aide et support',
            onTap: () {
              // Navigation vers l'aide
            },
          ),
          _buildSettingItem(
            icon: Icons.info,
            title: 'À propos',
            subtitle: 'Version 1.0.0',
            onTap: () {
              // Afficher les informations de l'app
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // await authService.signOutDev();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Déconnexion dev désactivée')),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Se déconnecter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.green[600], size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}

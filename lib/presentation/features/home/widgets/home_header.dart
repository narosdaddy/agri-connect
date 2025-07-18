import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String userRole;
  final VoidCallback? onNotificationTap;
  const HomeHeader({
    super.key,
    required this.userName,
    required this.userRole,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
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
                    userRole == 'producteur'
                        ? Icons.agriculture
                        : Icons.shopping_basket,
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
                  onPressed: onNotificationTap,
                  icon: const Icon(Icons.notifications, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

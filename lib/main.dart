import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Services
import 'services/auth_service.dart';
import 'services/cart_service.dart';
import 'services/product_service.dart';
import 'services/order_service.dart';

// Routes
import 'routes.dart';

void main() {
  runApp(const AgriConnectApp());
}

class AgriConnectApp extends StatelessWidget {
  const AgriConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final authService = AuthService();
            // Initialiser les utilisateurs de test en mode développement
            // Appels à authService.initialize() et authService.createTestUsers() supprimés
            return authService;
          },
        ),
        ChangeNotifierProvider(create: (_) => CartService()..loadCart()),
        ChangeNotifierProvider(create: (_) => ProductService()..initializeProducts()),
        ChangeNotifierProvider(create: (_) => OrderService()),
      ],
      child: MaterialApp(
        title: 'AgriConnect Marketplace',
        theme: ThemeData(
          primarySwatch: MaterialColor(0xFF4CAF50, {
            50: Color(0xFFE8F5E8),
            100: Color(0xFFC8E6C9),
            200: Color(0xFFA5D6A7),
            300: Color(0xFF81C784),
            400: Color(0xFF66BB6A),
            500: Color(0xFF4CAF50),
            600: Color(0xFF43A047),
            700: Color(0xFF388E3C),
            800: Color(0xFF2E7D32),
            900: Color(0xFF1B5E20),
          }),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: Colors.grey[50],
        ),
        initialRoute: AppRoutes.welcome,
        onGenerateRoute: AppRoutes.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

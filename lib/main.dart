import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Services
import 'package:agri_marketplace/data/sources/auth_service.dart';
import 'package:agri_marketplace/data/sources/cart_service.dart';
import 'package:agri_marketplace/data/sources/product_service.dart';
import 'package:agri_marketplace/data/sources/order_service.dart';
import 'package:agri_marketplace/data/sources/profile_service.dart';
import 'package:dio/dio.dart';
// Ajout de l'import du provider
import 'package:agri_marketplace/presentation/features/auth/provider/auth_provider.dart';
import 'package:agri_marketplace/presentation/features/home/provider/profile_provider.dart';

// Routes
import 'package:agri_marketplace/presentation/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:agri_marketplace/core/network/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api/v1'));
  runApp(AgriConnectApp(dio: dio));
}

class AgriConnectApp extends StatelessWidget {
  final Dio dio;
  const AgriConnectApp({super.key, required this.dio});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService(dio))),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(ProfileService(dio)),
        ),
        Provider(create: (_) => CartService(dio)),
        Provider(create: (_) => ProductService(dio)),
        Provider(create: (_) => OrderService(dio)),
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

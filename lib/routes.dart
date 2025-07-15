import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/cart_page.dart';
import 'screens/profile_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/phone_auth_screen.dart';
import 'screens/producer_dashboard_screen.dart';
import 'screens/product_management_screen.dart';
import 'screens/sales_analytics_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String categories = '/categories';
  static const String cart = '/cart';
  static const String profile = '/profile';
  static const String addProduct = '/add-product';
  static const String productDetails = '/product-details';
  static const String orders = '/orders';
  static const String forgotPassword = '/forgot-password';
  static const String phoneAuth = '/phone-auth';
  static const String producerDashboard = '/producer-dashboard';
  static const String buyerDashboard = '/buyer-dashboard';
  static const String productManagement = '/product-management';
  static const String salesAnalytics = '/sales-analytics';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case categories:
        return MaterialPageRoute(builder: (_) => const CategoriesScreen());
      
      case cart:
        return MaterialPageRoute(builder: (_) => const CartPage());
      
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      
      case addProduct:
        return MaterialPageRoute(builder: (_) => const AddProductScreen());
      
      case productDetails:
        final product = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(product: product),
        );
      
      case orders:
        return MaterialPageRoute(builder: (_) => const OrdersTrackingScreen());
      
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      
      case phoneAuth:
        return MaterialPageRoute(builder: (_) => const PhoneAuthScreen());
      
      case producerDashboard:
        return MaterialPageRoute(builder: (_) => const ProducerDashboardScreen());
      
      case buyerDashboard:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case productManagement:
        return MaterialPageRoute(builder: (_) => const ProductManagementScreen());
      
      case salesAnalytics:
        return MaterialPageRoute(builder: (_) => const SalesAnalyticsScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} non trouvée'),
            ),
          ),
        );
    }
  }
} 
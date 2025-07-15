import 'dart:io';

class ApiConfig {
  // URLs de base selon l'environnement
  static const String _devUrl = 'http://localhost:8080'; // Local development
  static const String _androidEmulatorUrl = 'http://10.0.2.2:8080'; // Émulateur Android
  static const String _localNetworkUrl = 'http://192.200.200.20:8080'; // Réseau local
  static const String _iosUrl = 'http://localhost:8080'; // iOS Simulator
  static const String _prodUrl = 'https://api.agriconnect.com'; // Production
  
  // Mode de développement - mettre à false pour utiliser l'API
  static const bool devMode = false;
  
  // Type de test : 'auto', 'local', 'emulator', 'network'
  static const String testType = 'auto'; // Détection automatique
  
  // Obtenir l'URL de base selon la plateforme
  static String get baseUrl {
    if (testType == 'auto') {
      return _getAutoUrl();
    }
    
    switch (testType) {
      case 'emulator':
        return _androidEmulatorUrl;
      case 'network':
        return _localNetworkUrl;
      case 'local':
      default:
        return _devUrl;
    }
  }
  
  // Détection automatique de l'environnement
  static String _getAutoUrl() {
    try {
      if (Platform.isAndroid) {
        // Pour Android, on utilise l'émulateur par défaut
        // Si c'est un appareil physique, l'utilisateur peut changer manuellement
        return _androidEmulatorUrl;
      } else if (Platform.isIOS) {
        return _iosUrl;
      } else {
        // Web ou autre plateforme
        return _devUrl;
      }
    } catch (e) {
      // Fallback si la détection échoue
      return _devUrl;
    }
  }
  
  // Méthode pour forcer une URL spécifique (utile pour les tests)
  static String getUrlForEnvironment(String environment) {
    switch (environment.toLowerCase()) {
      case 'emulator':
        return _androidEmulatorUrl;
      case 'physical':
      case 'device':
        return _localNetworkUrl;
      case 'ios':
        return _iosUrl;
      case 'web':
        return _devUrl;
      default:
        return baseUrl;
    }
  }
  
  // Headers par défaut
  static Map<String, String> get defaultHeaders {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
  
  // Timeout pour les requêtes
  static const Duration timeout = Duration(seconds: 30);
  
  // Endpoints
  static const String authRegister = '/api/v1/auth/register';
  static const String authLogin = '/api/v1/auth/login';
  static const String authLogout = '/api/v1/auth/logout';
  static const String authRefresh = '/api/v1/auth/refresh';
  static const String authProfile = '/api/v1/auth/profile';
  static const String authHealth = '/api/v1/auth/health';
  static const String authVerify = '/auth/verify';
  static const String authResendVerification = '/auth/resend-verification';
  
  static const String produits = '/api/v1/produits';
  static const String produitsSearch = '/api/v1/produits/search';
  static const String produitsCategorie = '/api/v1/produits/categorie';
  static const String produitsProducteur = '/api/v1/produits/producteur';
  static const String produitsFeatured = '/api/v1/produits/featured';
  
  static const String panier = '/api/v1/panier';
  static const String panierElements = '/api/v1/panier/elements';
  static const String panierVider = '/api/v1/panier/vider';
  static const String panierPromo = '/api/v1/panier/promo';
  
  static const String commandes = '/api/v1/commandes';
  static const String commandesHistorique = '/api/v1/commandes/historique';
  static const String commandesAnalytics = '/api/v1/commandes/analytics';
  
  // Méthodes de paiement disponibles
  static const List<String> paymentMethods = [
    'CARTE_BANCAIRE',
    'MOBILE_MONEY',
    'VIREMENT_BANCAIRE',
    'ESPECES_LIVRAISON',
    'PAYPAL',
  ];
  
  // Catégories de produits
  static const List<String> productCategories = [
    'LEGUMES',
    'FRUITS',
    'CEREALES',
    'LEGUMINEUSES',
    'HERBES_AROMATIQUES',
    'PRODUITS_LAITIERS',
    'VIANDES',
    'OEUFS',
    'MIEL',
    'AUTRES',
  ];
  
  // Statuts de commande
  static const List<String> orderStatuses = [
    'EN_ATTENTE',
    'CONFIRMEE',
    'EN_PREPARATION',
    'EN_COURS',
    'LIVREE',
    'ANNULEE',
  ];
  
  // Codes de statut HTTP
  static const int ok = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int unprocessableEntity = 422;
  static const int internalServerError = 500;
} 
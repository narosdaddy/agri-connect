class ApiConfig {
  static const String baseUrl = 'http://localhost:8080/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String verifyEmail = '/auth/verify';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String phoneAuth = '/auth/phone';
  static const String resendVerificationEmail =
      '/auth/resend-verification-email';
  static const String sendOTP = '/auth/send-otp';
  static const String verifyOTP = '/auth/verify-otp';

  // Profile
  static const String profileMe = '/profil/me';
  static const String updateProfile = '/profil/me';
  static const String demandeEvolutionProducteur = '/profil/demande-evolution';

  // Notifications
  static const String notificationsMe = '/notifications/me';
  static const String notificationMarkAsRead = '/notifications/{id}/read';
  static const String notificationMarkAllAsRead = '/notifications/read-all';

  // Livraisons
  static const String livraisons = '/livraisons';
  static const String livraisonById = '/livraisons/{id}';
  static const String livraisonsByCommande =
      '/livraisons/commande/{commandeId}';
  static const String livraisonsByPartenaire =
      '/livraisons/partenaire/{partenaireId}';
  static const String livraisonUpdateStatus = '/livraisons/{id}';

  // Partenaires logistiques
  static const String partenairesLogistiques = '/partenaires-logistiques';
  static const String partenaireLogistiqueById =
      '/partenaires-logistiques/{id}';
  static const String partenaireLogistiqueActivate =
      '/partenaires-logistiques/{id}/activate';
  static const String partenaireLogistiqueDeactivate =
      '/partenaires-logistiques/{id}/deactivate';
  static const String partenaireLogistiqueDelete =
      '/partenaires-logistiques/{id}';

  // Ajoute ici les autres endpoints (produits, commandes, paiement, admin, etc.)

  // Products
  static const String products = '/products';
  static const String productById = '/products/{id}';
  static const String productCategories = '/products/categories';
  static const String searchProducts = '/products/search';
  static const String featuredProducts = '/products/featured';

  // Cart
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  static const String cartItemById = '/cart/items/{id}';
  static const String applyPromo = '/cart/apply-promo';

  // Orders
  static const String orders = '/orders';
  static const String orderById = '/orders/{id}';
  static const String orderStatus = '/orders/{id}/status';
  static const String orderAnalytics = '/orders/analytics';

  // Users
  static const String producers = '/users/producers';
  static const String producerById = '/users/producers/{id}';
  static const String usersMe = '/users/me';
}

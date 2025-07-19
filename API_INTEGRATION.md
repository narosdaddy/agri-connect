# 🔗 Intégration API Spring Boot - AgriConnect Marketplace

## 📋 Vue d'ensemble

Ce document explique comment connecter votre application Flutter AgriConnect Marketplace à l'API Spring Boot.

## 🚀 Configuration

### 1. URLs de l'API

Les URLs sont configurées dans `lib/config/api_config.dart` :

```dart
// Émulateur Android
static const String _devUrl = 'http://10.0.2.2:8080/api/v1';

// iOS Simulator  
static const String _iosUrl = 'http://localhost:8080/api/v1';

// Production
static const String _prodUrl = 'https://api.agriconnect.com/api/v1';
```

### 2. Mode de développement

Pour activer/désactiver le mode développement :

```dart
// Dans lib/config/api_config.dart
static const bool devMode = false; // Mettre à true pour le mode local
```

## 🔧 Services mis à jour

### AuthService (`lib/services/auth_service.dart`)

**Fonctionnalités :**
- ✅ Inscription avec validation
- ✅ Connexion avec JWT
- ✅ Gestion des tokens (access + refresh)
- ✅ Déconnexion
- ✅ Récupération du profil utilisateur
- ✅ Test de connexion API

**Endpoints utilisés :**
- `POST /auth/register` - Inscription
- `POST /auth/login` - Connexion
- `POST /auth/logout` - Déconnexion
- `POST /auth/refresh` - Rafraîchissement token
- `GET /auth/profile` - Profil utilisateur
- `GET /auth/health` - Test de santé

### ProductService (`lib/services/product_service.dart`)

**Fonctionnalités :**
- ✅ Chargement des produits avec pagination
- ✅ Recherche et filtres
- ✅ Tri par prix, note, date
- ✅ Filtre bio
- ✅ Gestion des catégories
- ✅ CRUD pour les producteurs

**Endpoints utilisés :**
- `GET /produits` - Liste des produits
- `GET /produits/{id}` - Détails d'un produit
- `GET /produits/search` - Recherche
- `GET /produits/categorie/{categorie}` - Par catégorie
- `GET /produits/producteur/{id}` - D'un producteur
- `POST /produits` - Créer un produit
- `PUT /produits/{id}` - Modifier un produit
- `DELETE /produits/{id}` - Supprimer un produit

### CartService (`lib/services/cart_service.dart`)

**Fonctionnalités :**
- ✅ Chargement du panier
- ✅ Ajout/suppression d'articles
- ✅ Modification des quantités
- ✅ Codes promo
- ✅ Calcul des totaux

**Endpoints utilisés :**
- `GET /panier` - Obtenir le panier
- `POST /panier/elements` - Ajouter au panier
- `PUT /panier/elements/{id}` - Modifier quantité
- `DELETE /panier/elements/{id}` - Supprimer du panier
- `DELETE /panier/vider` - Vider le panier
- `POST /panier/promo/{code}` - Appliquer code promo

### OrderService (`lib/services/order_service.dart`)

**Fonctionnalités :**
- ✅ Historique des commandes
- ✅ Création de commande
- ✅ Suivi des statuts
- ✅ Analytics (producteurs)

**Endpoints utilisés :**
- `GET /commandes/historique` - Historique
- `POST /commandes` - Créer une commande
- `GET /commandes/{id}` - Détails d'une commande
- `PUT /commandes/{id}/status` - Mettre à jour le statut
- `GET /commandes/analytics` - Analytics

## 🔐 Authentification

### Gestion des tokens

```dart
// Headers automatiques avec token
Map<String, String> headers = authService.getAuthHeaders();

// Headers retournés :
{
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer {accessToken}' // Si connecté
}
```

### Stockage sécurisé

Les tokens sont stockés dans `SharedPreferences` :
- `access_token` - Token d'accès (1h)
- `refresh_token` - Token de rafraîchissement (7j)
- `is_logged_in` - Statut de connexion

## 📱 Utilisation dans l'UI

### Exemple d'utilisation

```dart
// Dans un widget
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (authService.isLoading) {
          return CircularProgressIndicator();
        }
        
        return ElevatedButton(
          onPressed: () async {
            final success = await authService.signIn(email, password);
            if (success) {
              // Navigation vers l'écran principal
            }
          },
          child: Text('Se connecter'),
        );
      },
    );
  }
}
```

## 🛠️ Gestion des erreurs

### Codes de statut HTTP

```dart
// Dans ApiConfig
static const int ok = 200;
static const int created = 201;
static const int badRequest = 400;
static const int unauthorized = 401;
static const int forbidden = 403;
static const int notFound = 404;
static const int conflict = 409;
static const int unprocessableEntity = 422;
static const int internalServerError = 500;
```

### Messages d'erreur

Les services affichent automatiquement les messages d'erreur via `ScaffoldMessenger` :

```dart
// Exemple de gestion d'erreur
if (response.statusCode == ApiConfig.conflict) {
  showToast("Un compte avec cet email existe déjà");
} else if (response.statusCode == ApiConfig.badRequest) {
  final errorData = jsonDecode(response.body);
  showToast(errorData['message'] ?? "Données invalides");
}
```

## 🔄 Mode développement vs Production

### Mode développement (`devMode = true`)

- ✅ Données simulées en local
- ✅ Pas d'appels API
- ✅ Tests rapides
- ✅ Développement hors ligne

### Mode production (`devMode = false`)

- ✅ Appels API réels
- ✅ Authentification JWT
- ✅ Données persistantes
- ✅ Fonctionnalités complètes

## 🧪 Tests

### Test de connexion API

```dart
// Tester la connexion
final authService = AuthService();
final isConnected = await authService.testApiConnection();
print('API connectée: $isConnected');
```

### Logs de débogage

Les services affichent des logs détaillés :

```
Requête d'inscription : {nom: John, email: john@example.com, ...}
URL de l'API : http://10.0.2.2:8080/api/v1/auth/register
Réponse de l'API : 201
Corps de la réponse : {"accessToken": "...", "user": {...}}
```

## 📦 Dépendances requises

Assurez-vous d'avoir ces dépendances dans `pubspec.yaml` :

```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
  provider: ^6.1.1
```

## 🚀 Déploiement

### 1. Configuration de production

```dart
// Dans lib/config/api_config.dart
static String get baseUrl {
  // Détecter automatiquement la plateforme
  if (Platform.isAndroid) {
    return _devUrl; // ou _prodUrl
  } else if (Platform.isIOS) {
    return _iosUrl; // ou _prodUrl
  }
  return _prodUrl;
}
```

### 2. Variables d'environnement

Pour la production, utilisez des variables d'environnement :

```dart
// .env
API_BASE_URL=https://api.agriconnect.com/api/v1
API_TIMEOUT=30
```

## 🔧 Dépannage

### Problèmes courants

1. **Erreur de connexion**
   - Vérifiez que l'API Spring Boot est démarrée
   - Vérifiez l'URL dans `ApiConfig`
   - Testez avec `authService.testApiConnection()`

2. **Erreur CORS**
   - L'API doit accepter les requêtes depuis l'émulateur
   - Vérifiez la configuration CORS côté serveur

3. **Token expiré**
   - Le refresh automatique est géré
   - Vérifiez les logs pour les erreurs 401

4. **Données manquantes**
   - Vérifiez la structure des réponses API
   - Comparez avec la documentation Swagger

### Logs utiles

```dart
// Activer les logs détaillés
print('Headers: $headers');
print('URL: $uri');
print('Status: ${response.statusCode}');
print('Body: ${response.body}');
```

## 📚 Ressources

- [Documentation API Swagger](http://localhost:8080/api/v1/swagger-ui.html)
- [Spécification API complète](API_SPECIFICATION.md)
- [Guide de déploiement Spring Boot](../backend/README.md)

---

**Note :** Cette intégration est compatible avec l'API Spring Boot AgriConnect. Assurez-vous que l'API est démarrée et accessible avant de tester l'application Flutter. 
# API Specification - AgriConnect Marketplace

## Vue d'ensemble
API REST complète pour la marketplace agricole AgriConnect, développée en Spring Boot avec PostgreSQL.

## Technologies
- **Backend** : Spring Boot 3.2.x
- **Base de données** : PostgreSQL 15+
- **Authentification** : JWT + Spring Security
- **Documentation** : Swagger/OpenAPI 3
- **Validation** : Bean Validation
- **Tests** : JUnit 5 + Mockito

## Structure de l'API

### Base URL
```
http://localhost:8080/api/v1
```

### Endpoints d'Authentification
```
POST   /auth/register          # Inscription utilisateur
POST   /auth/login             # Connexion
POST   /auth/refresh           # Rafraîchir token
POST   /auth/logout            # Déconnexion
POST   /auth/forgot-password   # Demande réinitialisation
POST   /auth/reset-password    # Réinitialiser mot de passe
GET    /auth/verify-email      # Vérifier email
GET    /auth/profile           # Profil utilisateur
PUT    /auth/profile           # Modifier profil
```

### Endpoints Produits
```
GET    /products               # Liste des produits (avec filtres)
GET    /products/{id}          # Détails d'un produit
POST   /products               # Créer un produit (Producteur)
PUT    /products/{id}          # Modifier un produit (Producteur)
DELETE /products/{id}          # Supprimer un produit (Producteur)
GET    /products/categories    # Liste des catégories
GET    /products/search        # Recherche de produits
GET    /products/featured      # Produits en vedette
```

### Endpoints Panier
```
GET    /cart                   # Contenu du panier
POST   /cart/items             # Ajouter au panier
PUT    /cart/items/{id}        # Modifier quantité
DELETE /cart/items/{id}        # Retirer du panier
DELETE /cart                   # Vider le panier
POST   /cart/apply-promo       # Appliquer code promo
```

### Endpoints Commandes
```
GET    /orders                 # Liste des commandes
GET    /orders/{id}            # Détails d'une commande
POST   /orders                 # Créer une commande
PUT    /orders/{id}/status     # Modifier statut (Producteur)
GET    /orders/analytics       # Analytics des commandes (Producteur)
```

### Endpoints Utilisateurs
```
GET    /users/producers        # Liste des producteurs
GET    /users/producers/{id}   # Profil d'un producteur
GET    /users/me               # Mon profil
PUT    /users/me               # Modifier mon profil
```

## Modèles de Données

### User (Utilisateur)
```json
{
  "id": "uuid",
  "name": "string",
  "email": "string",
  "phone": "string",
  "role": "ACHETEUR|PRODUCTEUR",
  "isEmailVerified": "boolean",
  "isActive": "boolean",
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

### Product (Produit)
```json
{
  "id": "uuid",
  "name": "string",
  "description": "string",
  "price": "decimal",
  "unit": "string",
  "category": "string",
  "image": "string",
  "isOrganic": "boolean",
  "quantity": "integer",
  "producerId": "uuid",
  "producerName": "string",
  "rating": "decimal",
  "reviewCount": "integer",
  "tags": ["string"],
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

### Order (Commande)
```json
{
  "id": "uuid",
  "userId": "uuid",
  "items": [
    {
      "productId": "uuid",
      "productName": "string",
      "quantity": "integer",
      "unitPrice": "decimal",
      "totalPrice": "decimal"
    }
  ],
  "subtotal": "decimal",
  "deliveryFee": "decimal",
  "discount": "decimal",
  "total": "decimal",
  "status": "EN_COURS|CONFIRMEE|EN_PREPARATION|EN_LIVRAISON|LIVREE|ANNULEE",
  "deliveryAddress": "string",
  "notes": "string",
  "promoCode": "string",
  "orderDate": "datetime",
  "deliveryDate": "datetime",
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

### CartItem (Article Panier)
```json
{
  "id": "uuid",
  "userId": "uuid",
  "productId": "uuid",
  "productName": "string",
  "productImage": "string",
  "quantity": "integer",
  "unitPrice": "decimal",
  "totalPrice": "decimal",
  "addedAt": "datetime"
}
```

## Codes de Statut HTTP

- **200** : Succès
- **201** : Créé avec succès
- **400** : Données invalides
- **401** : Non authentifié
- **403** : Non autorisé
- **404** : Ressource non trouvée
- **409** : Conflit (ex: email déjà utilisé)
- **422** : Erreur de validation
- **500** : Erreur serveur

## Authentification JWT

### Structure du Token
```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "sub": "user_id",
    "email": "user@example.com",
    "role": "ACHETEUR|PRODUCTEUR",
    "iat": "timestamp",
    "exp": "timestamp"
  }
}
```

### Headers Requis
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

## Filtres et Pagination

### Produits
```
GET /api/v1/products?category=Fruits&minPrice=2&maxPrice=10&organic=true&sort=price_asc&page=0&size=20
```

### Commandes
```
GET /api/v1/orders?status=EN_COURS&startDate=2024-01-01&endDate=2024-12-31&page=0&size=10
```

## Gestion d'Erreurs

### Format d'Erreur Standard
```json
{
  "timestamp": "datetime",
  "status": "integer",
  "error": "string",
  "message": "string",
  "path": "string",
  "details": {
    "field": "error_message"
  }
}
```

## Sécurité

### CORS Configuration
```java
@Configuration
public class CorsConfig {
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(Arrays.asList("*"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        configuration.setAllowCredentials(true);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
```

### Validation des Données
- Bean Validation sur tous les DTOs
- Validation personnalisée pour les emails uniques
- Validation des rôles utilisateur
- Validation des prix et quantités

## Tests

### Tests Unitaires
- Services métier
- Contrôleurs
- Repositories
- Validation

### Tests d'Intégration
- Endpoints API
- Authentification
- Base de données

### Tests de Performance
- Tests de charge avec JMeter
- Tests de concurrence

## Déploiement

### Configuration
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/agriconnect
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: false
  security:
    jwt:
      secret: ${JWT_SECRET}
      expiration: 86400000 # 24h

server:
  port: 8080
  servlet:
    context-path: /api/v1
```

### Variables d'Environnement
```bash
DB_USERNAME=agriconnect_user
DB_PASSWORD=secure_password
JWT_SECRET=your_jwt_secret_key_here
```

## Migration depuis l'App Flutter

### Étapes de Migration
1. **Désactiver le mode dev** dans `AuthService`
2. **Mettre à jour les URLs** vers l'API
3. **Adapter les modèles** pour correspondre à l'API
4. **Gérer les tokens JWT** dans les requêtes
5. **Tester tous les endpoints**

### Modifications Flutter Requises
```dart
// Dans AuthService
bool _devMode = false; // Passer en mode production

// Mettre à jour les URLs
final String baseUrl = 'http://your-api-domain.com/api/v1/auth';

// Ajouter les headers JWT
headers: {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $token',
}
```

## Monitoring et Logs

### Logs Structurés
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "INFO",
  "logger": "com.agriconnect.controller.ProductController",
  "message": "Product created successfully",
  "userId": "uuid",
  "productId": "uuid",
  "requestId": "uuid"
}
```

### Métriques
- Nombre de requêtes par minute
- Temps de réponse moyen
- Taux d'erreur
- Utilisation de la base de données

Cette API fournit une base solide et évolutive pour votre marketplace agricole, avec toutes les fonctionnalités nécessaires pour remplacer le mode développement actuel. 
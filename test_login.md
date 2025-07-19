# Test de Connexion - Mode Développement

## Utilisateurs de Test Disponibles

### Acheteur
- **Email:** acheteur@test.com
- **Mot de passe:** password123
- **Rôle:** ACHETEUR
- **Redirection:** Page d'accueil (HomeScreen)

### Producteur
- **Email:** producteur@test.com
- **Mot de passe:** password123
- **Rôle:** PRODUCTEUR
- **Redirection:** Dashboard producteur (ProducerDashboardScreen)

## Fonctionnalités Testées

✅ **Mode développement activé** (ApiConfig.devMode = true)
✅ **Validation d'email** avec regex
✅ **Connexion simulée** avec délai de 2 secondes
✅ **Gestion des rôles** (acheteur/producteur)
✅ **Navigation automatique** selon le rôle
✅ **Messages de succès/erreur** avec SnackBar
✅ **Utilisateurs de test** créés automatiquement au démarrage

## Comment Tester

1. Lancez l'application
2. Allez sur l'écran de connexion
3. Utilisez l'un des identifiants ci-dessus
4. Vérifiez que la redirection fonctionne selon le rôle

## Messages d'Erreur

Si vous utilisez de mauvais identifiants, vous verrez :
```
Identifiants invalides. Utilisez:
acheteur@test.com / password123 (Acheteur)
producteur@test.com / password123 (Producteur)
``` 
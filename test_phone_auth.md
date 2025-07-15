# Test d'Authentification par Téléphone - Mode Développement

## Fonctionnalités Testées

✅ **Mode développement activé** (ApiConfig.devMode = true)
✅ **Validation du numéro de téléphone** avec regex
✅ **Génération d'OTP simulée** (6 chiffres)
✅ **Affichage de l'OTP** dans une boîte de dialogue pour les tests
✅ **Vérification d'OTP** avec validation
✅ **Sauvegarde locale** des données utilisateur
✅ **Navigation automatique** vers HomeScreen
✅ **Gestion des erreurs** et messages informatifs

## Comment Tester l'Authentification par Téléphone

### 1. Test Complet
1. Allez sur l'écran d'authentification par téléphone
2. Entrez un numéro de téléphone valide :
   - **Format :** +22812345678
   - **Exemple :** +22890123456
3. Cliquez sur "Envoyer le code"
4. **Résultat attendu :** 
   - Délai de 2 secondes
   - Boîte de dialogue avec l'OTP généré
   - Message "Code OTP envoyé!"
5. Notez l'OTP affiché (ex: 123456)
6. Entrez l'OTP dans le champ de saisie
7. Cliquez sur "Vérifier le code"
8. **Résultat attendu :** Redirection vers HomeScreen

### 2. Test de Validation
- **Numéro invalide :** +123 (trop court)
- **Format invalide :** 123456789 (sans +)
- **Champ vide :** Laissez vide et cliquez "Envoyer le code"

### 3. Test d'OTP Incorrect
- Entrez un OTP différent de celui généré
- **Résultat attendu :** Message "Code OTP incorrect. Réessayez."

## Messages d'Erreur Possibles

- **"Veuillez entrer votre numéro de téléphone"** - Si le champ est vide
- **"Format invalide. Utilisez: +22812345678"** - Si le format est incorrect
- **"Veuillez entrer le code OTP"** - Si l'OTP est vide
- **"Code OTP incorrect. Réessayez."** - Si l'OTP est faux

## Données Sauvegardées

Après authentification réussie, les données suivantes sont sauvegardées :
- **Téléphone :** Le numéro saisi
- **Nom :** "Utilisateur Téléphone"
- **Email :** "{téléphone}@phone.auth"
- **Rôle :** "ACHETEUR" (par défaut)
- **Statut :** Connecté

## Validation du Numéro de Téléphone

Le système valide :
- ✅ Format international (+22812345678)
- ✅ Longueur minimale (3 chiffres après le +)
- ✅ Longueur maximale (15 chiffres au total)
- ✅ Commence par + suivi d'un chiffre 1-9

## OTP de Test

En mode développement :
- **Longueur :** 6 chiffres
- **Génération :** Basée sur le timestamp actuel
- **Affichage :** Dans une boîte de dialogue
- **Validité :** Unique par session

## Navigation

Après authentification réussie :
- **Destination :** HomeScreen
- **Méthode :** pushNamedAndRemoveUntil
- **Effet :** Supprime toutes les routes précédentes 
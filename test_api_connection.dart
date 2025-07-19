import 'dart:io';
import 'dart:convert';

void main() async {
  print('Test de connexion à l\'API AgriConnect...');
  
  // URLs à tester selon l'environnement
  final urls = [
    'http://10.0.2.2:8080/api/v1/auth/register', // Émulateur Android
    'http://192.200.200.20:8080/api/v1/auth/register', // Appareil physique
    'http://localhost:8080/api/v1/auth/register', // Local/iOS
  ];
  
  for (String url in urls) {
    print('\n=== Test de: $url ===');
    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse(url));
      
      // Headers
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');
      request.headers.set('User-Agent', 'Flutter-App');
      
      // Données de test pour l'inscription
      final testData = {
        'nom': 'Test User',
        'email': 'test${DateTime.now().millisecondsSinceEpoch}@example.com',
        'motDePasse': 'password123',
        'role': 'ACHETEUR',
        'telephone': '123456789'
      };
      
      final jsonData = jsonEncode(testData);
      request.write(jsonData);
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('Status Code: ${response.statusCode}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ CONNEXION RÉUSSIE avec cette URL!');
        print('URL fonctionnelle: $url');
        break;
      } else if (response.statusCode == 409) {
        print('⚠️ Utilisateur existe déjà (normal pour un test)');
        print('URL fonctionnelle: $url');
        break;
      } else {
        print('❌ Échec - Status: ${response.statusCode}');
        print('Réponse: ${responseBody.substring(0, responseBody.length > 100 ? 100 : responseBody.length)}...');
      }
      
    } catch (e) {
      print('❌ Erreur de connexion: $e');
    }
  }
  
  print('\n=== RÉSUMÉ ===');
  print('Si aucune URL n\'a fonctionné, vérifiez:');
  print('1. Que votre API Spring Boot est bien démarrée');
  print('2. Que vous utilisez la bonne URL selon votre environnement Flutter');
  print('3. Que votre pare-feu n\'empêche pas la connexion');
} 
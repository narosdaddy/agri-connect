import 'dart:io';
import 'dart:convert';

void main() async {
  print('Test des endpoints disponibles sur l\'API...');
  
  final baseUrl = 'http://localhost:8080/api/v1';
  final endpoints = [
    '/auth/register',
    '/auth/login',
    '/auth/health',
    '/produits',
    '/actuator/health',
    '/swagger-ui/index.html',
    '/v3/api-docs',
  ];
  
  for (String endpoint in endpoints) {
    final url = '$baseUrl$endpoint';
    print('\n=== Test de: $url ===');
    
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set('Accept', 'application/json');
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('Status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Endpoint disponible!');
      } else if (response.statusCode == 404) {
        print('❌ Endpoint non trouvé');
      } else if (response.statusCode == 403) {
        print('⚠️ Endpoint protégé (nécessite authentification)');
      } else {
        print('⚠️ Status inattendu: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Erreur: $e');
    }
  }
  
  print('\n=== RÉSUMÉ ===');
  print('Si aucun endpoint ne fonctionne, vérifiez:');
  print('1. Que votre API Spring Boot est bien démarrée sur le port 8080');
  print('2. Que le contexte de l\'application est bien /api/v1');
  print('3. Que les contrôleurs sont bien configurés');
} 
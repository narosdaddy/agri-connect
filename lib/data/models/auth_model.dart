/// Modèle de réponse d'authentification
class AuthResponse {
  final String? id; // ID de l'utilisateur
  final String? nom; // Nom de l'utilisateur
  final String? email; // Email de l'utilisateur
  final String? telephone; // Numéro de téléphone
  final String? role; // Rôle de l'utilisateur
  final String? token; // Token JWT d'accès
  final String? refreshToken; // Token de rafraîchissement
  final String? type; // Type de token (ex: Bearer)
  final bool? emailVerifie; // Email vérifié ou non
  final String? adresse; // Adresse de l'utilisateur
  final String? ville; // Ville de l'utilisateur
  final String? codePostal; // Code postal
  final String? pays; // Pays de l'utilisateur
  final String? avatar; // URL de l'avatar
  final String? nomExploitation; // Nom de l'exploitation agricole
  final String? descriptionExploitation; // Description de l'exploitation
  final bool? certifieBio; // Exploitation certifiée bio
  final bool? verifie; // Producteur vérifié

  AuthResponse({
    this.id,
    this.nom,
    this.email,
    this.telephone,
    this.role,
    this.token,
    this.refreshToken,
    this.type,
    this.emailVerifie,
    this.adresse,
    this.ville,
    this.codePostal,
    this.pays,
    this.avatar,
    this.nomExploitation,
    this.descriptionExploitation,
    this.certifieBio,
    this.verifie,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        id: json['id'] as String?,
        nom: json['nom'] as String?,
        email: json['email'] as String?,
        telephone: json['telephone'] as String?,
        role: json['role'] as String?,
        token: json['token'] as String?,
        refreshToken: json['refreshToken'] as String?,
        type: json['type'] as String?,
        emailVerifie: json['emailVerifie'] as bool?,
        adresse: json['adresse'] as String?,
        ville: json['ville'] as String?,
        codePostal: json['codePostal'] as String?,
        pays: json['pays'] as String?,
        avatar: json['avatar'] as String?,
        nomExploitation: json['nomExploitation'] as String?,
        descriptionExploitation: json['descriptionExploitation'] as String?,
        certifieBio: json['certifieBio'] as bool?,
        verifie: json['verifie'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'email': email,
        'telephone': telephone,
        'role': role,
        'token': token,
        'refreshToken': refreshToken,
        'type': type,
        'emailVerifie': emailVerifie,
        'adresse': adresse,
        'ville': ville,
        'codePostal': codePostal,
        'pays': pays,
        'avatar': avatar,
        'nomExploitation': nomExploitation,
        'descriptionExploitation': descriptionExploitation,
        'certifieBio': certifieBio,
        'verifie': verifie,
      };
}

/// Modèle pour la demande de vérification d'email
class EmailVerificationRequest {
  final String code; // Code de vérification à 6 chiffres

  EmailVerificationRequest({required this.code});

  factory EmailVerificationRequest.fromJson(Map<String, dynamic> json) =>
      EmailVerificationRequest(
        code: json['code'] as String,
      );

  Map<String, dynamic> toJson() => {
        'code': code,
      };
}

/// Modèle pour la demande de connexion (login)
class LoginRequest {
  final String email; // Email de l'utilisateur
  final String motDePasse; // Mot de passe

  LoginRequest({required this.email, required this.motDePasse});

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
        email: json['email'] as String,
        motDePasse: json['motDePasse'] as String,
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'motDePasse': motDePasse,
      };
}

/// Modèle pour la demande d'inscription (register)
class RegisterRequest {
  final String nom; // Nom complet de l'utilisateur
  final String email; // Email de l'utilisateur
  final String telephone; // Numéro de téléphone
  final String motDePasse; // Mot de passe

  RegisterRequest({
    required this.nom,
    required this.email,
    required this.telephone,
    required this.motDePasse,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => RegisterRequest(
        nom: json['nom'] as String,
        email: json['email'] as String,
        telephone: json['telephone'] as String,
        motDePasse: json['motDePasse'] as String,
      );

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'email': email,
        'telephone': telephone,
        'motDePasse': motDePasse,
      };
}

/// Modèle pour la demande d'évolution vers producteur
class EvolutionProducteurRequest {
  final String nomExploitation; // Nom de l'exploitation
  final String descriptionExploitation; // Description de l'exploitation
  final String adresseExploitation; // Adresse de l'exploitation
  final String telephoneExploitation; // Téléphone de l'exploitation
  final dynamic identityFile;
  final dynamic addressFile;
  final dynamic bioFile;
  final List<dynamic> otherFiles;

  EvolutionProducteurRequest({
    required this.nomExploitation,
    required this.descriptionExploitation,
    required this.adresseExploitation,
    required this.telephoneExploitation,
    this.identityFile,
    this.addressFile,
    this.bioFile,
    this.otherFiles = const [],
  });

  factory EvolutionProducteurRequest.fromJson(Map<String, dynamic> json) =>
      EvolutionProducteurRequest(
        nomExploitation: json['nomExploitation'] as String,
        descriptionExploitation: json['descriptionExploitation'] as String,
        adresseExploitation: json['adresseExploitation'] as String,
        telephoneExploitation: json['telephoneExploitation'] as String,
      );

  Map<String, dynamic> toJson() => {
        'nomExploitation': nomExploitation,
        'descriptionExploitation': descriptionExploitation,
        'adresseExploitation': adresseExploitation,
        'telephoneExploitation': telephoneExploitation,
        'identityFile': identityFile,
        'addressFile': addressFile,
        'bioFile': bioFile,
        'otherFiles': otherFiles,
      };
}
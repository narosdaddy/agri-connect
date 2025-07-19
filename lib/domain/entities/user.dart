class User {
  final String id;
  final String nom;
  final String email;
  final String? telephone;
  final String? role;
  final String? token;
  final String? refreshToken;
  final String? type;
  final bool? emailVerifie;
  final String? adresse;
  final String? ville;
  final String? codePostal;
  final String? pays;
  final String? avatar;
  final String? nomExploitation;
  final String? descriptionExploitation;
  final bool? certifieBio;
  final bool? verifie;

  const User({
    required this.id,
    required this.nom,
    required this.email,
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
}

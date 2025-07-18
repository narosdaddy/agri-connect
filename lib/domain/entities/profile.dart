class Profile {
  final String id;
  final String nom;
  final String email;
  final String? role;
  final String? telephone;

  const Profile({
    required this.id,
    required this.nom,
    required this.email,
    this.role,
    this.telephone,
  });
}

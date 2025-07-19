import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  final String? telephone;
  const ProfileModel({
    required String id,
    required String nom,
    required String email,
    String? role,
    this.telephone,
  }) : super(id: id, nom: nom, email: email, role: role);

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id: json['id'] as String,
    nom: json['nom'] as String,
    email: json['email'] as String,
    role: json['role'] as String?,
    telephone: json['telephone'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'email': email,
    'role': role,
    'telephone': telephone,
  };
}

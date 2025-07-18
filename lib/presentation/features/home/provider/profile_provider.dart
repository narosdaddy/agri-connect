import 'package:flutter/material.dart';
import 'package:agri_marketplace/data/sources/profile_service.dart';
import 'package:agri_marketplace/data/models/profile_model.dart';
import 'package:agri_marketplace/data/models/auth_model.dart';
import 'package:agri_marketplace/data/models/user_model.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService;
  ProfileModel? _profile;
  bool _isLoading = false;
  String? _error;

  ProfileProvider(this._profileService);

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Récupère le profil utilisateur depuis l'API et met à jour l'état local
  Future<ProfileModel?> fetchMyProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final profile = await _profileService.getProfile();
      _profile = profile;
      _isLoading = false;
      notifyListeners();
      return profile;
    } catch (e) {
      _error = "Erreur lors de la récupération du profil";
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Demande d'évolution vers producteur
  Future<bool> demandeEvolutionProducteur(
    EvolutionProducteurRequest request,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _profileService.demandeEvolutionProducteur(request.toJson());
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = "Erreur lors de la demande d'évolution producteur";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Met à jour localement le profil (ex: après édition)
  void updateProfileLocal(ProfileModel profile) {
    _profile = profile;
    notifyListeners();
  }

  /// Réinitialise le profil (ex: lors de la déconnexion)
  void clearProfile() {
    _profile = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}

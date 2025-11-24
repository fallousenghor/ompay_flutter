// lib/models/auth/user_models.dart

// Modèles supplémentaires pour le profil utilisateur
class UpdateProfileRequest {
  final String? prenom;
  final String? nom;
  final String? email;
  final String codePin;

  UpdateProfileRequest({
    this.prenom,
    this.nom,
    this.email,
    required this.codePin,
  });

  Map<String, dynamic> toJson() {
    return {
      if (prenom != null) 'prenom': prenom,
      if (nom != null) 'nom': nom,
      if (email != null) 'email': email,
      'codePin': codePin,
    };
  }
}

class ChangePinRequest {
  final String ancienPin;
  final String nouveauPin;

  ChangePinRequest({
    required this.ancienPin,
    required this.nouveauPin,
  });

  Map<String, dynamic> toJson() {
    return {
      'ancienPin': ancienPin,
      'nouveauPin': nouveauPin,
    };
  }
}

class ActivateBiometricsRequest {
  final String codePin;
  final String jetonBiometrique;

  ActivateBiometricsRequest({
    required this.codePin,
    required this.jetonBiometrique,
  });

  Map<String, dynamic> toJson() {
    return {
      'codePin': codePin,
      'jetonBiometrique': jetonBiometrique,
    };
  }
}

// Response models for UserService
class UpdateProfileResponse {
  final String idUtilisateur;
  final String prenom;
  final String nom;
  final String email;
  final String message;

  UpdateProfileResponse({
    required this.idUtilisateur,
    required this.prenom,
    required this.nom,
    required this.email,
    required this.message,
  });

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
      idUtilisateur: json['idUtilisateur'] as String,
      prenom: json['prenom'] as String,
      nom: json['nom'] as String,
      email: json['email'] as String,
      message: json['message'] as String,
    );
  }
}

class ChangePinResponse {
  final String message;

  ChangePinResponse({required this.message});

  factory ChangePinResponse.fromJson(Map<String, dynamic> json) {
    return ChangePinResponse(
      message: json['message'] as String,
    );
  }
}

class ActivateBiometricsResponse {
  final String message;

  ActivateBiometricsResponse({required this.message});

  factory ActivateBiometricsResponse.fromJson(Map<String, dynamic> json) {
    return ActivateBiometricsResponse(
      message: json['message'] as String,
    );
  }
}

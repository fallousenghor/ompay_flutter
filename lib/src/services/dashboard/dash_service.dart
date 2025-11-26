// lib/services/dashboard_service.dart

import 'package:flutter_app/src/models/auth_models/user.dart';
import 'package:flutter_app/src/models/dashboard.dart';
import 'package:flutter_app/src/services/services.dart';

class DashboardService {
  final HttpService _httpService;

  DashboardService(this._httpService);

  Future<ApiResponse<DashboardResponse>> getDashboard() async {
    return _httpService.get<DashboardResponse>(
      '/dashboard',
      requiresAuth: true,
      fromJson: (data) =>
          DashboardResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<User>> getUserProfile(String accountNumber) async {
    return _httpService.get<User>(
      '/$accountNumber/user',
      requiresAuth: true,
      fromJson: (data) => User.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> updateProfile(
    String accountNumber,
    UpdateProfileRequest request,
  ) async {
    return _httpService.put<void>(
      '/$accountNumber/profil',
      request.toJson(),
      requiresAuth: true,
    );
  }

  Future<ApiResponse<void>> changePin(
    String accountNumber,
    ChangePinRequest request,
  ) async {
    return _httpService.post<void>(
      '/$accountNumber/profil/changer-pin',
      request.toJson(),
      requiresAuth: true,
    );
  }

  Future<ApiResponse<void>> activateBiometrics(
    String accountNumber,
    ActivateBiometricsRequest request,
  ) async {
    return _httpService.post<void>(
      '/$accountNumber/profil/activer-biometrie',
      request.toJson(),
      requiresAuth: true,
    );
  }
}

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

// lib/services/auth/user_service.dart

import 'package:flutter_app/src/models/auth_models/user.dart';
import 'package:flutter_app/src/models/auth_models/user_models.dart';
import 'package:flutter_app/src/models/dashboard.dart';
import 'package:flutter_app/src/services/services.dart';

class UserService {
  final HttpService _httpService;

  UserService(this._httpService);

  Future<ApiResponse<DashboardResponse>> getDashboard() async {
    return _httpService.get<DashboardResponse>(
      '/dashboard',
      requiresAuth: true,
      fromJson: (data) =>
          DashboardResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<User>> getUserProfile() async {
    try {
      final response = await _httpService.get<Map<String, dynamic>>(
        '/utilisateur/profil',
        requiresAuth: true,
        fromJson: (m) => m,
      );

      if (response.success && response.data != null) {
        final userData = response.data as Map<String, dynamic>;
        return ApiResponse<User>(
          success: true,
          data: User.fromJson(userData),
        );
      }

      return ApiResponse<User>(
        success: false,
        message: response.message ?? 'Erreur lors de la récupération du profil',
      );
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Erreur réseau: $e',
      );
    }
  }

  Future<ApiResponse<UpdateProfileResponse>> updateProfile(
    String accountNumber,
    UpdateProfileRequest request,
  ) async {
    final response = await _httpService.put<Map<String, dynamic>>(
      '/$accountNumber/profil',
      request.toJson(),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return ApiResponse<UpdateProfileResponse>(
        success: true,
        data: UpdateProfileResponse.fromJson(response.data!),
      );
    }

    return ApiResponse<UpdateProfileResponse>(
      success: false,
      message: response.message ?? 'Erreur lors de la mise à jour du profil',
    );
  }

  Future<ApiResponse<ChangePinResponse>> changePin(
    String accountNumber,
    ChangePinRequest request,
  ) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '/$accountNumber/profil/changer-pin',
      request.toJson(),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return ApiResponse<ChangePinResponse>(
        success: true,
        data: ChangePinResponse.fromJson(response.data!),
      );
    }

    return ApiResponse<ChangePinResponse>(
      success: false,
      message: response.message ?? 'Erreur lors du changement de PIN',
    );
  }

  Future<ApiResponse<ActivateBiometricsResponse>> activateBiometrics(
    String accountNumber,
    ActivateBiometricsRequest request,
  ) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '/$accountNumber/profil/activer-biometrie',
      request.toJson(),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return ApiResponse<ActivateBiometricsResponse>(
        success: true,
        data: ActivateBiometricsResponse.fromJson(response.data!),
      );
    }

    return ApiResponse<ActivateBiometricsResponse>(
      success: false,
      message:
          response.message ?? 'Erreur lors de l\'activation de la biométrie',
    );
  }
}

// lib/services/auth/auth_service.dart

import 'package:flutter_app/src/models/auth_models/auth_models.dart';
import 'package:flutter_app/src/services/services.dart';

class AuthService {
  final HttpService _httpService;

  AuthService(this._httpService);

  // 1.1 Initier la connexion (envoyer OTP)
  Future<ApiResponse<InitiateLoginResponse>> initiateLogin(
      InitiateLoginRequest request) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '/auth/initiate',
      request.toJson(),
    );

    if (response.success && response.data != null) {
      return ApiResponse<InitiateLoginResponse>(
        success: true,
        data: InitiateLoginResponse.fromJson(response.data!),
      );
    }

    return ApiResponse<InitiateLoginResponse>(
      success: false,
      message:
          response.message ?? 'Erreur lors de l\'initiation de la connexion',
    );
  }

  // 1.2 Vérifier le code OTP
  Future<ApiResponse<VerifyOtpResponse>> verifyOtp(
      VerifyOtpRequest request) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '/auth/verify-otp',
      request.toJson(),
    );

    if (response.success && response.data != null) {
      return ApiResponse<VerifyOtpResponse>(
        success: true,
        data: VerifyOtpResponse.fromJson(response.data!),
      );
    }

    return ApiResponse<VerifyOtpResponse>(
      success: false,
      message: response.message ?? 'Erreur lors de la vérification du code',
    );
  }

  // 1.4 Se connecter avec code PIN
  Future<ApiResponse<LoginResponse>> login(LoginRequest request) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '/auth/login',
      request.toJson(),
    );

    if (response.success && response.data != null) {
      final loginResponse = LoginResponse.fromJson(response.data!);

      // Sauvegarder le token d'authentification
      if (loginResponse.sessionToken != null) {
        _httpService.setAuthToken(loginResponse.sessionToken!);
      }

      return ApiResponse<LoginResponse>(
        success: true,
        data: loginResponse,
      );
    }

    return ApiResponse<LoginResponse>(
      success: false,
      message: response.message ?? 'Erreur lors de la connexion',
    );
  }

  // 1.5 Se déconnecter
  Future<ApiResponse<Map<String, dynamic>>> logout() async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '/auth/logout',
      {},
      requiresAuth: true,
    );

    // Effacer le token même en cas d'erreur
    _httpService.clearAuthToken();

    return response;
  }
}

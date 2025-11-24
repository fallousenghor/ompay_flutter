// lib/services/auth/auth_service.dart

import 'package:flutter_app/src/models/auth_models/auth_models.dart';
import 'package:flutter_app/src/services/services.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final HttpService _httpService;

  AuthService(this._httpService);

  // 1.1 Initier la connexion (envoyer OTP)
  Future<ApiResponse<InitiateLoginResponse>> initiateLogin(
      InitiateLoginRequest request) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '/auth/initiate',
      request.toJson(),
      fromJson: (m) => m,
    );

    if (response.success) {
      // response.data contains the inner 'data' map (fromJson returned it as-is)
      final dataMap = response.data as Map<String, dynamic>?;
      final initiated = InitiateLoginResponse(
        message: response.message ?? '',
        code: dataMap?['code_otp'] as String?,
        lien: dataMap?['lien'] as String?,
        token: dataMap?['token'] as String?,
      );

      return ApiResponse<InitiateLoginResponse>(
        success: true,
        data: initiated,
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
      fromJson: (m) => m,
    );

    if (response.success) {
      final dataMap = response.data as Map<String, dynamic>?;
      if (dataMap != null) {
        // Use the model's fromJson to build the response object
        final verify = VerifyOtpResponse.fromJson(dataMap);
        return ApiResponse<VerifyOtpResponse>(
          success: true,
          data: verify,
        );
      }
    }

    // Debug output to help diagnostics: show what the server actually returned
    debugPrint(
        'verifyOtp response: success=${response.success} message=${response.message} data=${response.data}');

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
      // Sauvegarder le token d'authentification
      _httpService.setAuthToken(loginResponse.sessionToken);

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

  // 1.3 Créer un compte après vérification OTP (enregistrer code PIN)
  Future<ApiResponse<CreateAccountResponse>> createAccount(
      CreateAccountRequest request) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '/auth/create-account',
      request.toJson(),
      fromJson: (m) => m,
    );

    if (response.success && response.data != null) {
      final dataMap = response.data as Map<String, dynamic>?;
      if (dataMap != null) {
        final created = CreateAccountResponse.fromJson(dataMap);
        return ApiResponse<CreateAccountResponse>(
          success: true,
          data: created,
        );
      }
    }

    return ApiResponse<CreateAccountResponse>(
      success: false,
      message: response.message ?? 'Erreur lors de la création du compte',
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

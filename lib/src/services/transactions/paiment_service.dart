// lib/services/transactions/paiement_service.dart

import 'package:flutter_app/src/models/transaction_mdels/transaction_models.dart';
import 'package:flutter_app/src/services/services.dart';

class PaiementService {
  final HttpService _httpService;

  PaiementService(this._httpService);

  // Scanner un QR Code
  Future<ApiResponse<ScannerQrResponse>> scannerQRCode(String donneesQR) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '/paiements/scanner-qr',
      {'donneesQR': donneesQR},
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return ApiResponse<ScannerQrResponse>(
        success: true,
        data: ScannerQrResponse.fromJson(response.data!),
      );
    }

    return ApiResponse<ScannerQrResponse>(
      success: false,
      message: response.message ?? 'Erreur lors du scan du QR code',
    );
  }

  // Saisir un code de paiement
  Future<ApiResponse<SaisirCodeResponse>> saisirCodePaiement(
      String code) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '/paiements/saisir-code',
      {'code': code},
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return ApiResponse<SaisirCodeResponse>(
        success: true,
        data: SaisirCodeResponse.fromJson(response.data!),
      );
    }

    return ApiResponse<SaisirCodeResponse>(
      success: false,
      message: response.message ?? 'Erreur lors de la saisie du code',
    );
  }

  // Initier un paiement
  Future<ApiResponse<InitierPaiementResponse>> initierPaiement(
      InitiatePaiementRequest request) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '/paiements/initier',
      request.toJson(),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return ApiResponse<InitierPaiementResponse>(
        success: true,
        data: InitierPaiementResponse.fromJson(response.data!),
      );
    }

    return ApiResponse<InitierPaiementResponse>(
      success: false,
      message: response.message ?? 'Erreur lors de l\'initiation du paiement',
    );
  }

  // Confirmer un paiement
  Future<ApiResponse<ConfirmerPaiementResponse>> confirmerPaiement(
      String idPaiement, String codePin) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '/paiements/confirmer/$idPaiement',
      {'codePin': codePin},
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return ApiResponse<ConfirmerPaiementResponse>(
        success: true,
        data: ConfirmerPaiementResponse.fromJson(response.data!),
      );
    }

    return ApiResponse<ConfirmerPaiementResponse>(
      success: false,
      message: response.message ?? 'Erreur lors de la confirmation du paiement',
    );
  }

  // Annuler un paiement
  Future<ApiResponse<Map<String, dynamic>>> annulerPaiement(
      String idPaiement) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '/paiements/annuler/$idPaiement',
      {},
      requiresAuth: true,
    );

    return response;
  }
}

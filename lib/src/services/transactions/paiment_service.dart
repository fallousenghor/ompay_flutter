// lib/services/transactions/paiement_service.dart

import 'package:flutter_app/src/models/transaction_mdels/transaction_models.dart';
import 'package:flutter_app/src/services/services.dart';

class PaiementService {
  final HttpService _httpService;

  PaiementService(this._httpService);

  // Scanner un QR Code
  Future<ApiResponse<ScannerQrResponse>> scannerQRCode(
      String donneesQR, String numeroCompte) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '/$numeroCompte/paiement/scanner-qr',
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
  Future<ApiResponse<Map<String, dynamic>>> saisirCodePaiement(
      String code, double montant, String numeroCompte) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '/$numeroCompte/paiement/saisir-code',
      {'code': code, 'montant': montant},
      requiresAuth: true,
      fullResponse: true,
    );

    return ApiResponse<Map<String, dynamic>>(
      success: response.success,
      message: response.message,
      data: response.data?['data'] as Map<String, dynamic>?,
    );
  }

  // Saisir un numéro de téléphone pour paiement
  Future<ApiResponse<Map<String, dynamic>>> saisirNumeroTelephone(
      String numeroTelephone, double montant, String numeroCompte) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '/$numeroCompte/paiement/saisir-numero-telephone',
      {'numeroTelephone': numeroTelephone, 'montant': montant},
      requiresAuth: true,
      fullResponse: true,
    );

    return ApiResponse<Map<String, dynamic>>(
      success: response.success,
      message: response.message,
      data: response.data?['data'] as Map<String, dynamic>?,
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
      String idPaiement, String codePin, String numeroCompte) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '/$numeroCompte/paiement/$idPaiement/confirmer',
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
      String idPaiement, String numeroCompte) async {
    final response = await _httpService.delete<Map<String, dynamic>>(
      '/$numeroCompte/paiement/$idPaiement',
      requiresAuth: true,
    );

    return response;
  }
}

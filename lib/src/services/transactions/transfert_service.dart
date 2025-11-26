// lib/services/transactions/transfert_service.dart

import 'package:flutter_app/src/models/transaction_mdels/transaction_models.dart';
import 'package:flutter_app/src/services/services.dart';

class TransfertService {
  final HttpService _httpService;

  TransfertService(this._httpService);

  // 3.1 Vérifier un Destinataire
  Future<ApiResponse<VerifierDestinataireResponse>> verifierDestinataire(
      String numeroCompte, String numeroTelephone) async {
    final response = await _httpService.get<Map<String, dynamic>>(
      '/$numeroCompte/transfert/verifier-destinataire/$numeroTelephone',
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return ApiResponse<VerifierDestinataireResponse>(
        success: true,
        data: VerifierDestinataireResponse.fromJson(response.data!),
      );
    }

    return ApiResponse<VerifierDestinataireResponse>(
      success: false,
      message:
          response.message ?? 'Erreur lors de la vérification du destinataire',
    );
  }

  // 3.2 Initier un Transfert
  Future<ApiResponse<InitierTransfertResponse>> initierTransfert(
      String numeroCompte, InitiateTransfertRequest request) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '/$numeroCompte/transfert/initier',
      request.toJson(),
      requiresAuth: true,
      fromJson: (m) => m,
    );

    if (response.success && response.data != null) {
      return ApiResponse<InitierTransfertResponse>(
        success: true,
        data: InitierTransfertResponse.fromJson(response.data!),
      );
    }

    return ApiResponse<InitierTransfertResponse>(
      success: false,
      message: response.message ?? 'Erreur lors de l\'initiation du transfert',
    );
  }

  // 3.3 Confirmer un Transfert
  Future<ApiResponse<ConfirmerTransfertResponse>> confirmerTransfert(
      String numeroCompte, String idTransfert, String codePin) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '/$numeroCompte/transfert/$idTransfert/confirmer',
      {'codePin': codePin},
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return ApiResponse<ConfirmerTransfertResponse>(
        success: true,
        data: ConfirmerTransfertResponse.fromJson(response.data!),
      );
    }

    return ApiResponse<ConfirmerTransfertResponse>(
      success: false,
      message:
          response.message ?? 'Erreur lors de la confirmation du transfert',
    );
  }

  // 3.4 Annuler un Transfert
  Future<ApiResponse<Map<String, dynamic>>> annulerTransfert(
      String numeroCompte, String idTransfert) async {
    final response = await _httpService.delete<Map<String, dynamic>>(
      '/$numeroCompte/transfert/$idTransfert/annuler',
      requiresAuth: true,
    );

    return response;
  }
}

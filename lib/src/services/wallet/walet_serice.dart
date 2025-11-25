// lib/services/wallet/wallet_service.dart

import 'package:flutter_app/src/models/wallet/wallet_models.dart';
import 'package:flutter_app/src/services/services.dart';

class WalletService {
  final HttpService _httpService;

  WalletService(this._httpService);

  Future<ApiResponse<double>> getBalance(String accountNumber) async {
    final response = await _httpService.get<String>(
      '/$accountNumber/portefeuille/solde',
      requiresAuth: true,
      fromJson: (data) => data as String,
    );

    if (response.success && response.data != null) {
      return ApiResponse<double>(
        success: true,
        data: double.parse(response.data!),
      );
    }

    return ApiResponse<double>(
      success: false,
      message: response.message ?? 'Erreur lors de la récupération du solde',
    );
  }

  Future<ApiResponse<TransactionHistory>> getTransactionHistory({
    int page = 1,
    int limite = 20,
    String? type,
    String? dateDebut,
    String? dateFin,
    String? statut,
  }) async {
    final filters = <String, dynamic>{};

    if (type != null && type != 'tous') filters['type'] = type;
    if (dateDebut != null) filters['dateDebut'] = dateDebut;
    if (dateFin != null) filters['dateFin'] = dateFin;
    if (statut != null) filters['statut'] = statut;

    final response = await _httpService.post<Map<String, dynamic>>(
      '/portefeuille/historique-transactions',
      {
        'page': page,
        'limite': limite,
        'filters': filters,
      },
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      final historyData = response.data!['data'] as Map<String, dynamic>;
      return ApiResponse<TransactionHistory>(
        success: true,
        data: TransactionHistory.fromJson(historyData),
      );
    }

    return ApiResponse<TransactionHistory>(
      success: false,
      message:
          response.message ?? 'Erreur lors de la récupération de l\'historique',
    );
  }

  Future<ApiResponse<TransactionDetail>> getTransactionDetail(
    String accountNumber,
    String transactionId,
  ) async {
    return _httpService.get<TransactionDetail>(
      '/$accountNumber/portefeuille/transactions/$transactionId',
      requiresAuth: true,
      fromJson: (data) =>
          TransactionDetail.fromJson(data as Map<String, dynamic>),
    );
  }
}

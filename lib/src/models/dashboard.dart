// lib/models/dashboard/dashboard_response.dart
import 'package:flutter_app/src/models/auth_models/user.dart';
import 'package:flutter_app/src/models/transaction_mdels/qrcode.dart';
import 'package:flutter_app/src/models/transaction_mdels/transaction.dart';
import 'package:flutter_app/src/models/wallet/wallet.dart';

class DashboardResponse {
  final User utilisateur;
  final Wallet? portefeuille;
  final QrCode? qrCode;
  final List<Transaction> transactionsRecentes;

  DashboardResponse({
    required this.utilisateur,
    this.portefeuille,
    this.qrCode,
    required this.transactionsRecentes,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      utilisateur: User.fromJson(json['utilisateur'] as Map<String, dynamic>),
      portefeuille: json['portefeuille'] != null
          ? Wallet.fromJson(json['portefeuille'] as Map<String, dynamic>)
          : null,
      qrCode: json['qr_code'] != null
          ? QrCode.fromJson(json['qr_code'] as Map<String, dynamic>)
          : null,
      transactionsRecentes: (json['transactions_recentes'] as List<dynamic>?)
              ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'utilisateur': utilisateur.toJson(),
      'portefeuille': portefeuille?.toJson(),
      'qr_code': qrCode?.toJson(),
      'transactions_recentes':
          transactionsRecentes.map((e) => e.toJson()).toList(),
    };
  }
}

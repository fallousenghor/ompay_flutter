// lib/models/wallet/wallet_models.dart

import 'package:flutter_app/src/models/transaction_mdels/transaction.dart';
import 'package:flutter_app/src/models/transaction_mdels/transactionparticipant.dart';
import 'package:flutter_app/src/models/transaction_mdels/transactionmarchant.dart';

// Modèles supplémentaires pour le portefeuille
class WalletBalance {
  final double solde;
  final String devise;

  WalletBalance({
    required this.solde,
    required this.devise,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      solde: (json['solde'] as num).toDouble(),
      devise: json['devise'] as String,
    );
  }
}

class TransactionHistory {
  final List<Transaction> transactions;
  final PaginationInfo pagination;

  TransactionHistory({
    required this.transactions,
    required this.pagination,
  });

  factory TransactionHistory.fromJson(Map<String, dynamic> json) {
    return TransactionHistory(
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination:
          PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }
}

class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final int elementsPerPage;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
    required this.elementsPerPage,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['pageActuelle'] as int,
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
      elementsPerPage: json['elementsParPage'] as int,
    );
  }
}

class TransactionDetail {
  final String id;
  final double montant;
  final String type;
  final String statut;
  final DateTime date;

  TransactionDetail({
    required this.id,
    required this.montant,
    required this.type,
    required this.statut,
    required this.date,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      id: json['id'] as String,
      montant: (json['montant'] as num).toDouble(),
      type: json['type'] as String,
      statut: json['statut'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class WalletTransaction {
  final String id;
  final String type;
  final String montant;
  final double montantNumerique;
  final String devise;
  final String typeOperation;
  final TransactionParticipant? expediteur;
  final TransactionParticipant? destinataire;
  final TransactionMerchant? marchand;
  final String statut;
  final DateTime dateTransaction;
  final String reference;
  final double frais;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.montant,
    required this.montantNumerique,
    required this.devise,
    required this.typeOperation,
    this.expediteur,
    this.destinataire,
    this.marchand,
    required this.statut,
    required this.dateTransaction,
    required this.reference,
    required this.frais,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['idTransaction'] as String,
      type: json['type'] as String,
      montant: json['montant'] as String,
      montantNumerique: (json['montantNumerique'] as num).toDouble(),
      devise: json['devise'] as String,
      typeOperation: json['typeOperation'] as String,
      expediteur: json['expediteur'] != null
          ? TransactionParticipant.fromJson(
              json['expediteur'] as Map<String, dynamic>)
          : null,
      destinataire: json['destinataire'] != null
          ? TransactionParticipant.fromJson(
              json['destinataire'] as Map<String, dynamic>)
          : null,
      marchand: json['marchand'] != null
          ? TransactionMerchant.fromJson(
              json['marchand'] as Map<String, dynamic>)
          : null,
      statut: json['statut'] as String,
      dateTransaction: DateTime.parse(json['dateTransaction'] as String),
      reference: json['reference'] as String,
      frais: (json['frais'] as num).toDouble(),
    );
  }
}

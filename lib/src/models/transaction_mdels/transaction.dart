// lib/models/transaction/transaction.dart
import 'package:flutter_app/src/models/transaction_mdels/transactionmarchant.dart';
import 'package:flutter_app/src/models/transaction_mdels/transactionparticipant.dart';

class Transaction {
  final String id;
  final String type;
  final String montant;
  final double montantNumerique;
  final String devise;
  final String typeOperation; // 'debit' ou 'credit'
  final TransactionParticipant? expediteur;
  final TransactionParticipant? destinataire;
  final TransactionMerchant? marchand;
  final String statut;
  final DateTime dateTransaction;
  final String reference;
  final double frais;

  Transaction({
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

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'montant': montant,
      'montantNumerique': montantNumerique,
      'devise': devise,
      'typeOperation': typeOperation,
      'expediteur': expediteur?.toJson(),
      'destinataire': destinataire?.toJson(),
      'marchand': marchand?.toJson(),
      'statut': statut,
      'dateTransaction': dateTransaction.toIso8601String(),
      'reference': reference,
      'frais': frais,
    };
  }
}

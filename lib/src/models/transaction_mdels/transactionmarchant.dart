// lib/models/transaction/transaction_merchant.dart
class TransactionMerchant {
  final String nom;
  final String categorie;

  TransactionMerchant({
    required this.nom,
    required this.categorie,
  });

  factory TransactionMerchant.fromJson(Map<String, dynamic> json) {
    return TransactionMerchant(
      nom: json['nom'] as String? ?? '',
      categorie: json['categorie'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'categorie': categorie,
    };
  }
}

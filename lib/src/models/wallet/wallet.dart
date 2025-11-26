// lib/models/wallet/wallet.dart
class Wallet {
  final String id;
  final String idUtilisateur;
  final double solde;
  final String devise;
  final DateTime? derniereMiseAJour;

  Wallet({
    required this.id,
    required this.idUtilisateur,
    required this.solde,
    required this.devise,
    this.derniereMiseAJour,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as String? ?? '',
      idUtilisateur: json['id_utilisateur'] as String? ?? '',
      solde: json['solde'] is String
          ? double.parse(json['solde'] as String)
          : (json['solde'] as num).toDouble(),
      devise: json['devise'] as String,
      derniereMiseAJour: json['derniere_mise_a_jour'] != null
          ? DateTime.parse(json['derniere_mise_a_jour'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_utilisateur': idUtilisateur,
      'solde': solde,
      'devise': devise,
      'derniere_mise_a_jour': derniereMiseAJour?.toIso8601String(),
    };
  }

  bool verifierFondsSuffisants(double montant) {
    return solde >= montant;
  }

  double calculerSoldeApresTransaction(double montant, String type) {
    return type == 'debit' ? solde - montant : solde + montant;
  }
}

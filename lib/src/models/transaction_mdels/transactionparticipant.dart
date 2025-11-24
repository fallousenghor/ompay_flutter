// lib/models/transaction/transaction_participant.dart
class TransactionParticipant {
  final String numeroTelephone;
  final String nom;

  TransactionParticipant({
    required this.numeroTelephone,
    required this.nom,
  });

  factory TransactionParticipant.fromJson(Map<String, dynamic> json) {
    return TransactionParticipant(
      numeroTelephone: json['numeroTelephone'] as String,
      nom: json['nom'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroTelephone': numeroTelephone,
      'nom': nom,
    };
  }
}

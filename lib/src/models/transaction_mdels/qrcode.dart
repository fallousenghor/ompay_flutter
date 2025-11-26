// lib/models/user/qr_code.dart
class QrCode {
  final String id;
  final String donnees;
  final DateTime dateGeneration;
  final DateTime dateExpiration;

  QrCode({
    required this.id,
    required this.donnees,
    required this.dateGeneration,
    required this.dateExpiration,
  });

  factory QrCode.fromJson(Map<String, dynamic> json) {
    return QrCode(
      id: json['id'] as String? ?? '',
      donnees: json['donnees'] as String? ?? '',
      dateGeneration: json['date_generation'] != null
          ? DateTime.parse(json['date_generation'] as String)
          : DateTime.now(),
      dateExpiration: json['date_expiration'] != null
          ? DateTime.parse(json['date_expiration'] as String)
          : DateTime.now().add(const Duration(days: 365)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donnees': donnees,
      'date_generation': dateGeneration.toIso8601String(),
      'date_expiration': dateExpiration.toIso8601String(),
    };
  }
}

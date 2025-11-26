// lib/models/auth_models/user.dart
class User {
  final String id;
  final String numeroTelephone;
  final String? prenom;
  final String? nom;
  final String? email;
  final String? numeroCni;
  final String? statutKyc;
  final bool biometrieActivee;
  final DateTime? dateCreation;
  final DateTime? derniereConnexion;

  User({
    required this.id,
    required this.numeroTelephone,
    this.prenom,
    this.nom,
    this.email,
    this.numeroCni,
    this.statutKyc,
    required this.biometrieActivee,
    this.dateCreation,
    this.derniereConnexion,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? json['idUtilisateur'] as String? ?? '',
      numeroTelephone: json['numeroTelephone'] as String? ??
          json['numero_telephone'] as String? ??
          '',
      prenom: json['prenom'] as String?,
      nom: json['nom'] as String?,
      email: json['email'] as String?,
      numeroCni: json['numeroCNI'] as String? ?? json['numero_cni'] as String?,
      statutKyc: json['statutKYC'] as String? ?? json['statut_kyc'] as String?,
      biometrieActivee: json['biometrieActivee'] as bool? ??
          json['biometrie_activee'] as bool? ??
          false,
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'] as String)
          : json['date_creation'] != null
              ? DateTime.parse(json['date_creation'] as String)
              : null,
      derniereConnexion: json['derniereConnexion'] != null
          ? DateTime.parse(json['derniereConnexion'] as String)
          : json['derniere_connexion'] != null
              ? DateTime.parse(json['derniere_connexion'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUtilisateur': id,
      'numeroTelephone': numeroTelephone,
      'prenom': prenom,
      'nom': nom,
      'email': email,
      'numeroCNI': numeroCni,
      'statutKYC': statutKyc,
      'biometrieActivee': biometrieActivee,
      'dateCreation': dateCreation?.toIso8601String(),
      'derniereConnexion': derniereConnexion?.toIso8601String(),
    };
  }

  String get nomComplet => prenom != null && nom != null ? '$prenom $nom' : '';
}

// lib/models/transaction/transaction_models.dart

// Modèles pour les transferts
class InitiateTransfertRequest {
  final String telephoneDestinataire;
  final double montant;
  final String devise;
  final String? note;

  InitiateTransfertRequest({
    required this.telephoneDestinataire,
    required this.montant,
    this.devise = 'XOF',
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'telephoneDestinataire': telephoneDestinataire,
      'montant': montant,
      'devise': devise,
      if (note != null) 'note': note,
    };
  }
}

class VerifierDestinataireResponse {
  final bool estValide;
  final String nom;
  final String numeroTelephone;
  final String operateur;

  VerifierDestinataireResponse({
    required this.estValide,
    required this.nom,
    required this.numeroTelephone,
    required this.operateur,
  });

  factory VerifierDestinataireResponse.fromJson(Map<String, dynamic> json) {
    return VerifierDestinataireResponse(
      estValide: json['estValide'] as bool,
      nom: json['nom'] as String,
      numeroTelephone: json['numeroTelephone'] as String,
      operateur: json['operateur'] as String,
    );
  }
}

class InitierTransfertResponse {
  final String idTransfert;
  final String statut;
  final double montant;
  final double frais;
  final double montantTotal;
  final DestinataireInfo destinataire;
  final String? dateExpiration;

  InitierTransfertResponse({
    required this.idTransfert,
    required this.statut,
    required this.montant,
    required this.frais,
    required this.montantTotal,
    required this.destinataire,
    this.dateExpiration,
  });

  factory InitierTransfertResponse.fromJson(Map<String, dynamic> json) {
    return InitierTransfertResponse(
      idTransfert: json['idTransfert'] as String,
      statut: json['statut'] as String,
      montant: (json['montant'] as num).toDouble(),
      frais: (json['frais'] as num).toDouble(),
      montantTotal: (json['montantTotal'] as num).toDouble(),
      destinataire: DestinataireInfo.fromJson(
          json['destinataire'] as Map<String, dynamic>),
      dateExpiration: json['dateExpiration'] as String?,
    );
  }
}

class ConfirmerTransfertResponse {
  final String idTransaction;
  final String statut;
  final double montant;
  final DestinataireInfo destinataire;
  final String dateTransaction;
  final String reference;
  final String? recu;

  ConfirmerTransfertResponse({
    required this.idTransaction,
    required this.statut,
    required this.montant,
    required this.destinataire,
    required this.dateTransaction,
    required this.reference,
    this.recu,
  });

  factory ConfirmerTransfertResponse.fromJson(Map<String, dynamic> json) {
    return ConfirmerTransfertResponse(
      idTransaction: json['idTransaction'] as String,
      statut: json['statut'] as String,
      montant: (json['montant'] as num).toDouble(),
      destinataire: DestinataireInfo.fromJson(
          json['destinataire'] as Map<String, dynamic>),
      dateTransaction: json['dateTransaction'] as String,
      reference: json['reference'] as String,
      recu: json['recu'] as String?,
    );
  }
}

class DestinataireInfo {
  final String numeroTelephone;
  final String nom;

  DestinataireInfo({
    required this.numeroTelephone,
    required this.nom,
  });

  factory DestinataireInfo.fromJson(Map<String, dynamic> json) {
    return DestinataireInfo(
      numeroTelephone: json['numeroTelephone'] as String,
      nom: json['nom'] as String,
    );
  }
}

// Modèles pour les paiements
class InitiatePaiementRequest {
  final String idMarchand;
  final double montant;
  final String devise;
  final String modePaiement; // 'qr_code' ou 'code_numerique'
  final String? idQrCode;
  final String? idCodePaiement;
  final Map<String, dynamic>? detailsPaiement;

  InitiatePaiementRequest({
    required this.idMarchand,
    required this.montant,
    this.devise = 'XOF',
    required this.modePaiement,
    this.idQrCode,
    this.idCodePaiement,
    this.detailsPaiement,
  });

  Map<String, dynamic> toJson() {
    return {
      'idMarchand': idMarchand,
      'montant': montant,
      'devise': devise,
      'modePaiement': modePaiement,
      if (idQrCode != null) 'idQrCode': idQrCode,
      if (idCodePaiement != null) 'idCodePaiement': idCodePaiement,
      if (detailsPaiement != null) 'detailsPaiement': detailsPaiement,
    };
  }
}

class ScannerQrResponse {
  final Map<String, dynamic> data;

  ScannerQrResponse({required this.data});

  factory ScannerQrResponse.fromJson(Map<String, dynamic> json) {
    return ScannerQrResponse(
      data: json['data'] as Map<String, dynamic>,
    );
  }
}

class SaisirCodeResponse {
  final Map<String, dynamic> data;

  SaisirCodeResponse({required this.data});

  factory SaisirCodeResponse.fromJson(Map<String, dynamic> json) {
    return SaisirCodeResponse(
      data: json['data'] as Map<String, dynamic>,
    );
  }
}

class InitierPaiementResponse {
  final String idPaiement;
  final String statut;
  final double montant;
  final MarchandInfo marchand;
  final String? dateExpiration;

  InitierPaiementResponse({
    required this.idPaiement,
    required this.statut,
    required this.montant,
    required this.marchand,
    this.dateExpiration,
  });

  factory InitierPaiementResponse.fromJson(Map<String, dynamic> json) {
    return InitierPaiementResponse(
      idPaiement: json['idPaiement'] as String,
      statut: json['statut'] as String,
      montant: (json['montant'] as num).toDouble(),
      marchand: MarchandInfo.fromJson(json['marchand'] as Map<String, dynamic>),
      dateExpiration: json['dateExpiration'] as String?,
    );
  }
}

class ConfirmerPaiementResponse {
  final String idTransaction;
  final String statut;
  final double montant;
  final MarchandInfo marchand;
  final String dateTransaction;
  final String reference;
  final String? recu;

  ConfirmerPaiementResponse({
    required this.idTransaction,
    required this.statut,
    required this.montant,
    required this.marchand,
    required this.dateTransaction,
    required this.reference,
    this.recu,
  });

  factory ConfirmerPaiementResponse.fromJson(Map<String, dynamic> json) {
    return ConfirmerPaiementResponse(
      idTransaction: json['idTransaction'] as String,
      statut: json['statut'] as String,
      montant: (json['montant'] as num).toDouble(),
      marchand: MarchandInfo.fromJson(json['marchand'] as Map<String, dynamic>),
      dateTransaction: json['dateTransaction'] as String,
      reference: json['reference'] as String,
      recu: json['recu'] as String?,
    );
  }
}

class MarchandInfo {
  final String nom;
  final String categorie;

  MarchandInfo({
    required this.nom,
    required this.categorie,
  });

  factory MarchandInfo.fromJson(Map<String, dynamic> json) {
    return MarchandInfo(
      nom: json['nom'] as String,
      categorie: json['categorie'] as String,
    );
  }
}

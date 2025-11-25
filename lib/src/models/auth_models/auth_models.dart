// lib/models/auth/auth_models.dart

import 'package:flutter_app/src/models/auth_models/user.dart';
import 'package:flutter_app/src/models/wallet/wallet.dart';
import 'package:flutter_app/src/models/transaction_mdels/qrcode.dart';

// Authentication Request/Response Models

class InitiateLoginRequest {
  final String numeroTelephone;

  InitiateLoginRequest({required this.numeroTelephone});

  Map<String, dynamic> toJson() {
    return {
      'numero_telephone': numeroTelephone,
    };
  }
}

class InitiateLoginResponse {
  final String message;
  final String? code; // Seulement en développement
  final String? lien;
  final String? token;

  InitiateLoginResponse({
    required this.message,
    this.code,
    this.lien,
    this.token,
  });

  factory InitiateLoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return InitiateLoginResponse(
      message: (json['message'] as String?) ?? '',
      code: data?['code_otp'] as String?,
      lien: data?['lien'] as String?,
      token: data?['token'] as String?,
    );
  }
}

class VerifyOtpRequest {
  final String token;
  final String code;

  VerifyOtpRequest({
    required this.token,
    required this.code,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'code': code,
    };
  }
}

class VerifyOtpResponse {
  final String status;
  final String? numeroTelephone;
  final String? token;
  final User? user;
  final Wallet? portefeuille;
  final QrCode? qrCode;
  final String? sessionToken;
  final String? refreshToken;

  VerifyOtpResponse({
    required this.status,
    this.numeroTelephone,
    this.token,
    this.user,
    this.portefeuille,
    this.qrCode,
    this.sessionToken,
    this.refreshToken,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      status: (json['status'] as String?) ?? '',
      numeroTelephone: json['numero_telephone'] as String?,
      token: json['token'] as String?,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      portefeuille: json['portefeuille'] != null
          ? Wallet.fromJson(json['portefeuille'] as Map<String, dynamic>)
          : null,
      qrCode: json['qr_code'] != null
          ? QrCode.fromJson(json['qr_code'] as Map<String, dynamic>)
          : null,
      sessionToken: json['session_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
    );
  }
}

class CreateAccountRequest {
  final String numeroTelephone;
  final String codePin;
  final String token;

  CreateAccountRequest({
    required this.numeroTelephone,
    required this.codePin,
    required this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'numero_telephone': numeroTelephone,
      'code_pin': codePin,
      'token': token,
    };
  }
}

class CreateAccountResponse {
  final String sessionToken;
  final String refreshToken;
  final User? user;
  final QrCode? qrCode;

  CreateAccountResponse({
    required this.sessionToken,
    required this.refreshToken,
    this.user,
    this.qrCode,
  });

  factory CreateAccountResponse.fromJson(Map<String, dynamic> json) {
    return CreateAccountResponse(
      sessionToken: (json['session_token'] as String?) ?? '',
      refreshToken: (json['refresh_token'] as String?) ?? '',
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      qrCode: json['qr_code'] != null
          ? QrCode.fromJson(json['qr_code'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LoginRequest {
  final String numeroTelephone;
  final String codePin;

  LoginRequest({
    required this.numeroTelephone,
    required this.codePin,
  });

  Map<String, dynamic> toJson() {
    return {
      'numero_telephone': numeroTelephone,
      'code_pin': codePin,
    };
  }
}

class LoginResponse {
  final String sessionToken;
  final String refreshToken;
  final User? user;
  final QrCode? qrCode;
  final bool firstLogin;

  LoginResponse({
    required this.sessionToken,
    required this.refreshToken,
    this.user,
    this.qrCode,
    required this.firstLogin,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Handle both 'session_token' and 'token' keys for compatibility
    String? sessionToken = json['session_token'] as String?;
    if (sessionToken == null || sessionToken.isEmpty) {
      sessionToken = json['token'] as String?;
    }
    return LoginResponse(
      sessionToken: sessionToken ?? '',
      refreshToken: (json['refresh_token'] as String?) ?? '',
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      qrCode: json['qr_code'] != null
          ? QrCode.fromJson(json['qr_code'] as Map<String, dynamic>)
          : null,
      firstLogin: json['first_login'] as bool? ?? false,
    );
  }
}

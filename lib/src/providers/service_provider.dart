// lib/providers/service_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/src/services/auth/auth_service.dart';
import 'package:flutter_app/src/services/auth/user_service.dart';
import 'package:flutter_app/src/services/services.dart';
import 'package:flutter_app/src/services/transactions/paiment_service.dart';
import 'package:flutter_app/src/services/transactions/transfert_service.dart';
import 'package:flutter_app/src/services/wallet/walet_serice.dart';

class ServiceProvider with ChangeNotifier {
  late final HttpService _httpService;
  late final AuthService _authService;
  late final UserService _userService;
  late final WalletService _walletService;
  late final TransfertService _transfertService;
  late final PaiementService _paiementService;

  // Constructor
  ServiceProvider() {
    _initializeServices();
  }

  void _initializeServices() {
    _httpService = HttpService();
    _authService = AuthService(_httpService);
    _userService = UserService(_httpService);
    _walletService = WalletService(_httpService);
    _transfertService = TransfertService(_httpService);
    _paiementService = PaiementService(_httpService);
  }

  // Getters for services
  HttpService get httpService => _httpService;
  AuthService get authService => _authService;
  UserService get userService => _userService;
  WalletService get walletService => _walletService;
  TransfertService get transfertService => _transfertService;
  PaiementService get paiementService => _paiementService;

  // Authentication token management
  void setAuthToken(String token) {
    _httpService.setAuthToken(token);
    notifyListeners();
  }

  void clearAuthToken() {
    _httpService.clearAuthToken();
    notifyListeners();
  }
}

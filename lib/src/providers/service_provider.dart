// lib/providers/service_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/src/services/auth/auth_service.dart';
import 'package:flutter_app/src/services/auth/user_service.dart';
import 'package:flutter_app/src/services/services.dart';
import 'package:flutter_app/src/services/transactions/paiment_service.dart';
import 'package:flutter_app/src/services/transactions/transfert_service.dart';
import 'package:flutter_app/src/services/wallet/walet_serice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:flutter_app/src/models/auth_models/user.dart';

class ServiceProvider with ChangeNotifier {
  late final HttpService _httpService;
  late final AuthService _authService;
  late final UserService _userService;
  late final WalletService _walletService;
  late final TransfertService _transfertService;
  late final PaiementService _paiementService;

  User? _currentUser;
  double? _currentBalance;

  // Constructor
  ServiceProvider() {
    _initializeServices();
    _loadFromStorage();
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

  User? get currentUser => _currentUser;
  double? get currentBalance => _currentBalance;

  Future<void> fetchUserProfile() async {
    debugPrint('Fetching user profile...');
    final response = await _userService.getUserProfile();
    debugPrint(
        'Profile response: success=${response.success}, data=${response.data}');
    if (response.success && response.data != null) {
      _currentUser = response.data!;
      _saveUserToStorage(_currentUser!);
      debugPrint(
          'User profile loaded: ${_currentUser!.nomComplet} (${_currentUser!.numeroTelephone})');

      // Charger le solde après le profil
      await fetchBalance();

      notifyListeners();
    } else {
      debugPrint('Failed to load user profile: ${response.message}');
    }
  }

  Future<void> fetchBalance() async {
    if (_currentUser == null) return;

    debugPrint('Fetching balance for user: ${_currentUser!.numeroTelephone}');
    final response =
        await _walletService.getBalance(_currentUser!.numeroTelephone);
    debugPrint(
        'Balance response: success=${response.success}, data=${response.data}');
    if (response.success && response.data != null) {
      _currentBalance = response.data!;
      _saveBalanceToStorage(_currentBalance!);
      debugPrint('Balance loaded: $_currentBalance');
    } else {
      debugPrint('Failed to load balance: ${response.message}');
    }
  }

  // Authentication token management
  void setAuthToken(String token) {
    _httpService.setAuthToken(token);
    notifyListeners();
  }

  void setCurrentUser(User user) {
    _currentUser = user;
    _saveUserToStorage(user);
    notifyListeners();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('currentUser');
    if (userJson != null) {
      try {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        _currentUser = User.fromJson(userMap);
      } catch (e) {
        // Ignore invalid data
      }
    }
    final balance = prefs.getDouble('currentBalance');
    if (balance != null) {
      _currentBalance = balance;
    }
    notifyListeners();
  }

  Future<void> _saveUserToStorage(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUser', json.encode(user.toJson()));
  }

  Future<void> _saveBalanceToStorage(double balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('currentBalance', balance);
  }

  Future<void> clearAuthToken() async {
    _httpService.clearAuthToken();
    _currentUser = null;
    _currentBalance = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
    await prefs.remove('currentBalance');
    notifyListeners();
  }
}

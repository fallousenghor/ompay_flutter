// lib/providers/service_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/src/services/auth/auth_service.dart';
import 'package:flutter_app/src/services/auth/user_service.dart'
    as auth_service;
import 'package:flutter_app/src/services/dashboard/dash_service.dart';
import 'package:flutter_app/src/services/services.dart';
import 'package:flutter_app/src/services/transactions/paiment_service.dart';
import 'package:flutter_app/src/services/transactions/transfert_service.dart';
import 'package:flutter_app/src/services/wallet/walet_serice.dart';
import 'package:flutter_app/src/models/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:flutter_app/src/models/auth_models/user.dart';

class ServiceProvider with ChangeNotifier {
  late final HttpService _httpService;
  late final AuthService _authService;
  late final auth_service.UserService _userService;
  late final DashboardService _dashboardService;
  late final WalletService _walletService;
  late final TransfertService _transfertService;
  late final PaiementService _paiementService;

  User? _currentUser;
  double? _currentBalance;
  DashboardResponse? _dashboard;

  bool _isLoadingUser = true;
  bool _isLoadingBalance = true;
  bool _isLoadingDashboard = true;

  // Constructor
  ServiceProvider() {
    _initializeServices();
    _loadFromStorage();
  }

  void _initializeServices() {
    _httpService = HttpService();
    _authService = AuthService(_httpService);
    _userService = auth_service.UserService(_httpService);
    _dashboardService = DashboardService(_httpService);
    _walletService = WalletService(_httpService);
    _transfertService = TransfertService(_httpService);
    _paiementService = PaiementService(_httpService);
  }

  // Getters for services
  HttpService get httpService => _httpService;
  AuthService get authService => _authService;
  auth_service.UserService get userService => _userService;
  DashboardService get dashboardService => _dashboardService;
  WalletService get walletService => _walletService;
  TransfertService get transfertService => _transfertService;
  PaiementService get paiementService => _paiementService;

  User? get currentUser => _currentUser;
  double? get currentBalance => _currentBalance;
  DashboardResponse? get dashboard => _dashboard;

  bool get isLoadingUser => _isLoadingUser;
  bool get isLoadingBalance => _isLoadingBalance;
  bool get isLoadingDashboard => _isLoadingDashboard;

  bool get isLoading =>
      _isLoadingUser || _isLoadingBalance || _isLoadingDashboard;

  Future<void> fetchUserProfile() async {
    _isLoadingUser = true;
    notifyListeners();
    final response = await _userService.getUserProfile();
    if (response.success && response.data != null) {
      _currentUser = response.data!;
      _saveUserToStorage(_currentUser!);

      // Charger le solde après le profil
      await fetchBalance();
    }
    _isLoadingUser = false;
    notifyListeners();
  }

  Future<void> fetchBalance() async {
    if (_currentUser == null) return;

    _isLoadingBalance = true;
    notifyListeners();
    final response =
        await _walletService.getBalance(_currentUser!.numeroTelephone);
    if (response.success && response.data != null) {
      _currentBalance = response.data!;
      _saveBalanceToStorage(_currentBalance!);
    }
    _isLoadingBalance = false;
    notifyListeners();
  }

  Future<void> fetchDashboard() async {
    _isLoadingDashboard = true;
    notifyListeners();
    final response = await _dashboardService.getDashboard();
    if (response.success && response.data != null) {
      _dashboard = response.data!;
      _saveDashboardToStorage(_dashboard!);
    }
    _isLoadingDashboard = false;
    notifyListeners();
  }

  // Authentication token management
  void setAuthToken(String token) {
    _httpService.setAuthToken(token);
    _saveAuthTokenToStorage(token);
    notifyListeners();
  }

  void setCurrentUser(User user) {
    _currentUser = user;
    _saveUserToStorage(user);
    notifyListeners();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token != null) {
      _httpService.setAuthToken(token);
    }
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
    final dashboardJson = prefs.getString('dashboard');
    if (dashboardJson != null) {
      try {
        final dashboardMap = json.decode(dashboardJson) as Map<String, dynamic>;
        _dashboard = DashboardResponse.fromJson(dashboardMap);
      } catch (e) {
        // Ignore invalid data
      }
    }
    // Set loading to false after loading from storage
    _isLoadingUser = false;
    _isLoadingBalance = false;
    _isLoadingDashboard = false;
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

  Future<void> _saveDashboardToStorage(DashboardResponse dashboard) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dashboard', json.encode(dashboard.toJson()));
  }

  Future<void> _saveAuthTokenToStorage(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  Future<void> clearAuthToken() async {
    _httpService.clearAuthToken();
    _currentUser = null;
    _currentBalance = null;
    _dashboard = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('currentUser');
    await prefs.remove('currentBalance');
    await prefs.remove('dashboard');
    notifyListeners();
  }
}

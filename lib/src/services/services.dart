// lib/services/http_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? dataFromJson,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] != null && dataFromJson != null
          ? dataFromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class HttpService {
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api';

  final http.Client _client;
  String? _authToken;

  HttpService({http.Client? client}) : _client = client ?? http.Client();

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Map<String, String> _getHeaders({bool requiresAuth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    bool requiresAuth = false,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(requiresAuth: requiresAuth),
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint,
    dynamic data, {
    bool requiresAuth = false,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(requiresAuth: requiresAuth),
        body: json.encode(data),
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint,
    dynamic data, {
    bool requiresAuth = false,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(requiresAuth: requiresAuth),
        body: json.encode(data),
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    bool requiresAuth = false,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(requiresAuth: requiresAuth),
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse<T>(
        success: responseData['success'] ?? true,
        message: responseData['message'],
        data: responseData['data'] != null && fromJson != null
            ? fromJson(responseData['data'])
            : null,
      );
    } else {
      throw Exception(responseData['message'] ?? 'Erreur inconnue');
    }
  }
}

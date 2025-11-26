// lib/services/http_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';

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
      dotenv.env['BASE_URL'] ?? 'http://localhost:8000/';

  final http.Client _client;
  String? _authToken;

  HttpService({http.Client? client})
      : _client = client ?? (kIsWeb ? BrowserClient() : http.Client());

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
    } else if (requiresAuth) {
      // WARNING: requiresAuth=true but _authToken is null
    }

    return headers;
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    bool requiresAuth = false,
    T Function(dynamic)? fromJson,
    bool fullResponse = false,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(requiresAuth: requiresAuth),
      );

      return _handleResponse<T>(response, fromJson, fullResponse: fullResponse);
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint,
    dynamic data, {
    bool requiresAuth = false,
    T Function(dynamic)? fromJson,
    bool fullResponse = false,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(requiresAuth: requiresAuth),
        body: json.encode(data),
      );

      return _handleResponse<T>(response, fromJson, fullResponse: fullResponse);
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint,
    dynamic data, {
    bool requiresAuth = false,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(requiresAuth: requiresAuth),
        body: json.encode(data),
      );

      return _handleResponse<T>(response, fromJson, fullResponse: false);
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    bool requiresAuth = false,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(requiresAuth: requiresAuth),
      );

      return _handleResponse<T>(response, fromJson, fullResponse: false);
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson, {
    bool fullResponse = false,
  }) {
    try {
      final responseData = json.decode(response.body);
      if (responseData is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }
      final Map<String, dynamic> responseDataMap = responseData;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>(
          success: responseDataMap['success'] ?? true,
          message: responseDataMap['message'],
          data: fullResponse
              ? (fromJson != null
                  ? fromJson(responseDataMap)
                  : responseDataMap as T)
              : (responseDataMap['data'] != null && fromJson != null
                  ? fromJson(responseDataMap['data'])
                  : null),
        );
      } else {
        // Return an ApiResponse with success=false so callers can handle
        // backend errors gracefully and display server-provided messages.
        return ApiResponse<T>(
          success: false,
          message: responseDataMap['message'] ?? 'Erreur inconnue',
          data: null,
        );
      }
    } catch (e) {
      if (response.body == "null") {
        return ApiResponse<T>(
          success: true,
          message: 'connexion reussie',
          data: null,
        );
      }
      return ApiResponse<T>(
        success: false,
        message: 'Erreur de parsing JSON: $e',
        data: null,
      );
    }
  }
}

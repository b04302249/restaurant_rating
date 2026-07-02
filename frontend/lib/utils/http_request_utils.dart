import 'dart:convert';

import 'package:http/http.dart' as http;

import '../response/ping_response.dart';
import '../response/restaurant_response.dart';
import '../response/routes_response.dart';

class RestaurantApiClient {
  static const String _defaultBaseUrl = 'http://192.168.22.22:8080';

  RestaurantApiClient({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  String get defaultBaseUrl => _defaultBaseUrl;

  Future<PingResponse> fetchPing(String baseUrl) async {
    final json = await _getJsonMap(baseUrl, '/api/ping');
    return PingResponse.fromJson(json);
  }

  Future<RoutesResponse> fetchRoutes(String baseUrl) async {
    final json = await _getJsonMap(baseUrl, '/api/routes');
    return RoutesResponse.fromJson(json);
  }

  Future<List<RestaurantResponse>> fetchRestaurants(String baseUrl) async {
    final jsonList = await _getJsonList(baseUrl, '/api/restaurants');
    return jsonList.map(RestaurantResponse.fromJson).toList();
  }

  Future<Map<String, dynamic>> _getJsonMap(String baseUrl, String path) async {
    final decoded = await _getDecodedJson(baseUrl, path);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception('Unexpected response body: $decoded');
  }

  Future<List<Map<String, dynamic>>> _getJsonList(
    String baseUrl,
    String path,
  ) async {
    final decoded = await _getDecodedJson(baseUrl, path);
    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    }

    throw Exception('Unexpected response body: $decoded');
  }

  Future<Object?> _getDecodedJson(String baseUrl, String path) async {
    final normalizedBaseUrl = baseUrl.trim().replaceFirst(RegExp(r'/$'), '');
    final uri = Uri.parse('$normalizedBaseUrl$path');
    final response = await _client
        .get(uri)
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw Exception(
            'Request timeout: $uri\n請確認後端已啟動，或把 Base URL 改成正確位址。',
          ),
        );
    final rawBody = utf8.decode(response.bodyBytes);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: $rawBody');
    }

    return jsonDecode(rawBody);
  }
}

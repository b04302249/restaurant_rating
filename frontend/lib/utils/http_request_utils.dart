import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../response/event_response.dart';
import '../response/ping_response.dart';
import '../response/rating_response.dart';
import '../response/restaurant_response.dart';
import '../response/routes_response.dart';

class RestaurantApiClient {
  // static const String _defaultBaseUrl = 'http://192.168.22.22:8080';
  static const String _defaultBaseUrl = 'http://192.168.0.116:8080';

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

  Future<List<RestaurantResponse>> fetchUserRestaurants(
    String baseUrl,
    int userId,
  ) async {
    final jsonList = await _getJsonList(baseUrl, '/api/users/$userId/restaurants');
    return jsonList.map(RestaurantResponse.fromJson).toList();
  }

  Future<List<EventResponse>> fetchEvents(String baseUrl) async {
    final jsonList = await _getJsonList(baseUrl, '/api/events');
    return jsonList.map(EventResponse.fromJson).toList();
  }

  Future<List<Map<String, dynamic>>> fetchUsers(String baseUrl) async {
    return _getJsonList(baseUrl, '/api/users');
  }

  Future<Map<String, dynamic>> createUser(
    String baseUrl, {
    required String name,
    required String email,
  }) async {
    return _postJson(baseUrl, '/api/users', {
      'name': name,
      'email': email,
    });
  }

  Future<RestaurantResponse> createRestaurant(
    String baseUrl, {
    required String name,
    String? area,
    String? category,
    String? address,
    String? note,
  }) async {
    final json = await _postJson(baseUrl, '/api/restaurants', {
      'name': name,
      if (area != null && area.trim().isNotEmpty) 'area': area,
      if (category != null && category.trim().isNotEmpty) 'category': category,
      if (address != null && address.trim().isNotEmpty) 'address': address,
      if (note != null && note.trim().isNotEmpty) 'note': note,
    });
    return RestaurantResponse.fromJson(json);
  }

  Future<EventResponse> createEvent(
    String baseUrl, {
    required String title,
    required String eventDate,
    int? restaurantId,
    List<int> participantUserIds = const [],
    List<int> ratingIds = const [],
  }) async {
    final json = await _postJson(baseUrl, '/api/events', {
      'title': title,
      'eventDate': eventDate,
      if (restaurantId != null) 'restaurantId': restaurantId,
      'participantUserIds': participantUserIds,
      'ratingIds': ratingIds,
    });
    return EventResponse.fromJson(json);
  }

  Future<List<RatingResponse>> fetchRatingsByRestaurant(
    String baseUrl,
    int restaurantId,
  ) async {
    final jsonList = await _getJsonList(
      baseUrl,
      '/api/ratings/restaurant/$restaurantId',
    );
    return jsonList.map(RatingResponse.fromJson).toList();
  }

  Future<RatingResponse> submitRating(
    String baseUrl, {
    required int restaurantId,
    required int userId,
    required int score,
    String? comment,
  }) async {
    final json = await _postJson(baseUrl, '/api/ratings', {
      'restaurantId': restaurantId,
      'userId': userId,
      'score': score,
      if (comment != null && comment.trim().isNotEmpty) 'comment': comment,
    });
    return RatingResponse.fromJson(json);
  }

  Future<void> addUserRestaurant(
    String baseUrl,
    int userId,
    int restaurantId,
  ) async {
    await _postJsonNoBody(baseUrl, '/api/users/$userId/restaurants/$restaurantId');
  }

  Future<void> removeUserRestaurant(
    String baseUrl,
    int userId,
    int restaurantId,
  ) async {
    await _deleteJson(baseUrl, '/api/users/$userId/restaurants/$restaurantId');
  }

  Future<Map<String, dynamic>> _postJson(
    String baseUrl,
    String path,
    Map<String, dynamic> body,
  ) async {
    final normalizedBaseUrl = baseUrl.trim().replaceFirst(RegExp(r'/$'), '');
    final uri = Uri.parse('$normalizedBaseUrl$path');
    final response = await _client
        .post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body))
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw Exception(
            'Request timeout: $uri\n請確認後端已啟動，或把 Base URL 改成正確位址。',
          ),
        );
    final rawBody = utf8.decode(response.bodyBytes);
    developer.log('POST $uri → ${response.statusCode}\n$rawBody', name: 'API');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: $rawBody');
    }

    final decoded = jsonDecode(rawBody);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception('Unexpected response body: $decoded');
  }

  Future<void> _postJsonNoBody(String baseUrl, String path) async {
    final normalizedBaseUrl = baseUrl.trim().replaceFirst(RegExp(r'/$'), '');
    final uri = Uri.parse('$normalizedBaseUrl$path');
    final response = await _client
        .post(uri, headers: {'Content-Type': 'application/json'})
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw Exception(
            'Request timeout: $uri\n請確認後端已啟動，或把 Base URL 改成正確位址。',
          ),
        );
    final rawBody = utf8.decode(response.bodyBytes);
    developer.log('POST $uri → ${response.statusCode}\n$rawBody', name: 'API');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: $rawBody');
    }
  }

  Future<void> _deleteJson(String baseUrl, String path) async {
    final normalizedBaseUrl = baseUrl.trim().replaceFirst(RegExp(r'/$'), '');
    final uri = Uri.parse('$normalizedBaseUrl$path');
    final response = await _client
        .delete(uri)
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw Exception(
            'Request timeout: $uri\n請確認後端已啟動，或把 Base URL 改成正確位址。',
          ),
        );
    final rawBody = utf8.decode(response.bodyBytes);
    developer.log('DELETE $uri → ${response.statusCode}\n$rawBody', name: 'API');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: $rawBody');
    }
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
    developer.log('GET $uri → ${response.statusCode}\n$rawBody', name: 'API');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: $rawBody');
    }

    return jsonDecode(rawBody);
  }
}

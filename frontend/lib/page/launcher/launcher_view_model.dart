import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../response/rating_response.dart';
import '../../response/restaurant_response.dart';
import '../../utils/http_request_utils.dart';

class LauncherViewModel extends ChangeNotifier {
  LauncherViewModel() {
    _apiClient = RestaurantApiClient();
    baseUrlController = TextEditingController(text: _apiClient.defaultBaseUrl);
    userIdController = TextEditingController(text: '1');
    loadRestaurants();
  }

  late final RestaurantApiClient _apiClient;
  late final TextEditingController baseUrlController;
  late final TextEditingController userIdController;

  int get currentUserId => int.tryParse(userIdController.text.trim()) ?? 1;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<RestaurantResponse> _restaurants = const [];
  List<RestaurantResponse> get restaurants => _restaurants;

  // Rating state: restaurantId -> list of ratings
  final Map<int, List<RatingResponse>> _ratingsMap = {};
  List<RatingResponse> ratingsFor(int restaurantId) =>
      _ratingsMap[restaurantId] ?? const [];

  double? averageScoreFor(int restaurantId) {
    final ratings = ratingsFor(restaurantId);
    if (ratings.isEmpty) return null;
    final total = ratings.fold<int>(0, (sum, r) => sum + r.score);
    return total / ratings.length;
  }

  /// Returns the current user's latest rating for a restaurant, or null.
  RatingResponse? userRatingFor(int restaurantId) {
    final ratings = ratingsFor(restaurantId);
    final userId = currentUserId;
    final userRatings = ratings.where((r) => r.userId == userId).toList();
    if (userRatings.isEmpty) return null;
    return userRatings.last;
  }

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  Future<void> loadRestaurants() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final restaurants = await _apiClient.fetchRestaurants(
        baseUrlController.text,
      );
      _restaurants = restaurants;
      // Load ratings for all restaurants
      await _loadAllRatings();
    } catch (error) {
      _errorMessage = '$error';
      _restaurants = const [];
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAllRatings() async {
    for (final restaurant in _restaurants) {
      try {
        final ratings = await _apiClient.fetchRatingsByRestaurant(
          baseUrlController.text,
          restaurant.id,
        );
        _ratingsMap[restaurant.id] = ratings;
      } catch (_) {
        _ratingsMap[restaurant.id] = const [];
      }
    }
  }

  Future<void> submitRating({
    required int restaurantId,
    required int score,
    String? comment,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      await _apiClient.submitRating(
        baseUrlController.text,
        restaurantId: restaurantId,
        userId: currentUserId,
        score: score,
        comment: comment,
      );
      // Reload ratings for this restaurant
      final ratings = await _apiClient.fetchRatingsByRestaurant(
        baseUrlController.text,
        restaurantId,
      );
      _ratingsMap[restaurantId] = ratings;
    } catch (error) {
      _errorMessage = '評分失敗：$error';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Weighted random pick.
  /// Weight = score weight * recency decay.
  /// - Score weight: average score (0~100), default 50 if no ratings.
  /// - Recency decay: if the current user rated this restaurant recently,
  ///   the weight is reduced. Recovers linearly over 30 days.
  ///   decay = min(daysSinceLastVisit / 30, 1.0), minimum 0.1.
  RestaurantResponse? pickRandomRestaurant() {
    if (_restaurants.isEmpty) return null;

    final random = Random();
    final now = DateTime.now();
    final weights = _restaurants.map((r) {
      final avg = averageScoreFor(r.id);
      final scoreWeight = avg ?? 50.0;

      // Find the current user's most recent rating for this restaurant
      final userRatings = ratingsFor(r.id)
          .where((rating) => rating.userId == currentUserId)
          .toList();

      double decay = 1.0;
      if (userRatings.isNotEmpty) {
        // Use createdAt to determine recency
        final latest = userRatings.last;
        if (latest.createdAt != null) {
          final lastDate = DateTime.tryParse(latest.createdAt!);
          if (lastDate != null) {
            final daysSince = now.difference(lastDate).inDays;
            decay = (daysSince / 30.0).clamp(0.1, 1.0);
          }
        }
      }

      return scoreWeight * decay;
    }).toList();

    final totalWeight = weights.fold<double>(0, (sum, w) => sum + w);
    if (totalWeight == 0) {
      return _restaurants[random.nextInt(_restaurants.length)];
    }

    var roll = random.nextDouble() * totalWeight;
    for (var i = 0; i < _restaurants.length; i++) {
      roll -= weights[i];
      if (roll <= 0) return _restaurants[i];
    }
    return _restaurants.last;
  }

  @override
  void dispose() {
    baseUrlController.dispose();
    userIdController.dispose();
    super.dispose();
  }
}


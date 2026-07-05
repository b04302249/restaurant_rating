import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../response/event_response.dart';
import '../../response/rating_response.dart';
import '../../response/restaurant_response.dart';
import '../../utils/http_request_utils.dart';

class LauncherViewModel extends ChangeNotifier {
  LauncherViewModel({required int initialUserId}) : _initialUserId = initialUserId {
    _apiClient = RestaurantApiClient();
    baseUrlController = TextEditingController(text: _apiClient.defaultBaseUrl);
    userIdController = TextEditingController(text: initialUserId.toString());
    loadRestaurants();
  }

  final int _initialUserId;
  late final RestaurantApiClient _apiClient;
  late final TextEditingController baseUrlController;
  late final TextEditingController userIdController;

  int get currentUserId =>
      int.tryParse(userIdController.text.trim()) ?? _initialUserId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<RestaurantResponse> _restaurants = const [];
  List<RestaurantResponse> get restaurants => _restaurants;

  List<EventResponse> _events = const [];
  List<EventResponse> get events => _events;

  String? _eventErrorMessage;
  String? get eventErrorMessage => _eventErrorMessage;

  // Rating helpers — ratings come embedded in restaurant response
  List<RatingResponse> ratingsFor(int restaurantId) {
    final restaurant = _restaurants.where((r) => r.id == restaurantId).firstOrNull;
    return restaurant?.ratings ?? const [];
  }

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
    _eventErrorMessage = null;
    notifyListeners();

    try {
      final restaurants = await _apiClient.fetchUserRestaurants(
        baseUrlController.text,
        currentUserId,
      );
      _restaurants = restaurants;
      await loadEvents();
    } catch (error, stackTrace) {
      _errorMessage = '$error\n$stackTrace';
      _restaurants = const [];
      _events = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEvents() async {
    try {
      _eventErrorMessage = null;
      _events = await _apiClient.fetchEvents(baseUrlController.text);
    } catch (error, stackTrace) {
      _eventErrorMessage = '活動載入失敗：$error\n$stackTrace';
      _events = const [];
    }
    notifyListeners();
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
      final restaurants = await _apiClient.fetchUserRestaurants(
        baseUrlController.text,
        currentUserId,
      );
      _restaurants = restaurants;
    } catch (error, stackTrace) {
      _errorMessage = '評分失敗：$error\n$stackTrace';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> addRestaurant(int restaurantId) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiClient.addUserRestaurant(
        baseUrlController.text,
        currentUserId,
        restaurantId,
      );
      await loadRestaurants();
    } catch (error, stackTrace) {
      _errorMessage = '加入餐廳失敗：$error\n$stackTrace';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> removeRestaurant(int restaurantId) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiClient.removeUserRestaurant(
        baseUrlController.text,
        currentUserId,
        restaurantId,
      );
      await loadRestaurants();
    } catch (error, stackTrace) {
      _errorMessage = '移除餐廳失敗：$error\n$stackTrace';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> createEvent({
    required String title,
    required String eventDate,
    int? restaurantId,
    List<int> participantUserIds = const [],
    List<int> ratingIds = const [],
  }) async {
    _isSubmitting = true;
    _eventErrorMessage = null;
    notifyListeners();

    try {
      await _apiClient.createEvent(
        baseUrlController.text,
        title: title,
        eventDate: eventDate,
        restaurantId: restaurantId,
        participantUserIds: participantUserIds,
        ratingIds: ratingIds,
      );
      await loadEvents();
    } catch (error, stackTrace) {
      _eventErrorMessage = '建立活動失敗：$error\n$stackTrace';
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
    final weights = computeWeights();
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

  /// Returns the raw weight for each restaurant (same order as [restaurants]).
  List<double> computeWeights() {
    final now = DateTime.now();
    return _restaurants.map((r) {
      final avg = averageScoreFor(r.id);
      final scoreWeight = avg ?? 50.0;

      final userRatings = ratingsFor(r.id)
          .where((rating) => rating.userId == currentUserId)
          .toList();

      double decay = 1.0;
      if (userRatings.isNotEmpty) {
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
  }

  /// Returns a map of restaurantId -> probability (0.0 ~ 1.0).
  Map<int, double> computeProbabilities() {
    final weights = computeWeights();
    final totalWeight = weights.fold<double>(0, (sum, w) => sum + w);
    if (totalWeight == 0) {
      final uniform = _restaurants.isEmpty ? 0.0 : 1.0 / _restaurants.length;
      return {for (final r in _restaurants) r.id: uniform};
    }
    return {
      for (var i = 0; i < _restaurants.length; i++)
        _restaurants[i].id: weights[i] / totalWeight,
    };
  }

  @override
  void dispose() {
    baseUrlController.dispose();
    userIdController.dispose();
    super.dispose();
  }
}

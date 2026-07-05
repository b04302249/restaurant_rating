import 'package:json_annotation/json_annotation.dart';

import 'rating_response.dart';

part 'restaurant_response.g.dart';

@JsonSerializable()
class RestaurantResponse {
  const RestaurantResponse({
    required this.id,
    required this.name,
    required this.area,
    required this.category,
    required this.address,
    this.ratings = const [],
  });

  final int id;
  final String name;
  final String? area;
  final String? category;
  final String? address;
  final List<RatingResponse> ratings;

  factory RestaurantResponse.fromJson(Map<String, dynamic> json) =>
      _$RestaurantResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantResponseToJson(this);
}

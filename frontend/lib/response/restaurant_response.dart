import 'package:json_annotation/json_annotation.dart';

part 'restaurant_response.g.dart';

@JsonSerializable()
class RestaurantResponse {
  const RestaurantResponse({
    required this.id,
    required this.name,
    required this.area,
    required this.category,
    required this.address,
  });

  final int id;
  final String name;
  final String? area;
  final String? category;
  final String? address;

  factory RestaurantResponse.fromJson(Map<String, dynamic> json) =>
      _$RestaurantResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantResponseToJson(this);
}

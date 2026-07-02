import 'package:json_annotation/json_annotation.dart';

part 'routes_response.g.dart';

@JsonSerializable()
class RoutesResponse {
  const RoutesResponse({
    required this.users,
    required this.restaurants,
    required this.ratings,
    required this.events,
    required this.ping,
    required this.health,
  });

  final String users;
  final String restaurants;
  final String ratings;
  final String events;
  final String ping;
  final String health;

  factory RoutesResponse.fromJson(Map<String, dynamic> json) =>
      _$RoutesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RoutesResponseToJson(this);
}

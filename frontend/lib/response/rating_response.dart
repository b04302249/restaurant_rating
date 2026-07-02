import 'package:json_annotation/json_annotation.dart';

part 'rating_response.g.dart';

@JsonSerializable()
class RatingResponse {
  const RatingResponse({
    required this.id,
    required this.restaurantId,
    required this.userId,
    required this.eventId,
    required this.score,
    required this.comment,
    required this.visitedAt,
    required this.createdAt,
  });

  final int id;
  final int restaurantId;
  final int? userId;
  final int? eventId;
  final int score;
  final String? comment;
  final String? visitedAt;
  final String? createdAt;

  factory RatingResponse.fromJson(Map<String, dynamic> json) =>
      _$RatingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RatingResponseToJson(this);
}

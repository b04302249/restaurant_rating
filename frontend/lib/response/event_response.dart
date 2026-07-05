import 'package:json_annotation/json_annotation.dart';

part 'event_response.g.dart';

@JsonSerializable()
class EventResponse {
  const EventResponse({
    required this.id,
    required this.title,
    required this.eventDate,
    required this.restaurantId,
    required this.participantUserIds,
    required this.ratingIds,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String eventDate;
  final int? restaurantId;
  final List<int> participantUserIds;
  final List<int> ratingIds;
  final String? createdAt;

  factory EventResponse.fromJson(Map<String, dynamic> json) =>
      _$EventResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EventResponseToJson(this);
}

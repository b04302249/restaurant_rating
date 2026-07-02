// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RatingResponse _$RatingResponseFromJson(Map<String, dynamic> json) =>
    RatingResponse(
      id: (json['id'] as num).toInt(),
      restaurantId: (json['restaurantId'] as num).toInt(),
      userId: (json['userId'] as num?)?.toInt(),
      eventId: (json['eventId'] as num?)?.toInt(),
      score: (json['score'] as num).toInt(),
      comment: json['comment'] as String?,
      visitedAt: json['visitedAt'] as String?,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$RatingResponseToJson(RatingResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'restaurantId': instance.restaurantId,
      'userId': instance.userId,
      'eventId': instance.eventId,
      'score': instance.score,
      'comment': instance.comment,
      'visitedAt': instance.visitedAt,
      'createdAt': instance.createdAt,
    };

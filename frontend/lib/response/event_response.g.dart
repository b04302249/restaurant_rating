// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventResponse _$EventResponseFromJson(Map<String, dynamic> json) =>
    EventResponse(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      eventDate: json['eventDate'] as String,
      restaurantId: (json['restaurantId'] as num?)?.toInt(),
      participantUserIds: (json['participantUserIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      ratingIds: (json['ratingIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$EventResponseToJson(EventResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'eventDate': instance.eventDate,
      'restaurantId': instance.restaurantId,
      'participantUserIds': instance.participantUserIds,
      'ratingIds': instance.ratingIds,
      'createdAt': instance.createdAt,
    };

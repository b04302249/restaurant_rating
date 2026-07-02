// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoutesResponse _$RoutesResponseFromJson(Map<String, dynamic> json) =>
    RoutesResponse(
      users: json['users'] as String,
      restaurants: json['restaurants'] as String,
      ratings: json['ratings'] as String,
      events: json['events'] as String,
      ping: json['ping'] as String,
      health: json['health'] as String,
    );

Map<String, dynamic> _$RoutesResponseToJson(RoutesResponse instance) =>
    <String, dynamic>{
      'users': instance.users,
      'restaurants': instance.restaurants,
      'ratings': instance.ratings,
      'events': instance.events,
      'ping': instance.ping,
      'health': instance.health,
    };

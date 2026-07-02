// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestaurantResponse _$RestaurantResponseFromJson(Map<String, dynamic> json) =>
    RestaurantResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      area: json['area'] as String?,
      category: json['category'] as String?,
      address: json['address'] as String?,
      note: json['note'] as String?,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$RestaurantResponseToJson(RestaurantResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'area': instance.area,
      'category': instance.category,
      'address': instance.address,
      'note': instance.note,
      'createdAt': instance.createdAt,
    };

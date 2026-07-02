import 'package:json_annotation/json_annotation.dart';

part 'ping_response.g.dart';

@JsonSerializable()
class PingResponse {
  const PingResponse({required this.status});

  final String status;

  factory PingResponse.fromJson(Map<String, dynamic> json) =>
      _$PingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PingResponseToJson(this);
}

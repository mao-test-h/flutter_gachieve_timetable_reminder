import 'package:json_annotation/json_annotation.dart';

part 'json_slack_info.g.dart';

@JsonSerializable()
class JsonSlackInfo {
  JsonSlackInfo(this.token, this.memberId);

  @JsonKey(required: true)
  final String token;

  @JsonKey(required: true)
  final String memberId;

  factory JsonSlackInfo.fromJson(Map<String, dynamic> json) =>
      _$JsonSlackInfoFromJson(json);

  Map<String, dynamic> toJson() => _$JsonSlackInfoToJson(this);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_slack_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JsonSlackInfo _$JsonSlackInfoFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['token', 'memberId'],
  );
  return JsonSlackInfo(
    json['token'] as String,
    json['memberId'] as String,
  );
}

Map<String, dynamic> _$JsonSlackInfoToJson(JsonSlackInfo instance) =>
    <String, dynamic>{
      'token': instance.token,
      'memberId': instance.memberId,
    };

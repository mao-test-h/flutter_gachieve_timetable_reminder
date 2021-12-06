// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_live.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JsonTimeTable _$JsonTimeTableFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['timeTable', 'liveDate'],
  );
  return JsonTimeTable(
    (json['timeTable'] as List<dynamic>)
        .map((e) => JsonLive.fromJson(e as Map<String, dynamic>))
        .toList(),
    json['liveDate'] as String,
  );
}

Map<String, dynamic> _$JsonTimeTableToJson(JsonTimeTable instance) =>
    <String, dynamic>{
      'timeTable': instance.timeTable,
      'liveDate': instance.liveDate,
    };

JsonLive _$JsonLiveFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['startLiveTime', 'diffMinute'],
  );
  return JsonLive(
    json['startLiveTime'] as String,
    json['diffMinute'] as int,
  );
}

Map<String, dynamic> _$JsonLiveToJson(JsonLive instance) => <String, dynamic>{
      'startLiveTime': instance.startLiveTime,
      'diffMinute': instance.diffMinute,
    };

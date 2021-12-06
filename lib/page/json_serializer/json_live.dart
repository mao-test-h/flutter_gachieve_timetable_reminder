import 'package:json_annotation/json_annotation.dart';

part 'json_live.g.dart';

@JsonSerializable()
class JsonTimeTable {
  JsonTimeTable(this.timeTable, this.liveDate);

  @JsonKey(required: true)
  final List<JsonLive> timeTable;

  @JsonKey(required: true)
  final String liveDate;

  factory JsonTimeTable.fromJson(Map<String, dynamic> json) =>
      _$JsonTimeTableFromJson(json);

  Map<String, dynamic> toJson() => _$JsonTimeTableToJson(this);
}

@JsonSerializable()
class JsonLive {
  JsonLive(this.startLiveTime, this.diffMinute);

  @JsonKey(required: true)
  final String startLiveTime;

  @JsonKey(required: true)
  final int diffMinute;

  factory JsonLive.fromJson(Map<String, dynamic> json) =>
      _$JsonLiveFromJson(json);

  Map<String, dynamic> toJson() => _$JsonLiveToJson(this);
}

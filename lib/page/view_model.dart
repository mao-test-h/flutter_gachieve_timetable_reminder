import 'dart:convert' as convert;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gachieve_timetable_reminder/page/json_serializer/json_live.dart';
import 'package:gachieve_timetable_reminder/page/json_serializer/json_slack_info.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainViewModel extends ChangeNotifier {
  /// 永続化用のキー
  static const String _persistenceKey =
      'gachieve_timetable_reminder@persistenceKey';

  var _liveDate = DateTime.now();
  final _timeTable = <Live>[];

  var _slackMemberId = '';
  var _slackToken = '';

  /// Slack情報の読み込み
  Future loadSlackInfo() async {
    final jsonStr = await rootBundle.loadString('assets/slack_info.json');
    final slackInfo = JsonSlackInfo.fromJson(convert.jsonDecode(jsonStr));
    _slackMemberId = slackInfo.memberId;
    _slackToken = slackInfo.token;
  }

  /// 配信日
  DateTime get liveDate => _liveDate;

  /// 現在設定されているタイムテーブル
  List<Live> get timeTable => _timeTable;

  /// 配信日の設定
  set liveDate(DateTime liveDate) {
    _liveDate = liveDate;
    for (var i = 0; i < _timeTable.length; ++i) {
      _timeTable[i].liveDate = liveDate;
    }
    notifyListeners();
  }

  /// ライブを追加
  void addLive() {
    _timeTable.add(Live(_liveDate));
    notifyListeners();
  }

  /// ライブの削除
  void removeLive() {
    // NOTE: 面倒臭いから最後のを消す
    _timeTable.removeLast();
    notifyListeners();
  }

  /// ライブの全消し
  Future clearLive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _timeTable.clear();
    _liveDate = DateTime.now();
    debugPrint('クリアしました');
    notifyListeners();
  }

  /// 「時」の設定
  void setHour(int index, String hourStr) {
    final hour = int.tryParse(hourStr);
    if (hour == null) {
      return;
    }

    _timeTable[index].hour = hour;
    notifyListeners();
  }

  /// 「分」の設定
  void setMinute(int index, String minuteStr) {
    final minute = int.tryParse(minuteStr);
    if (minute == null) {
      return;
    }

    _timeTable[index].minute = minute;
    notifyListeners();
  }

  /// 「差」の設定
  void setDiffMinute(int index, String diffStr) {
    final diff = int.tryParse(diffStr);
    if (diff == null) {
      return;
    }

    _timeTable[index].diffMinute = diff;
    notifyListeners();
  }

  /// 送信
  Future<bool> onSubmit() async {
    if (_slackMemberId.isEmpty || _slackToken.isEmpty) {
      debugPrint('Slackの情報が未設定');
      return false;
    }

    var result = true;
    debugPrint('タイムテーブル');
    for (var i = 0; i < _timeTable.length; ++i) {
      final live = _timeTable[i];

      final showStartLiveTimeStr = showTimeFormatter.format(live.startLiveTime);
      final startLiveTimeStr = sendTimeFormatter.format(live.startLiveTime);
      final collectTimeStr = sendTimeFormatter.format(live.collectTime);
      final throwTimeStr = sendTimeFormatter.format(live.throwTime);

      debugPrint('    指定時刻: $startLiveTimeStr, '
          '星集め: $collectTimeStr, '
          '星捨て: $throwTimeStr');

      // 「星集め」のリマインダーの設定
      result =
          await _callSlackApi('星集め ($showStartLiveTimeStr)', collectTimeStr);
      if (!result) {
        break;
      }

      // 「捨て星」のリマインダーの設定
      result = await _callSlackApi('捨て星 ($showStartLiveTimeStr)', throwTimeStr);
      if (!result) {
        break;
      }
    }

    if (!result) {
      debugPrint('failed');
      return false;
    }

    debugPrint('complete');
    return true;
  }

  /// 保存
  Future onSave() async {
    final lives = <JsonLive>[];
    for (var i = 0; i < _timeTable.length; ++i) {
      final live = _timeTable[i];
      final startLiveTimeStr = sendTimeFormatter.format(live.startLiveTime);
      lives.add(JsonLive(startLiveTimeStr, live.diffMinute));
    }

    final liveDateStr = sendTimeFormatter.format(_liveDate);
    final timeTable = JsonTimeTable(lives, liveDateStr);
    final jsonStr = convert.jsonEncode(timeTable.toJson());
    debugPrint('保存します: $jsonStr}');
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_persistenceKey, jsonStr);
  }

  /// 復元
  Future restore() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_persistenceKey)) {
      debugPrint('データが存在しません');
      return;
    }

    final jsonStr = prefs.getString(_persistenceKey)!;
    final timeTable = JsonTimeTable.fromJson(convert.jsonDecode(jsonStr));
    _liveDate = DateTime.parse(timeTable.liveDate);
    _timeTable.clear();
    for (var i = 0; i < timeTable.timeTable.length; ++i) {
      final jsonLive = timeTable.timeTable[i];
      _timeTable.add(Live.restore(
          DateTime.parse(jsonLive.startLiveTime), jsonLive.diffMinute));
    }

    debugPrint('復元完了');
    notifyListeners();
  }

  /// Slack APIのリクエスト
  Future<bool> _callSlackApi(String text, String timeStr) async {
    final requestHeader = {
      HttpHeaders.contentTypeHeader: 'application/json ',
      HttpHeaders.authorizationHeader: 'Bearer $_slackToken',
    };

    try {
      var dio = Dio();
      final Response<String> response = await dio.post(
        'https://slack.com/api/reminders.add',
        data: {
          'text': text,
          'time': timeStr,
          'user': _slackMemberId,
        },
        options: Options(
          headers: requestHeader,
        ),
      );

      var body =
          convert.jsonDecode(response.data.toString()) as Map<String, dynamic>;
      return body['ok'] as bool;
    } on DioError catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}

/// Slackリマインダーに送信するDateFormat
final sendTimeFormatter = DateFormat('yyyy-MM-dd HH:mm');

/// 表示用途で使うDateFormat
final showTimeFormatter = DateFormat('HH:mm');

/// ライブ情報
class Live {
  /// [liveDate]には配信日を、[initDiffMinute]には「差」の初期値を指定
  Live(DateTime liveDate)
      : _startLiveTime = DateTime(
          liveDate.year,
          liveDate.month,
          liveDate.day,
        ),
        diffMinute = 0;

  /// 復元用
  Live.restore(this._startLiveTime, this.diffMinute);

  DateTime _startLiveTime;

  /// 配信開始時間
  DateTime get startLiveTime => _startLiveTime;

  /// 「時」
  int get hour => _startLiveTime.hour;

  /// 「分」
  int get minute => _startLiveTime.minute;

  /// 「差」
  int diffMinute;

  /// 「星集め」の時間
  DateTime get collectTime =>
      _calcStarCollectTime(_startLiveTime, diffMinute: diffMinute);

  /// 「捨て星」の時間
  DateTime get throwTime =>
      _calcStarThrowTime(_startLiveTime, diffMinute: diffMinute);

  /// 配信日の設定
  set liveDate(DateTime liveDate) {
    _startLiveTime = DateTime(
      liveDate.year,
      liveDate.month,
      liveDate.day,
      _startLiveTime.hour,
      _startLiveTime.minute,
    );
  }

  /// 「時」の設定
  set hour(int hour) {
    _startLiveTime = DateTime(
      _startLiveTime.year,
      _startLiveTime.month,
      _startLiveTime.day,
      hour,
      _startLiveTime.minute,
    );
  }

  /// 「分」の設定
  set minute(int minute) {
    _startLiveTime = DateTime(
      _startLiveTime.year,
      _startLiveTime.month,
      _startLiveTime.day,
      _startLiveTime.hour,
      minute,
    );
  }

  /// 配信開始時間から星集めの時刻を逆算して返す
  DateTime _calcStarCollectTime(
    DateTime startLiveTime, {
    int diffMinute = 0,
  }) {
    // 50分前 - 差分の分を加算
    final minute = 50 - diffMinute;
    // 星集めは1時間前固定
    return startLiveTime.subtract(Duration(hours: 1, minutes: minute));
  }

  /// 配信開始時間から捨て星の時刻を逆算して返す
  DateTime _calcStarThrowTime(
    DateTime startLiveTime, {
    int diffMinute = 0,
  }) {
    // 50分前 - 差分の分を加算
    final minute = 50 - diffMinute;
    return startLiveTime.subtract(Duration(minutes: minute));
  }
}

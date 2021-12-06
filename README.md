# flutter_gachieve_timetable_reminder

![Flutter](https://img.shields.io/badge/Flutter-2.5.3-50c8fa)
![Dart](https://img.shields.io/badge/language-Dart%202.14.4-1b6ac0)


## Getting Started

先ずは`./assets/slack_info.json`を開き、ローカルで必要な情報の設定を行う。

```json
{
    "token" : "Slack APIから取得した「User OAuth Token」",
    "memberId" : "メンバーID ([プロフィール -> その他]より参照可能)"
}
```

ちなみにSlackAPI側でアプリを作成する際に求められる権限(Scopes)は`reminders:write`を設定しておけばOK。


### ※Flutter on Desktopで動かす場合

こちらはβリリース故に幾つかの追加要件や設定が求められることがある。  
詳細については以下のドキュメントを参照すること。  

- [Desktop support for Flutter](https://docs.flutter.dev/desktop)



# LICENSES

- [cupertino_icons](https://pub.dev/packages/cupertino_icons/license)
- [dio](https://pub.dev/packages/dio/license)
- [intl](https://pub.dev/packages/intl/license)
- [provider](https://pub.dev/packages/provider/license)
- [json_annotation](https://pub.dev/packages/json_annotation/license)
- [shared_preferences](https://pub.dev/packages/shared_preferences/license)
- [flutter_lints](https://pub.dev/packages/flutter_lints/license)
- [build_runner](https://pub.dev/packages/build_runner/license)
- [json_serializable](https://pub.dev/packages/json_serializable/license)

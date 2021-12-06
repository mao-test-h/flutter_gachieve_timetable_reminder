import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gachieve_timetable_reminder/page/view_model.dart';
import 'package:gachieve_timetable_reminder/page/widgets/text_field_ex.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MainView extends StatefulWidget {
  MainView({Key? key}) : super(key: key);
  final _viewModel = MainViewModel();

  @override
  State<StatefulWidget> createState() => _MainState();
}

class _MainState extends State<MainView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await widget._viewModel.loadSlackInfo();
      await widget._viewModel.restore();
    });
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => widget._viewModel,
        child: _BodyWidget(),
      );
}

class _BodyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ガチイベ タイムテーブル リマインダー'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 配信日の設定
            _SelectLiveDateWidget(),

            // タイムテーブルタイトル
            const Padding(padding: EdgeInsets.only(top: 32)),
            _TimeTableTitleWidget(),

            // タイムテーブル
            const Padding(padding: EdgeInsets.only(top: 8)),
            _TimeTableWidget(),

            // 決定
            const Padding(padding: EdgeInsets.only(top: 64)),
            _MenuWidget(),
          ],
        ),
      ),
    );
  }
}

/// 配信日の設定
class _SelectLiveDateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainViewModel>();
    final dayFormatter = DateFormat('yyyy-MM-dd');
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('配信日 : ${dayFormatter.format(viewModel.liveDate)}'),
        const Padding(padding: EdgeInsets.only(top: 8)),
        ElevatedButton(
          onPressed: () => _selectDay(context, viewModel),
          child: const Text('日付選択'),
        ),
      ],
    );
  }

  Future _selectDay(BuildContext context, MainViewModel viewModel) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime.now().add(
        const Duration(days: 360),
      ),
    );

    if (picked != null) {
      viewModel.liveDate = picked;
      debugPrint('選択した日付: ${picked.toString()}');
    }
  }
}

/// タイムテーブルタイトル
class _TimeTableTitleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<MainViewModel>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 追加
        const Padding(padding: EdgeInsets.only(left: 8)),
        IconButton(
          onPressed: viewModel.addLive,
          icon: const Icon(Icons.add),
        ),

        // 削除
        IconButton(
          onPressed: viewModel.removeLive,
          icon: const Icon(Icons.remove),
        ),

        const Text(
          'タイムテーブル',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// タイムテーブル
class _TimeTableWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainViewModel>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (int i = 0; i < viewModel.timeTable.length; ++i)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _LiveSettingWidget(index: i),
            ],
          ),
      ],
    );
  }
}

/// ライブごとの設定
class _LiveSettingWidget extends StatelessWidget {
  const _LiveSettingWidget({
    Key? key,
    required this.index,
  }) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainViewModel>();
    final live = viewModel.timeTable[index];
    final numFormat = NumberFormat('00');
    return SizedBox(
      width: 300,
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 時間入力欄
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 「時」の設定
              SizedBox(
                width: 32,
                child: TextFieldEx(
                  labelText: '時',
                  hintText: '',
                  textAlign: TextAlign.center,
                  initText: numFormat.format(live.hour),
                  onChanged: (hourStr) {
                    viewModel.setHour(index, hourStr);
                  },
                ),
              ),

              // 「分」の設定
              const Text(' : '),
              SizedBox(
                width: 32,
                child: TextFieldEx(
                  labelText: '分',
                  hintText: '',
                  textAlign: TextAlign.center,
                  initText: numFormat.format(live.minute),
                  onChanged: (minuteStr) {
                    viewModel.setMinute(index, minuteStr);
                  },
                ),
              ),

              const Padding(padding: EdgeInsets.only(left: 8)),
              const Text(' diff : '),
              // 差分の設定
              SizedBox(
                width: 32,
                child: TextFieldEx(
                  labelText: '差',
                  hintText: '',
                  textAlign: TextAlign.center,
                  initText: numFormat.format(live.diffMinute),
                  onChanged: (diffStr) {
                    viewModel.setDiffMinute(index, diffStr);
                  },
                ),
              ),
            ],
          ),

          //
          const Padding(padding: EdgeInsets.only(top: 8)),
          Text(
            '指定時刻: ${showTimeFormatter.format(live.startLiveTime)}, '
            '星集め: ${showTimeFormatter.format(live.collectTime)}, '
            '星捨て: ${showTimeFormatter.format(live.throwTime)}',
          ),
        ],
      ),
    );
  }
}

/// メニュー
class _MenuWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<MainViewModel>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            final ret = await viewModel.onSubmit();
            if (!ret) {
              const snackBar = SnackBar(
                content: Text('Slackへの送信に失敗'),
                backgroundColor: Colors.red,
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          },
          child: const Text(
            '送信',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        // 保存と初期化
        const Padding(padding: EdgeInsets.only(top: 32)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 保存
            ElevatedButton(
              onPressed: () async {
                await viewModel.onSave();
              },
              child: const Text(
                '保存',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            // クリア
            const Padding(padding: EdgeInsets.only(left: 32)),
            ElevatedButton(
              onPressed: () async {
                await viewModel.clearLive();
              },
              child: const Text(
                'クリア',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        )
      ],
    );
  }
}

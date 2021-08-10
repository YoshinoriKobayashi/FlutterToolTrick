// BLoC
/*
- _actionControllerでボタンによるカウントアップ入力を受け付けます
- _actionControllerに流れてきた値を使って、_countControllerにカウントアップした値を流します。
-- わざわざ二つStreamControllerを使っているのは、型が異なるためです
*/

import 'dart:async';

class CounterBloc {
  // 制御するストリームをもつコントローラー。
  // このコントローラーを使用すると、ストリームでデータ、エラー、および完了イベントを送信できます。
  // このクラスを使用して、他の人がリッスンできる単純なストリームを作成し、そのストリームにイベントをプッシュできます。
  // https://api.dart.dev/stable/2.13.3/dart-async/StreamController-class.html

  // finalが指定された変数は、プログラム開始後のある時点で一回だけ初期化され、
  // 初期化以降は、代入などを通じて変更されない/できないことが保証される(再代入不可)。
  // なお、finalな変数が「指す先」のメモリ領域の内容が変更されることについての制約はない。
  final _actionController = StreamController<void>();
  // getメソッド。incrementはメソッド名。
  // sinkはデータを流す
  Sink<void> get increment => _actionController.sink;

  final _countController = StreamController<int>();
  // stream:listen()メソッドなどで、値が流れてきた時に自動で行う処理を設定できる。
  Stream<int> get count => _countController.stream;

  int _count = 0;

  CounterBloc() {
    _actionController.stream.listen((_) {
      _count++;
      _countController.sink.add(_count);
    });
  }

  void dispose() {
    _actionController.close();
    _countController.close();
  }
}

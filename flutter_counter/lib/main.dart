// https://github.com/felangel/bloc/tree/master/examples/flutter_counter
// こちらのサンプルコードを写経して解析したもの

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'counter_observer.dart';

void main() {
  // 作成したCountrrObserverを初期化する
  Bloc.observer = CounterObserver();
  // CounterAppウィジェットを使用してrunAppを呼び出す
  runApp(const CounterApp());
}


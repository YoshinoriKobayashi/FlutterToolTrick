/// CounterApp は MaterialApp になり、ホームを CounterPage として指定します。

import 'package:flutter/material.dart';
import 'counter/counter.dart';

/// {@template counter_app}
/// A [MaterialApp] which sets the 'home' to [CounterPage].
/// {@endtemplagte}
class CounterApp extends MaterialApp {
  /// {@macro counter_app}
  const CounterApp({Key? key}) : super(key: key, home: const CounterPage());
}
/// 注意：CounterAppはMaterialAppであるため、MaterialAppを拡張しています
/// ほとんどの場合、StatelessWidgetまたはStatefulWidgetインスタンスを作成し、
/// ビルドでウィジェットを作成しますが、この場合、作成するウィジェットがないため、MaterialAppを拡張する方が簡単
import "package:bloc/bloc.dart";

// 最初に確認するのは、アプリケーションのすべての状態変化を監視するのに役立つBlocObseverを作成する方法です。

/// {@template counter_observer}
/// [BlocObserver] for the counter application which
/// observer all state changes
/// {@endtemplate}
class CounterObserver extends BlocObserver {
  // この場合、発生するすべての状態変化を確認するためにonChangeをオーバーライドするだけです。
  @override
  void onChange(BlocBase bloc, Change change) {
    print('-------- onChangeスタート');
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }
}
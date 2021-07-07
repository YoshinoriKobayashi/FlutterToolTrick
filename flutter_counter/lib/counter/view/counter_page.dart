import 'dart:developer';

/// CounterPageウィジェットは、CounterCubitを作成し、それをCounterViewに提供する役割を果たします。

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../counter.dart';
import 'counter_view.dart';

/// {@template counter_page}
/// A [StatelessWidget] which is responsible for providing a
/// [CounterCubit] instance to the [CounterView].
/// {@endtemplate}
class CounterPage extends StatelessWidget {
  /// {@macro counter_page}
  const CounterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterCubit(),
      child: CounterView(),
    );
  }
}
/// 注意：テスト可能で再利用可能なコードを作成するには、Cubitの作成をCubitの消費から分離または分離することが重要

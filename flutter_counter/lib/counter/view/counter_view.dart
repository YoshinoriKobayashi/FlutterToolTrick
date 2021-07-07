import 'dart:developer';

import 'package:flutter/foundation.dart';
/// 次に、状態の消費とCounterCubitとの対話を担当するCounterViewを見てみましょう
/// CounterViewは、現在のカウントをレンダリングし、2つのFloatingActionButtonをレンダリングしてカウンターをインクリメント／デクリメントする

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_counter/counter/cubit/counter_cubit.dart';

import '../counter.dart';

/// {@template counter_view}
/// A [StatelessWidget] which reacts to the provided
/// [CounterCubit] state and notifies it in response to user input.
/// {@endtemplate}
///
///
/// プレゼンテーション層をビジネスロジック層から分離しました。
/// CounterViewは、ユーザーがボタンを押したときに何が起こるかを知りません。
/// CounterCubitに通知するだけです。
/// さらに、CounterCubitは状態（カンター値）で何が起こっているのかわかりません。
/// 呼び出されたメソッドに応答して、単純に新しい状態を発行しているだけです。

class CounterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        /// BlocBuilderは、CounterCubitの状態が変化するたびにテキストを更新するために
        /// テキストウィジェットをラップするために使用されます。
        /// さらに、context.read<CounterCubit>()を使用して、
        /// 最も近いCounterCubitインスタンスを検索します。
        ///
        /// CounterCubitの状態変化に応じて再構築する必要があるウィジットは、
        /// 状態が変化したときに再構築する必要のないウィジットを不必要にラップすることを避けてください。
        child: BlocBuilder<CounterCubit, int>(
          builder: (context, state) {
            return Text('$state', style: textTheme.headline2);
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget> [
          FloatingActionButton(
             key: const Key('counterView_increment_floatingActionButton'),
            child: const Icon(Icons.add),
            onPressed: () => context.read<CounterCubit>().increment(),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            key: const Key('counterView_decrement_floatingActionButton'),
            child: const Icon(Icons.remove),
            onPressed: () => context.read<CounterCubit>().decrement(),
          )
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_counter_bloc/counter_bloc.dart';
import 'package:provider/provider.dart';

// 次の記事を参考にカスタマイズ
// https://qiita.com/tetsufe/items/521014ddc59f8d1df581

// 元のコードの問題
// ボタンを押すたびにsetState()でbuild()メソッドを呼び出しているため、ページ全体がリビルドされてしまい、非効率
// カウンターの値を他のページや他のWidgetで使いたい時に不便
// BLoCでこれらを解決していきます。

// BLoCを使った構成
/*
- MyApp
-- MyHomePage( StatelessWidget )
--- counterBloc
--- Scaffold
---- StreamBuilder
----- Text
---- FloatingActionButton
*/
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // childパラメータに指定したWidget以下全てのWidgetで、同じBLoCインスタンスにアクセスすることができます。
      home: Provider<CounterBloc>(
        create: (context) => CounterBloc(),
        // disposeパラメータを使って、Widgetとblocの生存期間を一緒にします。これをしないと必要ないblocがいつまでも残ってしまうことになります。
        dispose: (context, bloc) => bloc.dispose(),
        child: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({this.title});

  final String title;

  // BLoCは、MyHomePage（子Widget）のbuild()メソッドで呼ぶのが定番です。
  @override
  Widget build(BuildContext context) {
    final counterBloc = Provider.of<CounterBloc>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'You have pushed the button this many times:',
                  ),
                  //
                  // StreamBuilder でBLoCの値を受け取る
                  // StreamBuilderを使って、Streamの値を反映します。
                  // StreamBuilderを使うことで、build()メソッドを呼ぶことなくStreamの値に応じてこの箇所だけUIを更新することができます。
                  // このStreamBuilderのおかげで、MyHomePage()ウィジェットはStatefulWidgetからStatelessWidgetに置き換えることができていることに気付いたでしょうか。
                  StreamBuilder(
                    initialData: 0,
                    stream: counterBloc.count,
                    builder: (context, snapshot) {
                      return Text(
                        '${snapshot.data}',
                        style: Theme
                            .of(context)
                            .textTheme
                            .display1,
                      );
                    },
                  )
                ]
            )
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Sink<T>.add()
            // ここでは、counterBloc.increment の中でしている。
            // カウントアップアクションをBloCに送る
            counterBloc.increment.add(null)
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
    );
  }

}

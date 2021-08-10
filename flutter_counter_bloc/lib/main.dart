import 'package:flutter/material.dart';

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
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ここのカウンターの値を他のページや他のWidgetで使いたい時に不便
  int _counter = 0;

  // + ボタンをタップされたとき
  void _incrementCounter() {
    // StatefulWidgetでは、setState()というメソッドを通じてフレームワーク側に
    // 画面更新が必要であることを通知します。
    // あとは、フレームワーク側でbuild()メソッドが実行されるので、
    // プログラマーは必要な画面表示処理をbuild()メソッド内に実装します。
    setState(() {
      // ボタンを押すたびにsetState()でbuild()メソッドを呼び出しているため、ページ全体がリビルドされてしまい、非効率
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      // +のアクションボタン
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

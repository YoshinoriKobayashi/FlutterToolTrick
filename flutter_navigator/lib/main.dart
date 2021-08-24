import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 事前にroutesを定義する場合
    // /homeのようなルーティング名称に対して、表示されるページを作成しウィジェットを設定します
    return MaterialApp(
      home: MainPage(),
      routes: <String, WidgetBuilder> {
        '/home': (BuildContext context) => new MainPage(),
        '/subpage': (BuildContext context) => new SubPage()
      },
    );
  }
}
class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Navigator'),
      ),
      body: new Container(
        padding: new EdgeInsets.all(32.0),
        child: new Center(
          child: new Column(
            children: <Widget>[
              Text('Main'),
              RaisedButton(onPressed: () => Navigator.of(context).pushNamed("/subpage"), child: new Text('Subページへ'),)
            ],
          ),
        ),
      ),
    );
  }
}
class SubPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Navigator'),
      ),
      body: new Container(
        padding: new EdgeInsets.all(32.0),
        child: new Center(
          child: new Column(
            children: <Widget>[
              Text('Sub'),
              RaisedButton(onPressed: () => Navigator.of(context).pop(), child: new Text('戻る'),)
            ],
          ),
        ),
      ),
    );
  }
}

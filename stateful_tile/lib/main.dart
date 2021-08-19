import 'package:flutter/material.dart';
import 'package:hello_world/statefulTile.dart';
void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  late List<Widget> tiles;
  @override
  void initState() {
    super.initState();
    //2つのStatefulWidgetが準備
    tiles = [
      StatefulTile(),
      StatefulTile(),
    ];
  }
  // 入れ替え処理
  void changeTiles() {
    setState(() {
      tiles.insert(1, tiles.removeAt(0));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Row(children: tiles),
      floatingActionButton: FloatingActionButton(
        onPressed: changeTiles,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

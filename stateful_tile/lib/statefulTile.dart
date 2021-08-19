import 'dart:math';
import 'package:flutter/material.dart';
class StatefulTile extends StatefulWidget {
  StatefulTile({Key key}) : super(key: key);
  @override
  _StatefulTileState createState() => _StatefulTileState();
}
class _StatefulTileState extends State<StatefulTile> {
  Color _color = Colors.black;
  var _random = new Random();
  // initStateで色を設定する
  @override
  void initState() {
    super.initState();
    _color = Color.fromRGBO(
        _random.nextInt(256), _random.nextInt(256), _random.nextInt(256), 1);
  }
  // ビルド内では色は最初に作ったものを使う
  @override
  Widget build(BuildContext context) {
    print("build");
    return Container(color: _color, height: 100, width: 100);
  }
}

import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _imgSrc = "images/pa.png";
  // じゃんけんの結果を格納する変数
  // （0=初期画面、1=グー、2=チョキ、3=パー）
  var _answerNumber = 0;

  void _setImg() {
    // setStateを使うことによって、その変更が伝わり変更要素とその親要素を更新します。
    setState(() {
      // 新しいじゃんけんの結果を一時的に格納する変数を設ける
      final _newAnswerNumber = math.Random().nextInt(3);

      switch (num) {
        case 0:
          _imgSrc = "images/pa.png";
          break;
        case 1:
          _imgSrc = "images/gu.png";
          break;
        default:
          _imgSrc = "images/choki.png";
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:
        Container(
          padding: EdgeInsets.all(10),
          child:
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.asset(_imgSrc),
              ElevatedButton(onPressed: _setImg,
                  style: ButtonStyle(padding:MaterialStateProperty.all(EdgeInsets.all(10.0))),
                      child: Text('じゃんけんをする', style: TextStyle(fontSize: 30)))
            ]),
          )
    );
  }
}

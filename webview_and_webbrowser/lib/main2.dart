// WebBrowser

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> openBrowserTab() async {
    // FlutterWebBrowser.openWebPage でブラウザを別ページで開く
    await FlutterWebBrowser.openWebPage(url: "https://moneyworld.jp/news");
  }

  List<BrowserEvent> _events = [];

  StreamSubscription<BrowserEvent> _browserEvents;

  @override
  void initState() {
    super.initState();
    _browserEvents = FlutterWebBrowser.events().listen((event) {
      setState(() {
        _events.add(event);
      });
    });
  }

  @override
  void dispose() {
    _browserEvents?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RaisedButton(
                  // warmup 準備し始める
                  onPressed: () => FlutterWebBrowser.warmup(),
                  child: new Text('Warmup browser website'),
                ),
                RaisedButton(
                  onPressed: () => openBrowserTab(),
                  child: new Text('Open Flutter website'),
                ),
                RaisedButton(
                  onPressed: () => openBrowserTab().then(
                    // 5秒たつとブラウザをクローズ
                    (value) => Future.delayed(
                      Duration(seconds: 5),
                      () => FlutterWebBrowser.close(),
                    ),
                  ),
                  child:
                      new Text('Open Flutter website & close after 5 seconds'),
                ),
                if (Platform.isAndroid) ...[
                  Text('test Android customizations'),
                  RaisedButton(
                    onPressed: () {
                      FlutterWebBrowser.openWebPage(
                        url: "https://moneyworld.jp/news",
                        customTabsOptions: CustomTabsOptions(
                          colorScheme: CustomTabsColorScheme.dark,
                          toolbarColor: Colors.deepPurple,
                          secondaryToolbarColor: Colors.amber,
                          addDefaultShareMenuItem: true,
                          instantAppsEnabled: true,
                          showTitle: true,
                          urlBarHidingEnabled: true,
                        ),
                      );
                    },
                    child: Text('custom Browser'),
                  ),
                ],
                if (Platform.isIOS) ...[
                  Text('test iOS customizations'),
                  RaisedButton(
                    onPressed: () {
                      FlutterWebBrowser.openWebPage(
                        url: "https://moneyworld.jp/news",
                        // Safariをカスタマイズ
                        safariVCOptions: SafariViewControllerOptions(
                          barCollapsingEnabled: true,
                          preferredBarTintColor: Colors.green,
                          preferredControlTintColor: Colors.amber,
                          dismissButtonStyle:
                              SafariViewControllerDismissButtonStyle.close,
                          modalPresentationCapturesStatusBarAppearance: true,
                        ),
                      );
                    },
                    child: Text('custom Browser'),
                  ),
                  Divider(),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _events.map((e) {
                      if (e is RedirectEvent) {
                        return Text('redirect: ${e.url}');
                      }
                      if (e is CloseEvent) {
                        return Text('closed');
                      }

                      return Text('Unknown event: $e');
                    }).toList(),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}

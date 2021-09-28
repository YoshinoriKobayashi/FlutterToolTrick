import 'dart:async';
/// -----------------------------------
///          External Packages
/// -----------------------------------

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth0.dart';

final FlutterAppAuth appAuth = FlutterAppAuth();
const FlutterSecureStorage secureStorage = FlutterSecureStorage();

/// -----------------------------------
///           Profile Widget
/// -----------------------------------
// このウィジェットは、ユーザーがログインするとユーザープロファイル情報を表示するビューを定義します。また、ログアウトボタンも表示します。
///StatelessWidgetの表示内容を変更するためには、再作成が必要です。通常は初回表示時と親部品が更新されるタイミングで再作成されます。
class Profile extends StatelessWidget {
  final Future<void> Function() logoutAction;
  final String name;
  final String picture;

  // 初期化
  const Profile(this.logoutAction, this.name, this.picture, {Key key})
      : super(key: key);

  /// StatelessWidgetでは、インスタンスの作成時に画面表示処理であるbuild()メソッドが実行されます
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 4),
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(picture ?? ''),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Name: $name'),
        const SizedBox(height: 48),
        RaisedButton(
          onPressed: () async {
            /// ログアウト
            await logoutAction();
          },
          child: const Text('Logout'),
        ),
      ],
    );
  }
}

/// -----------------------------------
///            Login Widget
/// -----------------------------------
/// このウィジェットは、Auth0によってまだ認証されていないユーザーにアプリが表示するビューを定義します。認証プロセスを開始できるように、ログインボタンが表示されます。
class Login extends StatelessWidget {
  final Future<void> Function() loginAction;
  final String loginError;

  const Login(this.loginAction, this.loginError, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          onPressed: () async {
            // ログインボタン
            await loginAction();
          },
          child: const Text('Login'),
        ),
        Text(loginError ?? ''),
      ],
    );
  }
}

/// -----------------------------------
///                 App
/// -----------------------------------

void main() => runApp(const MyApp());

// 最初に動く
// setState()というメソッドを通じてフレームワーク側に画面更新が必要であることを通知
class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  // 状態の管理とその状態に依存する表示を定義するStateというクラスを継承したクラスを作成します
  @override
  _MyAppState createState() => _MyAppState();
}

/// -----------------------------------
///              App State
/// -----------------------------------

class _MyAppState extends State<MyApp> {
  // ローディング状態を示す
  bool isBusy = false;
  // ログイン状態：trueでログイン済み
  bool isLoggedIn = false;
  //
  String errorMessage;
  String name;
  String picture;

  // ------------------------------
  // ビルド時にユーザーインターフェースを条件付きでレンダリングする
  // 最後に、build()メソッドを以下のように更新します。
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth0 Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Auth0 Demo'),
        ),
        body: Center(
          // 三項演算子
          child: isBusy
              ? const CircularProgressIndicator() // isBusy:true
              : isLoggedIn
                  ? Profile(logoutAction, name, picture) // isLoggedIn:true
              : Login(loginAction, errorMessage),
        ),
      ),
    );
  }

  // 連想配列<データ型>の関数戻り値
  // トークンをパース
  Map<String, Object> parseIdToken(String idToken) {
    final List<String> parts = idToken.split('.');
    assert(parts.length == 3);

    return jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
  }
  // Futureは、すぐには完了しない計算を表します。通常の関数が結果を返す場合、非同期関数はFutureを返します
  // ユーザーの詳細を取得
  Future<Map<String, Object>> getUserDetails(String accessToken) async {
    const String url = 'https://$AUTH0_DOMAIN/userinfo';
    final http.Response response = await http.get(
      url,
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user details');
    }
  }

  // ログインのアクション
  Future<void> loginAction() async {
    // 更新が必要なことを通知する
    setState(() {
      isBusy = true;
      errorMessage = '';
    });

    try {
      print("◆◆◆loginAction");
      // PKCE 認証コードフローの開始から、コールバックで認証コードを取得し、
      // それをアーティファクトトークンのセットと交換するまでのエンドツーエンドのフローを処理します
      // 次に、AppAuth.authorizeAndExchangeCode()にAuthorizationTokenRequestオブジェクトを渡して、
      // サインイントランザクションを開始します。
      // サインイン・トランザクションが完了すると、ユーザーは認証サーバーで認証され、アプリケーションに戻ります。
      final AuthorizationTokenResponse result =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AUTH0_CLIENT_ID,
          AUTH0_REDIRECT_URI,
          issuer: 'https://$AUTH0_DOMAIN',
          scopes: <String>['openid', 'profile', 'offline_access'],
          //　promptValuesがないとサイレントログインになるみたい
            // ログアウト→ログイン→ログイン状態になる
          // promptValues: ['none']
          // ログアウト→ログイン→ログイン画面が表示される→ログイン状態になる
          // promptValues: ['login']
        ),
      );

      final Map<String, Object> idToken = parseIdToken(result.idToken);
      final Map<String, Object> profile =
          await getUserDetails(result.accessToken);

      print("◆◆◆idToken:${idToken}");
      print("◆◆◆profile:${profile}");
      print("◆◆◆result.accessToken:${result.accessToken}");
      print("◆◆◆result.refreshToken:${result.refreshToken}");

      await secureStorage.write(
          key: 'refresh_token', value: result.refreshToken);

      // 更新が必要なことを通知する
      setState(() {
        isBusy = false;
        isLoggedIn = true;
        name = idToken['name'];
        picture = profile['picture'];
      });
    } on Exception catch (e, s) {
      debugPrint('login error: $e - stack: $s');

      // 更新が必要なことを通知する
      setState(() {
        isBusy = false;
        isLoggedIn = false;
        errorMessage = e.toString();
      });
    }
  }

  // ログアウトのアクション
  Future<void> logoutAction() async {
    print("◆◆◆logoutAction");
    print("◆◆◆ローカルのリフレッシュトークンを削除");
    await secureStorage.delete(key: 'refresh_token');
    // 更新が必要なことを通知する
    setState(() {
      isLoggedIn = false;
      isBusy = false;
    });
  }

  // 初期化
  // FlutterのinitState()メソッドは、ステートフルなクラスを作成する際に使用される最初のメソッドで、ここで任意のウィジェットの変数、データ、プロパティなどを初期化することができます。
  @override
  void initState() {
    print("◆◆◆initState");
    initAction();

    //　タイマーをセット
    // periodicでスケジュール
    Timer.periodic(Duration(seconds: 10), _onTimer,);

    super.initState();
  }

  void _onTimer(Timer timer) {
    if (isLoggedIn) {
      print("ログイン済み");
    } else {
      print("ログインしていない");
    }
  }

  //
  Future<void> initAction() async {
    print("◆◆◆initAction");
    print("◆◆◆既存のリフレッシュトークンのチェック");
    // 既存のリフレッシュトークンのチェック
    final String storedRefreshToken =
        await secureStorage.read(key: 'refresh_token');
    print("◆◆◆storedRefreshToken:${storedRefreshToken}");
    if (storedRefreshToken == null) return;

    // 画面更新
    setState(() {
      isBusy = true;
    });

    try {
      print("◆◆◆トークンを取得");
      // トークンを取得
      final TokenResponse response = await appAuth.token(TokenRequest(
        AUTH0_CLIENT_ID,
        AUTH0_REDIRECT_URI,
        issuer: AUTH0_ISSUER,
        refreshToken: storedRefreshToken,
      ));

      final Map<String, Object> idToken = parseIdToken(response.idToken);
      final Map<String, Object> profile =
          await getUserDetails(response.accessToken);
      print("◆◆◆idToken:${idToken}");
      print("◆◆◆response.accessToken:${response.accessToken}");
      print("◆◆◆profile:${profile}");
      print("◆◆◆response.refreshToken:${response.refreshToken}");
      print("◆◆◆リフレッシュトークンを保存");
      // リフレッシュトークンを保存
      await secureStorage.write(
          key: 'refresh_token', value: response.refreshToken);

      // 画面更新
      setState(() {
        isBusy = false;
        isLoggedIn = true;
        name = idToken['name'];
        picture = profile['picture'];
      });
    } on Exception catch (e, s) {
      debugPrint('error on refresh token: $e - stack: $s');
      await logoutAction();
    }
  }
}

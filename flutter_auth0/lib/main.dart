/// -----------------------------------
///          External Packages
/// -----------------------------------

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final FlutterAppAuth appAuth = FlutterAppAuth();
const FlutterSecureStorage secureStorage = FlutterSecureStorage();

/// -----------------------------------
///           Auth0 Variables
/// -----------------------------------
// PKCEを使用した認証コード付与フローでは、クライアントシークレットは必要ありません。
// ファイル内のAuth0ドメインとAuth0クライアントIDを使用するだけで、Flutterアプリが接続するAuth0のテナント（ドメイン）とアプリケーション（クライアントID）を指定できます。
// Auth0に複数のテナントと複数のアプリケーションが登録されている場合があります。したがって、それらを指定することが重要です。
const AUTH0_DOMAIN = 'dev-os0it2sn.us.auth0.com';
const AUTH0_CLIENT_ID = 'c6KZrJ132epccERnWzbMRUmhjDI5CYx4';

const AUTH0_REDIRECT_URI = 'com.auth0.flutterdemo://login-callback';
const AUTH0_ISSUER = 'https://$AUTH0_DOMAIN';

/// -----------------------------------
///           Profile Widget
/// -----------------------------------
// このウィジェットは、ユーザーがログインするとユーザープロファイル情報を表示するビューを定義します。また、ログアウトボタンも表示します。
class Profile extends StatelessWidget {
  final Future<void> Function() logoutAction;
  final String name;
  final String picture;

  const Profile(this.logoutAction, this.name, this.picture, {Key key})
      : super(key: key);

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

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

/// -----------------------------------
///              App State
/// -----------------------------------

class _MyAppState extends State<MyApp> {
  bool isBusy = false;
  bool isLoggedIn = false;
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
          child: isBusy
              ? const CircularProgressIndicator()
              : isLoggedIn
                  ? Profile(logoutAction, name, picture)
                  : Login(loginAction, errorMessage),
        ),
      ),
    );
  }

  Map<String, Object> parseIdToken(String idToken) {
    final List<String> parts = idToken.split('.');
    assert(parts.length == 3);

    return jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
  }

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

  Future<void> loginAction() async {
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

      setState(() {
        isBusy = false;
        isLoggedIn = true;
        name = idToken['name'];
        picture = profile['picture'];
      });
    } on Exception catch (e, s) {
      debugPrint('login error: $e - stack: $s');

      setState(() {
        isBusy = false;
        isLoggedIn = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> logoutAction() async {
    print("◆◆◆logoutAction");
    await secureStorage.delete(key: 'refresh_token');
    setState(() {
      isLoggedIn = false;
      isBusy = false;
    });
  }

  @override
  void initState() {
    print("◆◆◆initState");
    initAction();
    super.initState();
  }

  Future<void> initAction() async {
    print("◆◆◆initAction");
    print("◆◆◆既存のリフレッシュトークンのチェック");
    // 既存のリフレッシュトークンのチェック
    final String storedRefreshToken =
        await secureStorage.read(key: 'refresh_token');
    print("◆◆◆storedRefreshToken:${storedRefreshToken}");
    if (storedRefreshToken == null) return;

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

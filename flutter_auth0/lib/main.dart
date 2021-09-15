// @dart=2.9
/// -----------------------------------
///          External Packages
/// -----------------------------------
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final FlutterAppAuth appAuth = FlutterAppAuth();
final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

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
  final logoutAction;
  final String name;
  final String picture;

  Profile(this.logoutAction, this.name, this.picture);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 4.0),
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(picture),
            ),
          ),
        ),
        SizedBox(height: 24.0),
        Text('Name: $name'),
        SizedBox(height: 48.0),
        RaisedButton(
          onPressed: () {
            logoutAction();
          },
          child: Text('Logout'),
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
  final loginAction;
  final String loginError;

  const Login(this.loginAction, this.loginError);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          onPressed: () {
            loginAction();
          },
          child: Text('Login'),
        ),
        Text(loginError),
      ],
    );
  }
}




/// -----------------------------------
///                 App
/// -----------------------------------

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

/// -----------------------------------
///              App State
/// -----------------------------------

class _MyAppState extends State<MyApp> {
  bool isBusy = false;
  bool isLoggedIn = false;
  String errorMessage = '';
  String name = '';
  String picture = '';

  // ------------------------------
  // ビルド時にユーザーインターフェースを条件付きでレンダリングする
  // 最後に、build()メソッドを以下のように更新します。
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth0 Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Auth0 Demo'),
        ),
        body: Center(
          child: isBusy
              ? CircularProgressIndicator()
              : isLoggedIn
              ? Profile(logoutAction, name, picture)
              : Login(loginAction, errorMessage),
        ),
      ),
    );
  }

// AppAuthとの統合
//
// 認可サーバーに対するAppAuthの設定の最初のステップは、OAuth 2.0のエンドポイントURLを設定することです。
// 今回のサンプルアプリケーションには、3つのエンドポイントが含まれています。
//
// Authorization endpoint:
// リダイレクトベースのログインを開始し、コールバックで認証コードを受け取るために使用します。
// Auth0では、その値は https://TENANT.auth0.com/authorize です。
//
// トークンエンドポイント：
// 認証コードやリフレッシュトークンを新しいアクセストークンやIDトークンと交換するために使用します。
// Auth0では、その値は https://TENANT.auth0.com/oauth/token です。
//
// Userinfo エンドポイント：
// 認証サーバーからユーザーのプロファイル情報を取得するために使用します。
// Auth0では、その値は https://TENANT.auth0.com/userinfo です。
//
// OpenID Connectは、OAuth 2.0をベースにした認証用プロトコルです。
// OpenID Connectは、JSONドキュメントで認証サーバーのエンドポイントを発見する標準的な方法として、OpenID Connect Discoveryを導入しました。
// Auth0では、テナント・アドレスの/.well-known/openid-configurationエンドポイントでディスカバリー・ドキュメントを見つけることができます。
// このデモでは、それが https://YOUR-AUTH0-TENANT-NAME.auth0.com/.well-known/openid-configuration です。
//
// AppAuthはエンドポイントを設定するための3つの方法をサポートしています。
// 最も便利なのは、トップレベルドメイン名 (すなわち発行者) を AppAuth のメソッドにパラメータとして渡すだけです。
// AppAuth は、openid-configuration エンドポイントからディスカバリー・ドキュメントを内部的に取得し、後続のリクエストをどこに送ればよいかを判断します。
//
// {
//   "given_name": "Amin",
//   "family_name": "Abbaspour",
//   "nickname": "a.abbaspour",
//   "name": "Amin Abbaspour",
//   "picture": "https://lh3.googleusercontent.com/a-/AOh14GglAu_nSbRx6Wd5RBdN_tcH2xq0bFAaiVr9lPQCsyg",
//   "locale": "en",
//   "updated_at": "2020-05-29T04:55:44.158Z",
//   "email": "XXX@gmail.com",
//   "email_verified": true,
//   "iss": "https://flutterdemo.auth0.com/",
//   "sub": "google-oauth2|XXX",
//   "aud": "1b1NvfMVq6DP621IvegS7RB8XAsKD049",
//   "iat": 1590728144,
//   "exp": 1590764144,
//   "nonce": "mynonce"
// }

// クライアントにとって不透明で、API で消費されるべき accessToken とは異なり、OpenID Connect クライアントは受け取った idToken を検証する責任があります。
// 幸いなことに、AppAuth SDK がそれを代行してくれるので、検証をスキップしてボディをデコードすることができます。

// parseIdToken()を_MyAppStateクラスのメソッドとして以下のように実装します。
  Map<String, dynamic> parseIdToken(String idToken) {
    final parts = idToken.split(r'.');
    assert(parts.length == 3);

    return jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
  }

// getUserDetailsでユーザーのプロファイル情報を取得する
// 前のセクションではidTokenを調べ、name claimからユーザーのフルネームを取得しました。
// プロフィール画面で表示する必要のあるもう一つの属性は、ユーザーの写真です。
// 画像のURLもidToken JSONオブジェクトの一部であることにお気づきでしょうか。
// ユーザーのプロフィール情報を取得する別の方法を示すために、getUserDetails()メソッドを実装することにします。
// このメソッドは accessToken を受け取り、それを bearer authorization ヘッダーとして /userinfo エンドポイントに送信します。
// 結果は JSON オブジェクトで、それをパースして Future<Map> オブジェクトで返します。
//  getUserDetails()メソッドを以下のように実装します。
  Future<Map<String, dynamic>> getUserDetails(String accessToken) async {
    print("◆◆◆getUserDetails");
    final url = 'https://$AUTH0_DOMAIN/userinfo';
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user details');
    }
  }

// この記事ではユーザーの詳細情報を取得する用途に限定していますが、
// 頻繁にAPIを呼び出す必要のある大規模なアプリケーションのライフサイクルを通じて、
// accessTokenを生かしておくべきです。その改善は熱心な読者にお任せします。
// getTokenSilently()メソッドのコードをご覧になれば、
// JavaScriptでアクセストークンキャッシュを実装する方法のヒントが得られるでしょう。


// 単一のメソッド appAuth.authorizeAndExchangeCode() は、PKCE 認証コードフローの開始から、
// コールバックで認証コードを取得し、それをアーティファクトトークンのセットと交換するまでのエンドツーエンドのフローを処理します。
// loginAction()メソッドを以下のように実装します。
//
  Future<void> loginAction() async {
    print("◆◆◆loginAction");
    setState(() {
      isBusy = true;
      errorMessage = '';
    });

    try {
      // その後、AppAuth.authorizeAndExchangeCode()にAuthorizationTokenRequestオブジェクトを渡すことで、サインイントランザクションを開始します。
      // サインインが完了すると、ユーザーは認可サーバーで認証され、アプリケーションに戻ります。
      final AuthorizationTokenResponse result =
      await appAuth.authorizeAndExchangeCode(
        // まず、いくつかのパラメータを渡して、AuthorizationTokenRequestオブジェクトを作成します。
        // clientIDとredirectUrlは必須のパラメータで、それぞれAUTH0_CLIENT_IDとAUTH0_REDIRECT_URIの値に対応しています。
        // issuerパラメータは、前のセクションで説明したように、エンドポイントの発見を可能にします。
        AuthorizationTokenRequest(
          AUTH0_CLIENT_ID,
          AUTH0_REDIRECT_URI,
          issuer: 'https://$AUTH0_DOMAIN',
          // scopesパラメータは、ユーザがユーザに代わってアプリケーションに実行を許可する特定のアクションを定義します。渡された3つのスコープで、許可を要求します。
          // openid:openid connect sign-inを行う。
          // profile:ユーザープロファイルを取得します。
          // offline_access:アプリケーションからoffline_access用のリフレッシュトークンを取得します。
          scopes: ['openid', 'profile', 'offline_access'],
          // 完全なセキュア・ログアウトはこの記事の範囲外ですが、loginAction()メソッド内でprompt=loginパラメータを追加で渡し、
          // その結果変数の定義からpromptValuesの行をアンコメントすることで、
          // Authorization Serverにインタラクティブ・ログインを要求することができることを述べておきます。
          // promptValues: ['login']
        ),
      );

      // AuthorizationTokenResponseの結果オブジェクトの中には、3つのトークンが入っています。
      // idToken: JWT形式のユーザープロファイル情報。
      final idToken = parseIdToken(result.idToken);
      print("◆◆◆idToken:${idToken}");
      // accessToken: OAuth 2.0のアーティファクトで、アプリケーションがユーザーに代わってセキュアなAPIを呼び出すことを可能にします。
      final profile = await getUserDetails(result.accessToken);
      print("◆◆◆profile:${profile}");

      // refreshToken：新しいaccessTokenとidTokenを取得するためのトークンです。
      await secureStorage.write(
          key: 'refresh_token', value: result.refreshToken);
      print("◆◆◆result.refreshToken:${result.refreshToken}");
      // 実際のシナリオでは、アプリの機能に応じて、より多くのスコープが必要になることは言うまでもありません。
      // 例えば、ユーザーがSpotifyのライブラリを一覧表示したり編集したりするアプリケーションでは、
      // user-library-readとuser-library-modifyのスコープが必要になります。
      // また、先に定義した parseIdToken() を使用して ID トークンを取得し、
      // getUserDetails() を使用してユーザーのプロファイル情報を取得します。
      // 最後に、secureStorage.write()を使用してrefreshTokenトークンの値をローカルに保存し、
      // ログイン・ユーザー・エクスペリエンスを合理化することができます。
      setState(() {
        isBusy = false;
        isLoggedIn = true;
        name = idToken['name'];
        picture = profile['picture'];
      });
    } catch (e, s) {
      print('login error: $e - stack: $s');

      setState(() {
        isBusy = false;
        isLoggedIn = false;
        errorMessage = e.toString();
      });
    }
  }

  // ログアウトは単純に以下のように実装されています。
  void logoutAction() async {
    print("◆◆◆logoutAction");
    // logoutAction()メソッドでは、まずストレージからrefreshTokenを削除し、次にisLoggedInの状態をfalseに戻します。
    await secureStorage.delete(key: 'refresh_token');
    setState(() {
      isLoggedIn = false;
      isBusy = false;
    });
  }

  // このシンプルなログアウト方法では、ブラウザから認証サーバ（AS）のセッションが削除されません。
  // つまり、ASセッションの有効性によっては、次に「ログイン」を押したときに、ブラウザへのリダイレクトと戻ってくるまでの間、
  // ログインプロンプトが表示されず、シームレスな体験ができる可能性があるのです
  // 個人所有のデバイスではそれほど気にならないかもしれませんが、共有デバイスでは気になるところです。

  // ------------------------------

  // initActionとinitStateによるユーザー認証状態の処理
  // offline_accessスコープでAuthorization Codeフローを開始しました。
  // これは、認証時にトークン・エンドポイントから返されるリフレッシュ・トークンが追加されていることを意味します。
  // リフレッシュ・トークンを使うと、ユーザーが認可サーバーにサインインしていなくても、新しいアクセス・トークンやIDトークンを取得できます。
  // リフレッシュ・トークンを使用することで、ユーザーがアプリを起動するたびに再認証する必要はありません。
  // その代わり、利用可能なリフレッシュ・トークンがあれば、それを使って新しいアクセストークンを静かに取得することができます。
  // flutter_secure_storageは、機密性の高いアプリケーションデータを保存・取得するためのシンプルなCRUD操作を公開するライブラリです。
  // アプリケーションを起動すると、initState()メソッドは、既存のリフレッシュトークンがあるかどうかをチェックします。
  // 既存のリフレッシュ・トークンがある場合は、appAuth.token()メソッドを呼び出して新しいアクセストークンを取得しようとします。
  // 以下は、_MyAppStateクラスに追加するメソッドです。
  @override
  void initState() {
    print("◆◆◆initState");
    initAction();
    super.initState();
  }

  // initAction()は、既存のアクセストークンの有効性にかかわらず、アクセストークンを更新することに注意してください。
  // このコードをさらに最適化するには、accessTokenExpirationDateTimeを追跡し、
  // 手元のアクセストークンが期限切れになった場合にのみ新しいアクセストークンを要求するようにします。
  void initAction() async {
    print("◆◆◆initAction");
    final storedRefreshToken = await secureStorage.read(key: 'refresh_token');
    if (storedRefreshToken == null) return;

    setState(() {
      isBusy = true;
    });
    try {
      final response = await appAuth.token(TokenRequest(
        AUTH0_CLIENT_ID,
        AUTH0_REDIRECT_URI,
        issuer: AUTH0_ISSUER,
        refreshToken: storedRefreshToken,
      ));

      final idToken = parseIdToken(response.idToken);
      print("◆◆◆idToken: ${idToken}");

      final profile = await getUserDetails(response.accessToken);
      print("◆◆◆profile: ${profile}");

      secureStorage.write(key: 'refresh_token', value: response.refreshToken);
      print("◆◆◆response.refreshToken: ${response.refreshToken}");

      setState(() {
        isBusy = false;
        isLoggedIn = true;
        name = idToken['name'];
        picture = profile['picture'];
      });
    } catch (e, s) {
      print('error on refresh token: $e - stack: $s');
      logoutAction();
    }
  }
}

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';



// メソッド：1行の関数またはメソッドには矢印表記を使用します。
void main() => runApp(MyApp());

// StatelessWidgetなウィジェット
class MyApp extends StatelessWidget {
  @override
  // ウィジェットの主な仕事はbuild()
  // 他の下位レベルのウィジェットの観点からウィジェットを表示する方法を説明するメソッドを提供することです。
  // ビルドメソッドは、MaterialAppレンダリングが必要になるたびに、またはFlutterInspectorでプラットフォームを切り替えるときに実行されます。
  Widget build(BuildContext context) {
    // ランダムな英語を取得
    // final wordPair = WordPair.random();
    // Scaffoldマテリアルライブラリのウィジェットは、デフォルトのアプリバーと、
    // ホーム画面のウィジェットツリーを保持するbodyプロパティを提供します。
    // ウィジェットのサブツリーは非常に複雑になる可能性があります。
    return MaterialApp(
      // MyAppクラスのbuild()メソッドを更新し、タイトルを変更し、ホームをRandomWordsウィジェットに変更します。
      title: 'Startup Name Generator',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: RandomWords(),
      //   appBar: AppBar(
      //     title: const Text('Welcome to Flutter'),
      //   ),
      //   body: Center(
      //     // child: Text(wordPair.asPascalCase),
      //     child: RandomWords(),
      //   ),
      // ),
    );
  }
}

// デフォルトでは、クラスの名前の前にアンダーバーが付いています。
// 識別子の前にアンダースコアを付けると、Dart言語でプライバシーが強化され、オブジェクトのベストプラクティスとして推奨されます。
class RandomWords extends StatefulWidget {
  @override
  // インポートディレクティブとライブラリディレクティブは、モジュール化された共有可能なコードベースを作成するのに役立ちます。
  // ライブラリは、APIを提供するだけでなく、プライバシーの単位でもあります。
  // アンダースコア(_)で始まる識別子は、ライブラリの中でのみ表示されます。
  // すべてのDartアプリは、たとえlibraryディレクティブを使用していなくても、libraryです。
  // ステートフルなウィジェットの名前としてRandomWordsを入力すると、IDEは自動的に付属のStateクラスを更新し、
  // _RandomWordsStateという名前を付けます。デフォルトでは、Stateクラスの名前の前にアンダーバーが付いています。
  // 識別子の前にアンダーバーを付けることで、Dart言語でのプライバシーが確保され、Stateオブジェクトのベスト・プラクティスとして推奨されています。

  _RandomWordsState createState() => _RandomWordsState();
}
// また、IDE は State クラスを自動的に更新して State<RandomWords> を拡張し、
// RandomWords での使用に特化した汎用 State クラスを使用していることを示します。
// アプリのロジックのほとんどはこのクラスにあり、RandomWordsウィジェットの状態を維持しています。
// このクラスは、生成された単語ペアのリストを保存します。
// このリストは、ユーザーがスクロールすると無限に増えていきます。
// また、この研究室のパート2では、ユーザーがハートのアイコンをトグルしてリストに追加したり削除したりすると、お気に入りの単語ペアを保存します。

// _RandomWordsStateを拡張して、単語のペアリングのリストを生成して表示します。
// ユーザーがスクロールすると、リスト(ListViewウィジェットに表示)は無限に増えていきます。
// ListViewのビルダーファクトリコンストラクタは、必要に応じてリストビューを構築することができます。
class _RandomWordsState extends State<RandomWords> {
  // RandomWordsStateクラスに、提案された単語の組み合わせを保存するための_suggestionsリストを追加しました。
  // また、フォントサイズを大きくするための_biggerFont変数を追加しました。
  final _suggestions = <WordPair>[];
  // ユーザーがお気に入りに追加した単語のペアを保存
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18.0);

  // RandomWordsStateクラスのbuild()メソッドを更新し、単語生成ライブラリを直接呼び出すのではなく、
  // _buildSuggestions()を使用するようにしました。(ScaffoldはMaterial Designの基本的なビジュアルレイアウトを実装しています。)
  // Flutter では、Navigator がアプリのルートを含むスタックを管理します。
  // Navigator のスタックにルートをプッシュすると、表示がこのルートに更新されます。Navigator のスタックからルートをポップすると、表示が前のルートに戻ります。
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        // ユーザーがリストアイコンをクリックすると、保存したお気に入りを含む新しいルートが Navigator にプッシュされ、アイコンが表示されます。
        // ヒント: 一部のウィジェット プロパティは 1 つのウィジェット（child）を受け取ります。
        // action などの他のプロパティは、角かっこ（[]）で図示されるように、ウィジェットの配列（children）を受け取ります。
        actions: [
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        ],
        ),
        body: _buildSuggestions(),
      );
  }
 // このメソッドは、提案された単語のペアを表示するListViewを構築します。
  // _buildSuggestions（）関数は、単語ペアごとに1回_buildRow（）を呼び出します。
  // この関数は、ListTileに新しいペアを表示します。これにより、次のステップで行をより魅力的にすることができます。
  Widget _buildSuggestions() {
    // ListViewクラスは、無名関数として指定されたファクトリビルダーおよびコールバック関数であるビルダープロパティitemBuilderを提供します。
    // 2つのパラメーターが関数に渡されます。BuildContextと行イテレーターです。
    // イテレータは0から始まり、関数が呼び出されるたびにインクリメントします。
    // 提案された単語のペアごとに2回増分します。
    // 1回はListTile用、もう1回はDivider用です。 このモデルにより、ユーザーがスクロールしても、提案されたリストが増え続けることができます。
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
        // itemBuilderコールバックは、提案された単語のペアごとに1回呼び出され、
        // 各提案をListTileの行に配置します。
        // 偶数行の場合、この関数は単語ペアのListTile行を追加します。
        // 奇数行では、エントリを視覚的に分離するためにDividerウィジェットが追加されます。
        // なお、小さなデバイスでは仕切りが見づらいかもしれません。
      itemBuilder: (context,i) {
        // ListViewの各行の前に、1ピクセルの高さのディバイダー・ウィジェットを追加します。
        // isOdd この整数が奇数の場合にのみtrueを返します。
        if (i.isOdd) return const Divider();
        // i ~/ 2という式は、iを2で割り、結果を整数で返します。例えば、1,2,3,4,5は0,1,1,2,2になります。
        // これはListViewの中の単語ペアリングの実際の数を計算し、ディバイダーウィジェットを除いたものです。
        final index = i ~/ 2;
        if (index >= _suggestions.length) {
          // 利用可能な単語ペアの数が限界に達した場合は、さらに10個生成して候補リストに追加します。
          _suggestions.addAll(generateWordPairs().take(10));
        }
        // _buildSuggestions（）関数は、単語ペアごとに1回_buildRow（）を呼び出します。
        // この関数は、ListTileに新しいペアを表示します。これにより、次のステップで行をより魅力的にすることができます。
        return _buildRow(_suggestions[index]);
      });
  }
  Widget _buildRow(WordPair pair) {
    // 単語のペアがすでにお気に入りに追加されていないことを確認するために alreadySaved チェックを追加します。
    final alreadySaved = _saved.contains((pair));
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      // ListTile オブジェクトにハート形のアイコンを追加して、お気に入り機能を有効
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      // ハートアイコンをタップ可能にします。
      // ユーザーがリスト内のエントリをタップしてお気に入りの状態を切り替えると、保存されているお気に入りのセットに対して単語のペアの追加または削除を行えます。
      // 単語がすでにお気に入りに追加されている場合は、その単語をもう一度タップするとお気に入りから削除できます。
      // タイルがタップされると、関数は setState() を呼び出して、状態が変更されたことをフレームワークに通知します。
      onTap: () {
        // Flutter のリアクティブ スタイル フレームワークでは、setState() を呼び出すと State オブジェクトの build() メソッドが呼び出され、UI が更新されます。
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },
    );
  }
  void _pushSaved() {
    // ルートを作成して Navigator のスタックにプッシュします。
    // この操作により、新しいルートを表示するように画面が変わります。
    // 新しいページのコンテンツは、匿名関数の MaterialPageRoute の builder プロパティに作成されます。
    Navigator.of(context).push(
      // 次に、MaterialPageRoute とそのビルダーを追加します。
      // ここでは、ListTile 行を生成するコードを追加します。
      MaterialPageRoute<void>(
        // builder プロパティは、SavedSuggestions という名前の新しいルートのアプリバーを含む Scaffold を返します。
        // 新しいルートの本文は、ListTiles 行を含む ListView で構成されています。各行は分割線で区切ります。
        builder: (BuildContext context) {
          final tiles = _saved.map(
              (WordPair pair) {
                return ListTile(
                  title: Text(
                    pair.asPascalCase,
                    style: _biggerFont,
                  ),
                );
              },
          );
          // ListTile の divideTiles() メソッドは、各 ListTile の間に水平方向の間隔を追加します。
          // divided 変数は、簡易関数である toList() によってリストに変換された最終行を保持します。
          final divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();
          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }
}

import 'package:boardgame_io/boardgame.dart' as bgio;
import 'package:flutter/material.dart';

import 'src/tic_tac_toe.dart';

void main() {
  runApp(TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'boardgame.io Tic-Tac-Toe Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Boardgame.io Tic-Tac-Toe Example Home Page'),
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
  bgio.Lobby lobby = bgio.Lobby(Uri.base);
  bgio.Client? clientX;
  bgio.Client? clientO;
  bgio.Client? bannerClient;

  @override
  void initState() {
    super.initState();
    _createMatch();
  }

  Future<bgio.Client> _join(bgio.Game game, bgio.MatchData matchData, int index, String name) {
    return lobby.joinMatch(game, matchData.players[index].id, name);
  }

  void _createMatch() async {
    bgio.GameDescription description = bgio.GameDescription('tic-tac-toe', 2);
    bgio.MatchData matchData = await lobby.createMatch(description);
    bgio.Game game = matchData.toGame();

    bgio.Client clientX = await _join(game, matchData, 0, 'Player X');
    bgio.Client clientO = await _join(game, matchData, 1, 'Player O');
    bgio.Client bannerClient = lobby.watchMatch(game);

    setState(() {
      this.clientX = clientX;
      this.clientO = clientO;
      this.bannerClient = bannerClient;
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
            if (bannerClient != null) TicTacToeBanner(bannerClient!),
            SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (clientX != null) TicTacToePlayer(clientX!),
                SizedBox(width: 100),
                if (clientO != null) TicTacToePlayer(clientO!),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createMatch,
        tooltip: 'New Game',
        child: Icon(Icons.add),
      ),
    );
  }
}

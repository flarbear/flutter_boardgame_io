import 'package:boardgame_io/boardgame.dart' as bgio;
import 'package:flutter/material.dart';

abstract class TicTacToeBase extends StatefulWidget {
  TicTacToeBase(this.client);

  final bgio.Client client;
}

abstract class TicTacToeBaseState<T extends TicTacToeBase> extends State<T> {
  bgio.ClientContext _ctx;
  List<String> _cells;
  bool _isPlaying;

  void _setUp() {
    this._isPlaying = false;
    this._ctx = null;
    this._cells = List<String>.filled(9, null);
    widget.client.subscribe(_update);
    widget.client.start();
  }

  void _takeDown(T oldWidget) {
    oldWidget.client.leaveGame();
  }

  @override
  void initState() {
    super.initState();
    _setUp();
  }

  @override
  void didUpdateWidget(TicTacToeBase oldWidget) {
    _takeDown(oldWidget);
    super.didUpdateWidget(oldWidget);
    _setUp();
  }

  @override
  void dispose() {
    _takeDown(widget);
    super.dispose();
  }

  void _update(Map<String, dynamic> G, bgio.ClientContext ctx) {
    setState(() {
      if (ctx != null) {
        _isPlaying = !ctx.isGameOver && ctx.currentPlayer == widget.client.playerID;
        _ctx = ctx;
        _cells = G['cells'];
      }
    });
  }
}

class TicTacToePlayer extends TicTacToeBase {
  TicTacToePlayer(bgio.Client client) : super(client);

  @override
  State createState() => TicTacToePlayerState();
}

class TicTacToePlayerState extends TicTacToeBaseState<TicTacToePlayer> {
  void _clickCell(int index) {
    widget.client.makeMove('clickCell', [ index ]);
  }

  Widget _makeCell(Widget child, [ Color color ]) {
    if (color != null) {
      child = Container(color: color, child: child);
    } else if (child != null) {
      child = Center(child: child);
    }
    return SizedBox(
      width: 50,
      height: 50,
      child: child,
    );
  }

  Widget _cell(int index) {
    switch (_cells[index]) {
      case '0': return _makeCell(Text('X', textAlign: TextAlign.center));
      case '1': return _makeCell(Text('O', textAlign: TextAlign.center));
      default: return _isPlaying
          ? _makeCell(GestureDetector(onTap: () => _clickCell(index)), Colors.green.withAlpha(64))
          : _makeCell(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    Table grid = Table(
      defaultColumnWidth: FixedColumnWidth(50),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder(
        horizontalInside: BorderSide(),
        verticalInside:   BorderSide(),
      ),
      children: <TableRow>[
        TableRow(children: <Widget>[_cell(0), _cell(1), _cell(2)]),
        TableRow(children: <Widget>[_cell(3), _cell(4), _cell(5)]),
        TableRow(children: <Widget>[_cell(6), _cell(7), _cell(8)]),
      ],
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_ctx != null) Text(widget.client.playerName),
        SizedBox(height: 25),
        grid,
      ],
    );
  }
}

class TicTacToeBanner extends TicTacToeBase {
  TicTacToeBanner(bgio.Client client) : super(client);

  @override
  State createState() => TicTacToeBannerState();
}

class TicTacToeBannerState extends TicTacToeBaseState<TicTacToeBanner> {
  static const TextStyle style = TextStyle(fontSize: 48);

  @override
  Widget build(BuildContext context) {
    String status;
    if (_ctx == null) {
      status = 'Waiting for game to initialize...';
    } else {
      if (_ctx.isGameOver) {
        if (_ctx.isDraw) {
          status = 'Draw game';
        } else if (_ctx.winnerID != null) {
          status = '${widget.client.players[_ctx.winnerID].name} wins!';
        } else {
          status = 'Game over (${_ctx.gameOver})';
        }
      } else {
        bgio.Player player = widget.client.players[_ctx.currentPlayer];
        status = (player == null)
            ? 'Not all players have joined'
            : '${widget.client.players[_ctx.currentPlayer].name} to move';
      }
    }
    return Text(status, style: style);
  }
}

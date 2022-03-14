import 'package:flutter/material.dart';
import 'package:puzzle2/game_board.dart';
import 'package:puzzle2/themes.dart';

import 'dart:async';

import '../domain.dart';
import '../game_board.dart';
import '../game_ui/game_controller.dart';
import '../main.dart';
import '../style.dart';

BoxDecoration getBoxDecoration() {
  return BoxDecoration(
    color: Colors.teal, border: Border.all(color: Colors.tealAccent, width: 4),
    borderRadius: BorderRadius.circular(8),
    boxShadow: const [
      BoxShadow(color: Colors.black26, spreadRadius: 4, blurRadius: 10)
    ],
  );
}

class GameClock extends StatefulWidget {
  final Game game;
  const GameClock(this.game, {Key? key}) : super(key: key);

  @override
  State<GameClock> createState() => _GameClockState();
}

class _GameClockState extends State<GameClock> {
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Duration duration = DateTime.now().difference(widget.game.startTime);
    return Card(
      color: bg.withOpacity(.5),
      elevation: 10,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: Text(printDuration(duration)))
    );
  }
}

class ResultsWidget extends StatefulWidget {
  final Game game;
  const ResultsWidget(this.game, {Key? key,}) : super(key: key);

  @override
  State<ResultsWidget> createState() => _ResultsWidgetState();
}

class _ResultsWidgetState extends State<ResultsWidget>
    with SingleTickerProviderStateMixin, GameListener {
  int gamesPlayed = 0;
  int gamesWon = 0;
  int currentScore = 0;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    widget.game.addGameListener(this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        fontFamily: 'Poppins'
      ),
      child: Container(
        decoration: getBoxDecoration(),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Score', ),
            Text('$currentScore',),
            const SizedBox(height: 8,),
            Text('$gamesWon of $gamesPlayed games',)
          ],
        ),
      ),
    );
  }

  @override
  void gameWon() {
    setState(() {
      gamesWon++;
    });
  }

  @override
  void moveComplete(int score) {
    setState(() {
      currentScore = score;
    });
  }

  @override
  void moveStarted() {
  }

  @override
  void gameRestarted() {
    setState(() {
      gamesPlayed++;
    });
  }
}

class GameStartButton extends StatefulWidget {
  final GameController controller;
  final Game game;

  const GameStartButton(this.game, this.controller, {Key? key}) : super(key: key);

  @override
  State<GameStartButton> createState() => _GameStartButtonState();
}

class _GameStartButtonState extends State<GameStartButton>
  with SingleTickerProviderStateMixin, GameListener {

  late AnimationController _controller;

  bool canRestart = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    widget.game.addGameListener(this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: (){ widget.controller.reverseSolve();},
          child: Container(
            decoration: getBoxDecoration(),
            child: const Icon(Icons.help_outline),
          ),
        ),
        const SizedBox(width: 12,),
        GestureDetector(
          onTap: () { widget.controller.shuffle();},
          child: Container(
            decoration: getBoxDecoration(),
            child: const Icon(Icons.shuffle_outlined),
          ),
        ),
        const SizedBox(width: 12,),
        GestureDetector(
          onTap: () { _controller.forward(from: 0); widget.game.reset();},
          child: Container(
            decoration: getBoxDecoration(),
            child: RotationTransition(
              turns: _controller,
              child: const Icon(Icons.restart_alt_outlined),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void gameRestarted() {
    setState(() {
      canRestart = false;
    });
  }

  @override
  void gameWon() {
    setState(() {
      canRestart = false;
    });
  }

  @override
  void moveComplete(int score) {
    setState(() {
      canRestart = true;
    });
  }

  @override
  void moveStarted() {
  }
}

class GameWidget extends StatefulWidget {
  final Game game;
  final GameBoard gameBoard;
  final GameTheme theme;
  const GameWidget({required this.game, required this.gameBoard,
    required this.theme, Key? key}) : super(key: key);

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget>
  with SingleTickerProviderStateMixin, GameListener {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _controller.addListener(() {setState(() {
    });});
    widget.game.addGameListener(this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.addAll(widget.theme.getEffects(widget.game.percentCorrect, widget.game));
    children.add(widget.gameBoard);
    if (widget.game.won) {
      children.addAll(widget.theme.getWinEffects(_controller.value, widget.game));
    }
    return Stack(
      children: children,
    );
  }

  @override
  void gameRestarted() {
  }

  @override
  void gameWon() {
    _controller.forward(from: 0.0);
  }

  @override
  void moveComplete(int score) {
    setState(() {
    });
  }

  @override
  void moveStarted() {
  }
}



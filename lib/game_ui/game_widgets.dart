import 'package:flutter/material.dart';
import 'package:puzzle2/game_board.dart';
import 'package:puzzle2/themes.dart';

import '../domain.dart';
import '../game_board.dart';
import '../game_ui/game_controller.dart';

BoxDecoration getBoxDecoration() {
  return BoxDecoration(
    color: Colors.teal, border: Border.all(color: Colors.tealAccent, width: 4),
    borderRadius: BorderRadius.circular(8),
    boxShadow: const [
      BoxShadow(color: Colors.black26, spreadRadius: 4, blurRadius: 10)
    ],
  );
}

class ScoreWidget extends StatefulWidget {
  final Game game;
  const ScoreWidget(this.game, {Key? key}) : super(key: key);

  @override
  State<ScoreWidget> createState() => _ScoreWidgetState();
}

class _ScoreWidgetState extends State<ScoreWidget> with SingleTickerProviderStateMixin,
  GameListener {
  late AnimationController _controller;
  double score = 0;
  double oldScore = 0;
  double displayedScore = 0;
  double delta = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _controller.addListener(() {
      setState(() {
        displayedScore = oldScore + delta * _controller.value;
      });
    });
    widget.game.addGameListener(this);
    oldScore = widget.game.score/100;
    score = widget.game.score/100;
    delta = 0;
    displayedScore = score;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60, height: 60,
      child: CircularProgressIndicator(
        value: displayedScore, strokeWidth: 8,
      ),
    );
  }

  @override
  void gameRestarted() {
    oldScore = widget.game.score/100;
    score = widget.game.score/100;
    delta = 0;
  }

  @override
  void gameWon() {
  }

  @override
  void moveComplete(int newScore) {
    setState(() {
      oldScore = score;
      score = newScore/100;
      delta = score - oldScore;
      _controller.forward(from: 0);
    });
  }

  @override
  void moveStarted() {
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
      fit: StackFit.expand,
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



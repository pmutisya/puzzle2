import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:puzzle2/game_ui/game_controller.dart';

import '../domain.dart';
import 'effects.dart';

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
            child: Icon(Icons.help_outline),
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

class GameEffectLayer extends StatefulWidget {
  final Game game;
  const GameEffectLayer(this.game, {Key? key}) : super(key: key);

  @override
  State<GameEffectLayer> createState() => _GameEffectLayerState();
}

class _GameEffectLayerState extends State<GameEffectLayer>
  with SingleTickerProviderStateMixin, GameListener {
  late AnimationController _controller;

  Tween<double> innerRadiusTween = Tween(begin: .5, end: 0.01);
  Tween<double> angleTween = Tween(begin: 0.0, end: pi);
  ColorTween colorTween = ColorTween(begin: Colors.green, end: Colors.red);

  late List<Alignment> stars, blueStars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _controller.addListener(() {setState(() {
    });});
    stars = []; blueStars = [];
    for (int k = 0; k < 20; k++) {
      stars.add(Alignment(random.nextDouble()*2 - 1, random.nextDouble()*2 - 1));
    }
    for (int k = 0; k < 5; k++) {
      blueStars.add(Alignment(random.nextDouble()*2 - 1, random.nextDouble()*2 - 1));
    }
    widget.game.addGameListener(this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: Colors.orangeAccent,
          width: double.infinity, height: double.infinity,
        ),
        CustomPaint(
          painter: BeamsPainter(
            innerRadius: innerRadiusTween.evaluate(_controller),
            angle: angleTween.evaluate(_controller),
            color: colorTween.evaluate(_controller)!,
          ),
        ),
        CustomPaint(
          painter: BeamsPainter(
            beams: 11,
            angle: angleTween.evaluate(_controller),
            innerRadius: 0, color: Colors.deepOrangeAccent.withOpacity(.5),
          ),
        ),
        CustomPaint(
          painter: StarsPainter(stars, radius: _controller.value),
        ),
        CustomPaint(
          painter: StarsPainter(blueStars, color: Colors.indigo, radius: _controller.value),
        )
      ],
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
  }

  @override
  void moveStarted() {
  }
}



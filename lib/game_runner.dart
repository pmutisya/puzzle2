import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keymap/keymap.dart';
import 'package:puzzle2/game_board.dart';

import 'domain.dart';
import 'game_controller.dart';

class GameRunner extends StatefulWidget {
  const GameRunner({Key? key}) : super(key: key);

  @override
  _GameRunnerState createState() => _GameRunnerState();
}

class _GameRunnerState extends State<GameRunner> with GameListener, SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Game game;
  late GlobalKey<GameBoardState> gameKey;
  late GameController gameController;

  static const Duration moveDuration = Duration(milliseconds: 250);
  List<Move> animatingMoves = [];

  @override
  void initState() {
    super.initState();

    gameKey = GlobalKey<GameBoardState>();
    gameController = GameController.startSorted(16);
    game = gameController.game;
    game.reset();

    game.setGameListener(this);
    game.addListener(() { setState(() {});});

    _controller = AnimationController(vsync: this, duration: GameBoardState.defaultDuration);
  }

  @override
  void moveStarted(){}
  @override
  void moveComplete() {
    setState(() {
      if (animatingMoves.isNotEmpty) {
        doNextMove();
      }
    });
  }

  void shuffle({bool animate = true}) {
    animatingMoves = gameController.shuffle(40, animate: animate);
    doNextMove();
  }

  void shuffleImmediately() {
    gameController.shuffleImmediately(40);
  }

  void reverseSolve() {
    animatingMoves = gameController.reverseMoves();
    doNextMove();
  }

  void doNextMove() {
    if (animatingMoves.isNotEmpty) {
      Move move = animatingMoves.removeAt(0);
      if (move == Move.up) {
        gameKey.currentState!.moveUp(duration: moveDuration);
      }
      else if (move == Move.down) {
        gameKey.currentState!.moveDown(duration: moveDuration);
      }
      else if (move == Move.left) {
        gameKey.currentState!.moveLeft(duration: moveDuration);
      }
      else {
        gameKey.currentState!.moveRight(duration: moveDuration);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardWidget(
        bindings: [
          KeyAction(LogicalKeyboardKey.keyS, 'Shuffle the board', shuffle),
          KeyAction(LogicalKeyboardKey.keyR, 'Reverse solve', reverseSolve),
          KeyAction(LogicalKeyboardKey.keyS, 'Shuffle (no animation)', shuffleImmediately, isShiftPressed: true),
        ],
        child: Stack(
          children: [
            Container(
              width: double.infinity, height: double.infinity,
              color: Colors.black,
            ),
            GameBoard(
              game, mode: 'gradient', key: gameKey, assetImage: 'assets/images/image_bg.jpg',
            )
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Game Tester',
    theme: ThemeData(
      fontFamily: 'Poppins'
    ),
    darkTheme: ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'Poppins'
    ),
    home: const GameRunner(),
  ));
}
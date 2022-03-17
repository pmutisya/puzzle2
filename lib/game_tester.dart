import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keymap/keymap.dart';
import 'package:puzzle2/game_board.dart';

import 'domain.dart';
import 'move_model.dart';

///A test widget to run simulated games only
class GameTester extends StatefulWidget {
  final bool autoplay;
  const GameTester({this.autoplay = true, Key? key}) : super(key: key);

  @override
  _GameTesterState createState() => _GameTesterState();
}

class _GameTesterState extends State<GameTester> with GameListener {
  late Game game;
  late GlobalKey<GameBoardState> gameBoardKey;
  late MoveModel movesModel;

  static const Duration moveDuration = Duration(milliseconds: 250);
  List<Move> animatingMoves = [];

  bool shuffling = false;

  @override
  void initState() {
    super.initState();

    gameBoardKey = GlobalKey<GameBoardState>();
    game = Game(16, interactive: true);
    movesModel = game.movesModel;
    game.reset();

    game.addGameListener(this);
    // _autoplay();
  }

  @override
  void moveStarted(){}

  @override
  void moveComplete(int score) {
    setState(() {
      if (animatingMoves.isNotEmpty) {
        doNextMove();
      }
      else {
        resetGame();
        if (shuffling) {
          shuffling = false;
          reverseSolve();
        }
        else {
          shuffling = true;
          // _autoplay();
        }
      }
    });
  }

  // Future<void> _autoplay() async {
  //   Future.delayed(const Duration(milliseconds: 1000), () {
  //     shuffle();
  //   });
  // }
  @override
  void gameRestarted() {}

  @override
  void gameWon() {}

  void doNextMove() {
    if (animatingMoves.isNotEmpty) {
      Move move = animatingMoves.removeAt(0);
      game.doMove(move);
      gameBoardKey.currentState!.animateExecutedMove(duration: moveDuration);
    }
  }

  void shuffle({bool animate = true}) {
    print('shuffling');
    animatingMoves = movesModel.shuffle(8, animate: animate);
    print('done::');
    for (Move move in animatingMoves) {
      print('\t$move');
    }
    doNextMove();
  }

  void shuffleImmediately() {
    movesModel.shuffleImmediately(4);
    gameBoardKey.currentState!.setState(() {
    });
  }

  void reverseSolve() {
    animatingMoves = movesModel.reverseMoves();
    shuffling = true;
    doNextMove();
  }

  void resetGame() {
    game.reset();
    gameBoardKey.currentState!.setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: KeyboardWidget(
        bindings: [
          KeyAction(LogicalKeyboardKey.keyS, 'Shuffle the board', shuffle),
          KeyAction(LogicalKeyboardKey.keyR, 'Reset the game', resetGame),
          KeyAction(LogicalKeyboardKey.keyV, 'Reverse solve', reverseSolve),
          KeyAction(LogicalKeyboardKey.keyS, 'Shuffle (no animation)', shuffleImmediately, isShiftPressed: true),
        ],
        child: Stack(
          children: [
            Container(
              width: double.infinity, height: double.infinity,
              color: Colors.black,
            ),
            GameBoard(game, showingOverlay: true,
              mode: 'rounded', key: gameBoardKey, assetImage: 'assets/images/image_bg.jpg',
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
    home: Container(
      color: Colors.blue,
      padding: const EdgeInsets.all(20.0),
      child: const GameTester(),
    ),
  ));
}
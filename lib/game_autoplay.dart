import 'package:flutter/material.dart';
import 'package:puzzle2/game_board.dart';
import 'package:puzzle2/home_screen/theme_selector.dart';

import 'domain.dart';
import 'move_model.dart';
import 'themes.dart';

///A test widget to run simulated games only
class AutoPlayer extends StatefulWidget {
  final bool autoplay;
  final Game? game;
  final ThemeListener listener;
  const AutoPlayer(this.game, this.listener, {this.autoplay = true, Key? key}) : super(key: key);

  @override
  _AutoPlayerState createState() => _AutoPlayerState();
}

class _AutoPlayerState extends State<AutoPlayer> with GameListener {
  late Game game;
  late GlobalKey<GameBoardState> gameBoardKey;
  late MoveModel movesModel;

  static const Duration moveDuration = Duration(milliseconds: 250);
  List<Move> animatingMoves = [];

  bool shuffling = true;

  static const List<GameTheme> themes = [DefaultTheme(), ImageTheme(), IvoryTheme(), ModernTheme(),];
  int selectedThemIndex = 0;

  @override
  void initState() {
    super.initState();

    gameBoardKey = GlobalKey<GameBoardState>();
    game = Game(16, interactive: false);
    movesModel = game.movesModel;
    game.reset();

    game.addGameListener(this);
    if (widget.autoplay) {
      _autoplay();
    }
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
          _autoplay();
        }
      }
    });
  }

  Future<void> _autoplay() async {
    Future.delayed(const Duration(milliseconds: 1000), () {
      shuffle();
    });
  }
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
    animatingMoves = movesModel.shuffle(40, animate: animate);
    doNextMove();
  }

  void shuffleImmediately() {
    movesModel.shuffleImmediately(40);
    gameBoardKey.currentState!.setState(() {
    });
  }

  void reverseSolve() {
    animatingMoves = movesModel.reverseMoves();
    doNextMove();
  }

  void resetGame() {
    game.reset();
    gameBoardKey.currentState!.setState(() {
    });
  }

  void _shiftTheme() {
    setState(() {
      selectedThemIndex++;
      if (selectedThemIndex >= themes.length) {
        selectedThemIndex = 0;
      }
      widget.listener(themes[selectedThemIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // const SizedBox(
        //   width: double.infinity, height: double.infinity,
        // ),
        GestureDetector(
          onTap: _shiftTheme,
          child: GameBoard(game,
            mode: themes[selectedThemIndex].tileType, key: gameBoardKey, assetImage: 'assets/images/image_bg.jpg',
          ),
        )
      ],
    );
  }
}


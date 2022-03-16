import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle2/game_board.dart';

import 'app_controller.dart';
import 'domain.dart';
import 'move_model.dart';

///A test widget to run simulated games only
class AutoPlayer extends StatefulWidget {
  final bool autoplay;
  // final ThemeListener listener;
  const AutoPlayer({this.autoplay = true, Key? key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();

    gameBoardKey = GlobalKey<GameBoardState>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    game = Game(Provider.of<AppController>(context).gameSize, interactive: false);
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // const SizedBox(
        //   width: double.infinity, height: double.infinity,
        // ),
        GestureDetector(
          onTap: () {
            Provider.of<AppController>(context, listen: false).shiftTheme();
          },
          child: GameBoard(game,
            mode: Provider.of<AppController>(context).theme.tileType, key: gameBoardKey, assetImage: 'assets/images/image_bg.jpg',
          ),
        )
      ],
    );
  }
}


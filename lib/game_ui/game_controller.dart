import 'package:flutter/material.dart';

import '../domain.dart';
import '../game_board.dart';
import '../move_model.dart';

///A test widget to run simulated games only
class GameController extends GameListener {
  final Game game;

  static const Duration moveDuration = Duration(milliseconds: 100);
  List<Move> animatingMoves = [];
  late GlobalKey<GameBoardState> gameBoardKey;
  late MoveModel movesModel;

  GameController(this.game, this.gameBoardKey) {
    movesModel = game.movesModel;
    game.reset();
    game.addGameListener(this);
  }

  @override
  void moveStarted(){}

  @override
  void moveComplete(int score) {
    if (animatingMoves.isNotEmpty) {
      doNextMove();
    }
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
    animatingMoves = movesModel.shuffle(20, animate: animate);
    doNextMove();
  }

  void shuffleImmediately() {
    movesModel.shuffleImmediately(20,);
  }

  void reverseSolve() {
    animatingMoves = movesModel.reverseMoves();
    doNextMove();
  }

  void resetGame() {
    game.reset();
  }

}

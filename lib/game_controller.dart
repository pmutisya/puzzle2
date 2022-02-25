import 'dart:math' show Random, Point;

import 'domain.dart';

Random random = Random();

enum MoveDirection {
  up, down, left, right
}
class Move {
  final MoveDirection moveDirection;
  final Tile tile;
  const Move(this.moveDirection, this.tile);
}
///Processes and stores the moves. Can be used to play the game
///automatically by calling shuffle and reverseMoves to solve
class GameController {
  final Game game;
  final List<MoveDirection> _moves;

  GameController.startSorted(int length) :
    game = Game(length),
    _moves = [];

  //called from an actual tap on the game board
  void moveTap(Tile tile) {

  }

  void _move(MoveDirection move, {bool animate = false}) {
    Point<int> p = game.getBlankTile();
    Tile tile;
    if (move == MoveDirection.left) {
      tile = game.getTileAt(p.x +1, p.y)!;
    }
    else if (move == MoveDirection.right) {
      tile = game.getTileAt(p.x - 1, p.y)!;
    }
    else if (move == MoveDirection.down) {
      tile = game.getTileAt(p.x, p.y - 1)!;
    }
    else {
      tile = game.getTileAt(p.x, p.y + 1)!;
    }
    game.tap(tile, animate: animate);
    game.completeTap(animate: animate);
  }

  List<MoveDirection> shuffle(int numberOfShuffles, {bool animate = false}) {
    List<MoveDirection> moves = [];
    MoveDirection? previousMove;

    for (int k = 0; k < numberOfShuffles; k++) {
      List<MoveDirection> legal = [];
      if (game.canMoveDown() && previousMove != MoveDirection.up) {
        legal.add(MoveDirection.down);
      }
      if (game.canMoveUp() && previousMove != MoveDirection.down) {
        legal.add(MoveDirection.up);
      }
      if (game.canMoveRight() && previousMove != MoveDirection.left) {
        legal.add(MoveDirection.right);
      }
      if (game.canMoveLeft() && previousMove != MoveDirection.right) {
        legal.add(MoveDirection.left);
      }
      MoveDirection nextMove = legal[random.nextInt(legal.length)];
      moves.add(nextMove);
      previousMove = nextMove;
      _move(nextMove, animate: animate);
    }

    game.reset();
    _moves.addAll(moves);
    return moves;
  }

  void shuffleImmediately(int numberOfShuffles) {
    _moves.clear();
    MoveDirection? previousMove;
    for (int k = 0; k < numberOfShuffles; k++) {
      List<MoveDirection> legal = [];
      if (game.canMoveDown() && !(previousMove == MoveDirection.up)) {
        legal.add(MoveDirection.down);
      }
      if (game.canMoveUp() && !(previousMove == MoveDirection.down)) {
        legal.add(MoveDirection.up);
      }
      if (game.canMoveRight() && !(previousMove == MoveDirection.left)) {
        legal.add(MoveDirection.right);
      }
      if (game.canMoveLeft() && !(previousMove == MoveDirection.right)) {
        legal.add(MoveDirection.left);
      }
      MoveDirection nextMove = legal[random.nextInt(legal.length)];
      previousMove = nextMove;
      _moves.add(nextMove);
      _move(nextMove, animate: true);
    }
  }

  List<MoveDirection> reverseMoves() {
    List<MoveDirection> reverse = [];
    for (MoveDirection move in _moves) {
      if (move == MoveDirection.up) {
        reverse.insert(0, MoveDirection.down);
      }
      else if (move == MoveDirection.down) {
        reverse.insert(0, MoveDirection.up);
      }
      else if (move == MoveDirection.right) {
        reverse.insert(0, MoveDirection.left);
      }
      else {
        reverse.insert(0, MoveDirection.right);
      }
    }
    return reverse;
  }

}
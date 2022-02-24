import 'dart:math' show Random, Point;

import 'domain.dart';

Random random = Random();

enum Move {
  up, down, left, right
}

class GameController {
  final Game _game;
  final List<Move> _moves;

  GameController.startSorted(int length) :
    _game = Game(length),
    _moves = [];

  void move(Move move, {bool animate = false}) {
    Point<int> p = _game.getBlankTile();
    Tile tile;
    if (move == Move.left) {
      tile = _game.getTileAt(p.x +1, p.y)!;
    }
    else if (move == Move.right) {
      tile = _game.getTileAt(p.x - 1, p.y)!;
    }
    else if (move == Move.down) {
      tile = _game.getTileAt(p.x, p.y - 1)!;
    }
    else {
      tile = _game.getTileAt(p.x, p.y + 1)!;
    }
    _game.tap(tile, animate: animate);
    _game.completeTap(animate: animate);

  }

  List<Move> shuffle(int numberOfShuffles, {bool animate = false}) {
    List<Move> moves = [];
    Move? previousMove;

    for (int k = 0; k < numberOfShuffles; k++) {
      List<Move> legal = [];
      if (_game.canMoveDown() && previousMove != Move.up) {
        legal.add(Move.down);
      }
      if (_game.canMoveUp() && previousMove != Move.down) {
        legal.add(Move.up);
      }
      if (_game.canMoveRight() && previousMove != Move.left) {
        legal.add(Move.right);
      }
      if (_game.canMoveLeft() && previousMove != Move.right) {
        legal.add(Move.left);
      }
      Move nextMove = legal[random.nextInt(legal.length)];
      moves.add(nextMove);
      previousMove = nextMove;
      move(nextMove, animate: animate);
    }

    _game.reset();
    _moves.addAll(moves);
    return moves;
  }

  void shuffleImmediately(int numberOfShuffles) {
    _moves.clear();
    Move? previousMove;
    for (int k = 0; k < numberOfShuffles; k++) {
      List<Move> legal = [];
      if (_game.canMoveDown() && !(previousMove == Move.up)) {
        legal.add(Move.down);
      }
      if (_game.canMoveUp() && !(previousMove == Move.down)) {
        legal.add(Move.up);
      }
      if (_game.canMoveRight() && !(previousMove == Move.left)) {
        legal.add(Move.right);
      }
      if (_game.canMoveLeft() && !(previousMove == Move.right)) {
        legal.add(Move.left);
      }
      Move nextMove = legal[random.nextInt(legal.length)];
      previousMove = nextMove;
      _moves.add(nextMove);
      move(nextMove, animate: true);
    }
  }

  List<Move> reverseMoves() {
    List<Move> reverse = [];
    for (Move move in _moves) {
      if (move == Move.up) {
        reverse.insert(0, Move.down);
      }
      else if (move == Move.down) {
        reverse.insert(0, Move.up);
      }
      else if (move == Move.right) {
        reverse.insert(0, Move.left);
      }
      else {
        reverse.insert(0, Move.right);
      }
    }
    return reverse;
  }

}
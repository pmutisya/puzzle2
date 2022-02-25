import 'dart:math' show Random, Point;

import 'domain.dart';

Random random = Random();

enum Move {
  up, down, left, right
}

///Processes and stores the moves. Can be used to play the game
///automatically by calling shuffle and reverseMoves to solve
class GameController {
  final Game game;
  final List<Move> _moves;

  GameController.startSorted(int length) :
    game = Game(length),
    _moves = [];

  //called from an actual tap on the game board
  void moveTap(Tile tile) {

  }

  void _move(Move move, {bool animate = false}) {
    Point<int> p = game.getBlankTile();
    Tile tile;
    if (move == Move.left) {
      tile = game.getTileAt(p.x +1, p.y)!;
    }
    else if (move == Move.right) {
      tile = game.getTileAt(p.x - 1, p.y)!;
    }
    else if (move == Move.down) {
      tile = game.getTileAt(p.x, p.y - 1)!;
    }
    else {
      tile = game.getTileAt(p.x, p.y + 1)!;
    }
    game.tap(tile, animate: animate);
    game.completeTap(animate: animate);
  }

  List<Move> shuffle(int numberOfShuffles, {bool animate = false}) {
    List<Move> moves = [];
    Move? previousMove;

    for (int k = 0; k < numberOfShuffles; k++) {
      List<Move> legal = [];
      if (game.canMoveDown() && previousMove != Move.up) {
        legal.add(Move.down);
      }
      if (game.canMoveUp() && previousMove != Move.down) {
        legal.add(Move.up);
      }
      if (game.canMoveRight() && previousMove != Move.left) {
        legal.add(Move.right);
      }
      if (game.canMoveLeft() && previousMove != Move.right) {
        legal.add(Move.left);
      }
      Move nextMove = legal[random.nextInt(legal.length)];
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
    Move? previousMove;
    for (int k = 0; k < numberOfShuffles; k++) {
      List<Move> legal = [];
      if (game.canMoveDown() && !(previousMove == Move.up)) {
        legal.add(Move.down);
      }
      if (game.canMoveUp() && !(previousMove == Move.down)) {
        legal.add(Move.up);
      }
      if (game.canMoveRight() && !(previousMove == Move.left)) {
        legal.add(Move.right);
      }
      if (game.canMoveLeft() && !(previousMove == Move.right)) {
        legal.add(Move.left);
      }
      Move nextMove = legal[random.nextInt(legal.length)];
      previousMove = nextMove;
      _moves.add(nextMove);
      _move(nextMove, animate: true);
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
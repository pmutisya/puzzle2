import 'dart:math' show Random, Point;

import 'domain.dart';

Random random = Random();

///Processes and stores the moves. Can be used to play the game
///automatically by calling shuffle and reverseMoves to solve
class MoveModel {
  final Game _game;
  final List<Move> _moves;

  MoveModel.fromGame(this._game) :
    _moves = [];

  int get length => _moves.length;

  //called from an actual tap on the game board
  void addMove(Move move) {
    _moves.add(move);
  }

  bool isLegalTap(Tile tile) {
    Point<int> loc = _game.getLocation(tile.position);
    Point<int> zeroLoc = _game.zeroLocation;
    if (loc.x == zeroLoc.x || loc.y == zeroLoc.y) {
      if (loc.x == zeroLoc.x && loc.y != zeroLoc.y) { //vertical match
        return true;
      }
      if (loc.y == zeroLoc.y && loc.x != zeroLoc.x) { //horizontal match
        return true;
      }
    }
    return false; //either the zero tile or too far away from it
  }

  void reset() {
    _moves.clear();
  }

  void _move(Move move, {bool animate = false}) {
    _game.doMove(move, animate: animate);
    _game.completeTap(animate: animate);
  }

  List<Move> shuffle(int numberOfShuffles, {bool animate = false}) {
    Point<int> oldZeroPosition = const Point<int>(-1, -1); //don't reverse moves sequentially

    bool vertical = random.nextBool();

    List<Move> moves = [];
    for (int k = 0; k < numberOfShuffles; k++) {
      List<Tile> possibleTiles = [];
      List<Tile> legalTiles = _game.getLegalTiles(restrict: true, vertical: vertical);
      for (Tile tile in legalTiles) {
        if (tile.location != oldZeroPosition) {
          possibleTiles.add(tile);
        }
      }
      Tile tappedTile = possibleTiles[random.nextInt(possibleTiles.length)];
      vertical = !vertical;
      oldZeroPosition = _game.zeroLocation;
      Move move = _game.getMoveFromTap(tappedTile)!;
      moves.add(move);
      // oldZeroPosition = move.tiles.first.location!;
      _move(move, animate: animate);
    }
    _game.reset();
    _moves.addAll(moves);
    return moves;
  }

  List<Move> shuffleImmediately(int numberOfShuffles) {
    _moves.clear();
    Point<int> oldZeroPosition = const Point<int>(-1, -1);
    List<Move> moves = [];
    for (int k = 0; k < numberOfShuffles; k++) {
      List<Tile> possibleTiles = [];
      List<Tile> legalTiles = _game.getLegalTiles();
      for (Tile tile in legalTiles) {
        if (tile.location != oldZeroPosition) {
          possibleTiles.add(tile);
        }
      }
      Tile tappedTile = possibleTiles[random.nextInt(possibleTiles.length)];
      oldZeroPosition = _game.zeroLocation;
      Move move = _game.getMoveFromTap(tappedTile)!;
      moves.add(move);
      _move(move, animate: false);
    }
    _game.reset();
    return moves;
  }

  List<Move> reverseMoves() {
    List<Move> reverse = [];
    for (Move move in _moves) {
      Move reverseMove = _game.getReverse(move);
      reverse.insert(0, reverseMove);
    }
    return reverse;
  }

}
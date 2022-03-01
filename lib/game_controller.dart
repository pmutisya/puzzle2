import 'dart:math' show Random, Point;

import 'domain.dart';

Random random = Random();

///Processes and stores the moves. Can be used to play the game
///automatically by calling shuffle and reverseMoves to solve
class GameController {
  final Game game;
  final List<Move> _moves;

  GameController.startSorted(int length) :
    game = Game(length),
    _moves = [];

  //called from an actual tap on the game board
  void addMove(Move move) {
    _moves.add(move);
  }

  bool isLegalTap(Tile tile) {
    Point<int> loc = game.getLocation(tile.position);
    Point<int> zeroLoc = game.zeroLocation;
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

  void resetGame() {
    game.reset();
    _moves.clear();
  }

  void _move(Move move, {bool animate = false}) {
    // game.tap(tile, animate: animate);
    game.doMove(move, animate: animate);
    game.completeTap(animate: animate);
  }

  List<Move> shuffle(int numberOfShuffles, {bool animate = false}) {
    Point<int> oldZeroPosition = const Point<int>(-1, -1); //don't reverse moves sequentially

    List<Move> moves = [];
    for (int k = 0; k < numberOfShuffles; k++) {
      List<Tile> possibleTiles = [];
      List<Tile> legalTiles = game.getLegalTiles();
      for (Tile tile in legalTiles) {
        if (tile.location != oldZeroPosition) {
          possibleTiles.add(tile);
        }
      }
      Tile tappedTile = possibleTiles[random.nextInt(possibleTiles.length)];
      oldZeroPosition = game.zeroLocation;
      Move move = game.getMoveFromTap(tappedTile)!;
      moves.add(move);
      // oldZeroPosition = move.tiles.first.location!;
      _move(move, animate: animate);
    }
    game.reset();
    _moves.addAll(moves);
    return moves;
  }

  List<Move> shuffleImmediately(int numberOfShuffles) {
    _moves.clear();
    Point<int> oldZeroPosition = const Point<int>(-1, -1);
    List<Move> moves = [];
    for (int k = 0; k < numberOfShuffles; k++) {
      List<Tile> possibleTiles = [];
      List<Tile> legalTiles = game.getLegalTiles();
      for (Tile tile in legalTiles) {
        if (tile.location != oldZeroPosition) {
          possibleTiles.add(tile);
        }
      }
      Tile tappedTile = possibleTiles[random.nextInt(possibleTiles.length)];
      oldZeroPosition = game.zeroLocation;
      Move move = game.getMoveFromTap(tappedTile)!;
      moves.add(move);
      _move(move, animate: false);
    }
    return moves;
  }

  List<Move> reverseMoves() {
    List<Move> reverse = [];
    for (Move move in _moves) {
      Move reverseMove = game.getReverse(move);
      reverse.insert(0, reverseMove);
    }
    return reverse;
  }

}
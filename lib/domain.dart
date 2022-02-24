import 'dart:math';
import 'package:flutter/material.dart';

class Tile {
  final int value;
  int score = 0;
  int position;
  int? newPosition;
  Point<int>? location;

  bool isAnimating = false;
  bool isShaking = false;
  bool isVisible = true;
  bool canMove = false;

  Tile(this.value, this.position);

  @override
  String toString() => 'Tile $value [$location] at $position new: $newPosition';

  bool get isCorrect => value -1 == position;

}

abstract class GameListener {
  void moveStarted();
  void moveComplete();
}

class Game extends ChangeNotifier {
  final int length;
  final int columns;

  int moves = 0;
  final List<Tile> _tiles;
  late Tile zeroTile;
  late int zeroPosition;

  GameListener? listener;

  ///Creates a game with tiles already in
  ///order. This is useful for starting a game
  ///with the tiles in order then shuffling them
  ///visibly
  Game(this.length) :
      _tiles = List<Tile>.generate(length, (index) => Tile(index+1, index)),
    columns = sqrt(length).toInt() {
    _tiles.last.isVisible = false;
    zeroTile = _tiles.last;
    zeroPosition = zeroTile.position;
    for (Tile tile in _tiles) {
      tile.score = distanceFromTrue(tile);
    }
  }

  Game.fromValues(List<int> values):
    length = values.length,
  _tiles = List<Tile>.generate(values.length, (index) => Tile(values[index]+1, index)),
  columns = sqrt(values.length).toInt() {

    for (int k =0; k < _tiles.length; k++) {
      if (_tiles[k].value == _tiles.length) {
        zeroTile = _tiles[k];
        zeroTile.isVisible = false;
        zeroPosition = _tiles[k].position;
        break;
      }
    }
    for (Tile tile in _tiles) {
      tile.score = distanceFromTrue(tile);
    }
  }

  void setGameListener(GameListener newListener) => listener = newListener;

  int get rows => length ~/ columns;

  void reset() {
    int l = length;
    moves = 0;
    _tiles.clear();
    for (int k = 0; k < l; k++) {
      _tiles.add(Tile(k+1, k));
    }
    zeroTile = _tiles.last;
    zeroTile.isVisible = false;
    zeroPosition = zeroTile.position;

    Point<int> p0 = getBlankTile();
    for (Tile tile in _tiles) {
      Point<int> p1 = getLocation(tile.position);
      tile.location = p1;
      tile.canMove =  (((p1.x - p0.x).abs() == 1 && p0.y == p1.y)|| ((p1.y - p0.y).abs() == 1 && p0.x == p1.x));
      tile.score = distanceFromTrue(tile);
    }
    notifyListeners();
  }

  Tile operator [](int k) {
    return _tiles[k];
  }

  @override
  bool operator ==(Object other) {
    if (other is Game) {
      for (int k= 0; k < _tiles.length; k++) {
        if (_tiles[k].value != other._tiles[k].value) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  @override
  int get hashCode => _tiles.hashCode;

  int get score {
    int score = 0;
    for (Tile tile in _tiles) {
      score += scoreTile(tile);
    }
    return score;
  }

  Point<int> getLocation(int position) {
    int row = position ~/ columns;
    int col = position - row*columns;
    return Point<int>(col, row);
  }

  int getPositionFromLocation(int col, int row) {
    return row*columns + col;
  }

  Point<int> getBlankTile() {
    return getLocation(zeroTile.position);
  }

  List<Tile> getAnimatingTiles() {
    List<Tile> tiles = [];
    for (Tile tile in _tiles) {
      if (tile.isAnimating) {
        tiles.add(tile);
      }
    }
    return tiles;
  }

  Tile? getTileAtPosition(int position) {
    for (Tile tile in _tiles) {
      if (tile.position == position) {
        return tile;
      }
    }
    return null;
  }

  Tile? getTileAt(int col, int row) {
    int position = getPositionFromLocation(col, row);
    return getTileAtPosition(position);
  }

  //Manhattan distance
  int distanceFromTrue(Tile tile) {
    Point<int> p0 = getLocation(tile.position);
    Point<int> pC = getLocation(tile.value - 1);
    return (pC.x - p0.x).abs() + (pC.y - p0.y).abs();
  }

  int scoreTile(Tile tile) => (tile.position - tile.value + 1).abs();

  double get percentCorrect {
    int totalCorrect =0;
    for (Tile tile in _tiles) {
      if (tile.isCorrect) {
        totalCorrect++;
      }
    }
    return totalCorrect/length;
  }

  bool canMoveRight() {
    Point<int> p = getBlankTile();
    return (p.x > 0);
  }
  bool canMoveLeft() {
    Point<int> p = getBlankTile();
    return (p.x < columns - 1);
  }
  bool canMoveDown() {
    Point p = getBlankTile();
    return (p.y > 0);
  }
  bool canMoveUp() {
    Point<int> p = getBlankTile();
    return (p.y < rows - 1);
  }

  bool tap(Tile tile, {bool animate = true}) {
    Point<int> loc = getLocation(tile.position);
    Point<int> zeroLoc = getLocation(zeroTile.position);
    if (loc.x == zeroLoc.x || loc.y == zeroLoc.y) {
      if (loc.x == zeroLoc.x && loc.y != zeroLoc.y) { //vertical match
        int direction = zeroLoc.y < loc.y ? -1 : 1;
        for (int y = loc.y; y != zeroLoc.y; y+=direction) {
          Tile intermediateTile = getTileAt(loc.x, y)!;
          intermediateTile.newPosition = getPositionFromLocation(loc.x, y + direction);
          if (animate) {
            intermediateTile.isAnimating = true;
          }
        }

        zeroTile.newPosition = tile.position;
        zeroTile.isAnimating = animate;
      }
      else if (loc.x != zeroLoc.x){
        int direction = zeroLoc.x < loc.x ? -1 : 1;
        for (int x = loc.x; x != zeroLoc.x; x+=direction) {
          Tile intermediateTile = getTileAt(x, loc.y)!;
          intermediateTile.newPosition = getPositionFromLocation(x + direction, loc.y);
          if (animate) {
            intermediateTile.isAnimating = true;
          }
        }
        zeroTile.newPosition = tile.position;
        zeroTile.isAnimating = animate;
      }
      else {
        return false;
      }
      moves++;
      if (animate) {
        notifyListeners();
      }
      return true;
    }
    else {
      return false;
    }
  }

  void completeTap({bool animate = true}) {
    for (Tile tile in _tiles) {
      if (tile.isAnimating) {
        tile.position = tile.newPosition!;
        tile.location = getLocation(tile.newPosition!);
        tile.isAnimating = false;
      }
    }
    Point<int> p0 = getBlankTile();
    for (Tile tile in _tiles) {
      Point<int> p1 = tile.location!;
      tile.canMove =  (((p1.x - p0.x).abs() == 1 && p0.y == p1.y)|| ((p1.y - p0.y).abs() == 1 && p0.x == p1.x));
      tile.score = distanceFromTrue(tile);
    }
    if (animate) {
      listener?.moveComplete();
    }
  }

  void animationComplete() => notifyListeners();

  bool get won {
    for (Tile tile in _tiles) {
      if (tile.position != tile.value - 1) {
        // won =  false;
        return false;
      }
    }
    // notifyListeners();
    return moves > 0;
  }

  String toDebug() {
    StringBuffer buffer = StringBuffer();
    buffer.write('SCORE: ${(100*percentCorrect).toInt()}  \n');
    for (int row = 0; row < rows; row++) {
      buffer.write('|');
      for (int col =0; col < columns; col++) {
        Tile tile = getTileAt(col, row)!;
        String val = tile.value < 10? ' ${tile.value}' : '${tile.value}';
        buffer.write('$val |');
      }
      buffer.write('\n');
    }
    return buffer.toString();
  }

}


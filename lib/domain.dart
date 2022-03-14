import 'dart:math';

import 'move_model.dart';

class Tile {
  final int value;
  int score = 0;
  int position;
  int? newPosition;
  Point<int>? location;
  Point<int>? newLocation;

  bool isAnimating = false;
  bool isVisible = true;
  bool isTapped = false;
  bool isShaking = false;
  bool canMove = false;

  Tile(this.value, this.position);

  @override
  String toString() => '[$value]';
  // String toString() => 'Tile $value [$location] new: [$newLocation] at $position new: $newPosition';

  bool get isCorrect => value -1 == position;

}
enum MoveDirection {
  up, down, left, right
}
class Move {
  final MoveDirection moveDirection;
  final List<Tile> tiles;
  final Point<int> newZeroLocation;
  const Move(this.moveDirection, this.tiles, this.newZeroLocation);

  int get dx => moveDirection == MoveDirection.left? -1 : moveDirection == MoveDirection.right ? 1:0;

  int get dy => (moveDirection == MoveDirection.down) ? 1 :
  (moveDirection == MoveDirection.up)? -1 : 0;

  @override
  String toString() {
    StringBuffer buffer = StringBuffer();
    buffer.write('Move $moveDirection ');
    for(Tile element in tiles) {
      buffer.write('[${element.value}]');
    }
    return buffer.toString();
  }

}

abstract class GameListener {
  void moveStarted();
  void moveComplete(int score);
  void gameWon();
  void gameRestarted();
}

class Game {
  final int length;
  final int columns;

  final List<Tile> _tiles;

  late int zeroPosition;
  late Point<int> zeroLocation;

  late MoveModel movesModel;
  final List<GameListener> _gameListeners;

  bool interactive;

  ///Creates a game with tiles already in
  ///order. This is useful for starting a game
  ///with the tiles in order then shuffling them
  ///visibly
  Game(this.length, {this.interactive = true}) :
      _gameListeners = [],
      _tiles = List<Tile>.generate(length - 1, (index) => Tile(index+1, index)),
    columns = sqrt(length).toInt()
  {
    zeroPosition = length;
    zeroLocation = Point<int>(columns - 1, columns - 1);
    for (Tile tile in _tiles) {
      tile.location = getLocation(tile.position);
      tile.score = distanceFromTrue(tile);
    }
    movesModel = MoveModel.fromGame(this);
  }

  void addGameListener(GameListener newListener) => _gameListeners.add(newListener);

  int get rows => length ~/ columns;

  void reset() {
    int l = length;
    movesModel.reset();
    // _tiles.clear();
    for (int k = 0; k < l - 1; k++) {
      Tile tile = _tiles[k];
      tile.position = k;
      tile.location = getLocation(tile.position);
      tile.score = distanceFromTrue(tile);
    }
    zeroPosition = length;
    zeroLocation = Point<int>(columns - 1, columns - 1);

    Point<int> p0 = zeroLocation;
    for (Tile tile in _tiles) {
      Point<int> p1 = getLocation(tile.position);
      tile.location = p1;
      tile.canMove = (p1.x == p0.x) || (p1.y == p0.y);
        //(((p1.x - p0.x).abs() == 1 && p0.y == p1.y)|| ((p1.y - p0.y).abs() == 1 && p0.x == p1.x));
      tile.score = distanceFromTrue(tile);
    }
    for (GameListener listener in _gameListeners) {
      listener.gameRestarted();
    }
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
    Point<int> loc = Point(col, row);
    for (Tile tile in _tiles) {
      if (tile.location == loc) {
        return tile;
      }
    }
    return null;
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
    return totalCorrect/(length - 1);
  }

  bool canTap(Tile tile) {
    Point<int> loc = getLocation(tile.position);
    return ((loc.x == zeroLocation.x) && (loc.y != zeroLocation.y)) ||
        ((loc.y == zeroLocation.y) && (loc.x != zeroLocation.x));
  }

  List<Tile> getLegalTiles() {
    List<Tile> tiles = [];
    for (Tile tile in _tiles) {
      if (canTap(tile)) {
        tiles.add(tile);
      }
    }
    return tiles;
  }

  void doMove(Move move, {bool animate = true}) {
    for (Tile tile in move.tiles) {
      int nx = tile.location!.x + move.dx;
      int ny = tile.location!.y + move.dy;
      tile.newLocation = Point<int>(nx, ny);
      tile.newPosition = getPositionFromLocation(nx, ny);
      tile.isAnimating = animate;
    }
    zeroLocation = move.tiles.first.location!;
    zeroPosition = move.tiles.first.position;
  }

  Move getReverse(Move move) {
    MoveDirection direction = (move.moveDirection == MoveDirection.down)? MoveDirection.up:
    (move.moveDirection == MoveDirection.up)? MoveDirection.down:
    (move.moveDirection == MoveDirection.right)? MoveDirection.left : MoveDirection.right;

    return Move(direction, move.tiles, move.tiles.first.location!);
  }

  Move? getMoveFromTap(Tile tile) {
    if (canTap(tile)) {
      Point<int> loc = tile.location!; //getLocation(tile.position);
      Point<int> zL = zeroLocation;
      List<Tile> tiles = [];
      int dx = (zL.x > loc.x)? 1 : (zL.x < loc.x)? -1 : 0;
      int dy = (zL.y > loc.y)? 1 : (zL.y < loc.y)? -1 : 0;
      MoveDirection direction = (dx > 0)? MoveDirection.right :
        (dx < 0)? MoveDirection.left : (dy > 0)? MoveDirection.down : MoveDirection.up;

      Point<int> newZeroLocation = tile.location!;

      if (dx != 0) { //horizontal shift
        for (int x = loc.x; x != zL.x; x+=dx) {
          Tile movingTile = getTileAt(x, loc.y)!;
          tiles.add(movingTile);
        }
      }
      else { //vertical shift
        for (int y = loc.y; y != zL.y; y += dy) {
          tiles.add(getTileAt(loc.x, y)!);
        }
      }
      return Move(direction, tiles, newZeroLocation);
    }
    else {
      return null;
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
    Point<int> p0 = zeroLocation;
    for (Tile tile in _tiles) {
      Point<int> p1 = tile.location!;
      tile.canMove == (p1.x == p0.x) || (p1.y == p0.y);
      // tile.canMove =  (((p1.x - p0.x).abs() == 1 && p0.y == p1.y)|| ((p1.y - p0.y).abs() == 1 && p0.x == p1.x));
      tile.score = distanceFromTrue(tile);
    }
    // if (animate) {
    for(GameListener listener in _gameListeners) {
      listener.moveComplete((percentCorrect*100).round());
    }
    // }
    if (won) {
      for (GameListener _gameListener in _gameListeners) {
        _gameListener.gameWon();
      }
    }
  }

  bool get won {
    for (Tile tile in _tiles) {
      if (!tile.isCorrect) {
        // won =  false;
        return false;
      }
    }
    // notifyListeners();
    return movesModel.length > 0;
  }

  String toDebug() {
    StringBuffer buffer = StringBuffer();
    buffer.write('SCORE: ${(100*percentCorrect).toInt()}  \n');
    for (int row = 0; row < rows; row++) {
      buffer.write('|');
      for (int col = 0; col < columns; col++) {
        Tile tile = getTileAt(col, row)!;
        String val = tile.value < 10? ' ${tile.value}' : '${tile.value}';
        buffer.write('$val |');
      }
      buffer.write('\n');
    }
    return buffer.toString();
  }

}


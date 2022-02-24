import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'domain.dart';
import 'tiles.dart';

class GameBoard extends StatefulWidget {
  final Game game;
  final String mode;
  final String? assetImage;

  const GameBoard(this.game, {required this.mode, this.assetImage,
    Key? key}) : super(key: key);

  @override
  GameBoardState createState() => GameBoardState();
}

class GameBoardState extends State<GameBoard> with TickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _moveTileAnimation;
  late AnimationController _shakeController;
  late AnimationController _winController;

  static const Duration defaultDuration = Duration(milliseconds: 250);

  late Game game;
  List<Tile> animatingTiles = [];

  Tile? activeTile;

  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: defaultDuration);
    _controller.addListener(() {setState(() {});});
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        animatingTiles = widget.game.getAnimatingTiles();
      }
      else if (status == AnimationStatus.completed) {
        widget.game.completeTap();
        animatingTiles.clear();
        if (widget.game.won) {
          _winController.forward(from: 0.0);
        }
      }
    });

    _moveTileAnimation = CurvedAnimation(parent: _controller, curve: Curves.linearToEaseOut);

    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shakeController.addListener(() { setState((){});});
    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed && activeTile != null) {
        activeTile!.isShaking = false;
      }
    });

    _winController = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _winController.addListener(() { setState((){});});

    game = widget.game;
    if (widget.assetImage != null) {
      _loadAssetImage();
    }
  }

  Future<void> _loadAssetImage() async {
    String imagePath = widget.assetImage!;
    ByteData imageData = await rootBundle.load(imagePath);
    Uint8List list = Uint8List.view(imageData.buffer);
    ui.Codec codec = await ui.instantiateImageCodec(list);
    ui.FrameInfo info = await codec.getNextFrame();
    setState(() {
      _image = info.image;
    });
  }

  //a tile was tapped in the UI
  void _tapped(Tile tile, {Duration duration = defaultDuration}) {
   bool tapped = game.tap(tile);
   if (tapped) {
     activeTile = null;
     setState(() {
       _controller.duration = duration;
       _controller.forward(from: 0);
     });
   }
   else {
     activeTile = tile;
     activeTile!.isShaking = true;
     _shakeController.forward(from: 0);
   }
  }

  void moveRight({Duration duration = defaultDuration}) {
    Point<int> p = game.getBlankTile();
    if (game.canMoveRight()) {
      Tile? tile = game.getTileAt(p.x - 1, p.y);
      _tapped(tile!, duration: duration);
    }
  }

  void moveLeft({Duration duration = defaultDuration}) {
    Point<int> p = game.getBlankTile();
    if (game.canMoveLeft()) {
      Tile? tile = game.getTileAt(p.x + 1, p.y);
      _tapped(tile!, duration: duration);
    }
  }

  void moveDown({Duration duration = defaultDuration}) {
    Point<int> p = game.getBlankTile();
    if (game.canMoveDown()) {
      Tile? tile = game.getTileAt(p.x, p.y - 1);
      _tapped(tile!, duration: duration);
    }
  }

  void moveUp({Duration duration = defaultDuration}) {
    Point<int> p = game.getBlankTile();
    if (game.canMoveUp()) {
      Tile? tile = game.getTileAt(p.x, p.y + 1);
      _tapped(tile!, duration: duration);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _shakeController.dispose();
    _winController.dispose();
    super.dispose();
  }

  Offset _getScreenLocation(Tile tile, double tileSize) {
    if (tile.isAnimating) {
      Point<int> l1 = game.getLocation(tile.position);
      Point<int> l2 = game.getLocation(tile.newPosition!);
      Offset o1 = Offset(l1.x * tileSize, l1.y * tileSize);
      Offset o2 = Offset(l2.x * tileSize, l2.y * tileSize);

      return Tween<Offset>(begin: o1, end: o2).animate(_moveTileAnimation).value;
    }
    else {
      Point<int> loc = widget.game.getLocation(tile.position);
      return Offset(loc.x*tileSize, loc.y*tileSize);
    }
  }
  @override
  Widget build(BuildContext context) {
    MediaQueryData media = MediaQuery.of(context);
    Size size = media.size;
    size  = Size(size.width - media.padding.horizontal, size.height - media.padding.vertical);
    double side = size.shortestSide - 20;
    double tileSize = side/game.columns;

    List<Widget> children = [];
    Container panel = Container(color: Colors.black,
      width: side, height: side,);
    children.add(panel);

    for (int k =0; k < game.length; k++) {
      Tile tile = game[k];

      Offset offset = _getScreenLocation(tile, tileSize);
      Widget tw = _getTile(tile, tileSize);

      Widget child;

      if (tile.isShaking) {
        Point zeroPos = widget.game.getLocation(widget.game.zeroTile.position);
        Point tilePos = widget.game.getLocation(tile.position);
        double dy = zeroPos.y > tilePos.y ? 0.055 : zeroPos.y == tilePos.y ? 0.0 : -0.055;
        double dx = zeroPos.x > tilePos.x ? 0.055 : zeroPos.x == tilePos.x ? 0.0 : -0.055;
        child = SlideTransition(
          position: Tween<Offset>(begin: Offset(dx, dy), end: Offset.zero).
          animate(CurvedAnimation(
              parent: _shakeController, curve: Curves.easeInToLinear)),
          child: tw,
        );
      }
      else {
        child = tw;
      }

      Positioned positioned = Positioned(child: child, left: offset.dx, top: offset.dy,);
      children.add(positioned);
    }

    return Container(
      alignment: Alignment.center,
      width: double.infinity, height: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black)
      ),
      child: Stack(
        fit: StackFit.loose,
        alignment: Alignment.center,
        children: children,
      ),
    );
  }

  Widget _getTile(Tile tile, double size) {
    return GestureDetector(
      onTap: () => _tapped(tile),
      child: widget.mode == 'rounded'? TileWidget(tile: tile, game: game, size: size,) :
      widget.mode == 'ivory'? IvoryTile(tile: tile, game: game, size: size) :
      widget.mode == 'image' && _image != null? ImageTile(_image!, tile: tile, game: game, size: size):
      widget.mode == 'candy'? CandyTile(tile: tile, game: game, size: size) :
      widget.mode == 'gradient'? GradientTile(startColor: Colors.red, endColor: Colors.blue, tile: tile, size: size, game: game):
      widget.mode =='gradient-stop'? GradientStopTile(startColor: Colors.red, endColor: Colors.green, tile: tile, size: size, game: game) :
      SimpleTile(tile: tile, game: game, size: size),
    );
  }

}

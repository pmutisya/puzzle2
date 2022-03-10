import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../domain.dart';
import '../image_tiler.dart';

const List<String> tileTypes = ['simple', 'rounded', 'ivory', 'image', 'candy',
  'plastic', 'gradient', 'gradient stop'];

class TileWidget extends StatelessWidget {
  final Tile tile;
  final double size;
  final double margin;
  final double radius;
  final Game game;

  const TileWidget({required this.tile, required this.size, required this.game,
  this.margin = 8, this.radius = 8, Key? key}) : super(key: key);

  double calcTextSize(double size) {
    return min(144.0, max(12.0, size - 72));
  }

  Color get background => Colors.white;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        Container(
          width: max(18, size - margin*2), height: max(18, size - margin*2),
          alignment: Alignment.center,
          margin: EdgeInsets.all(margin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(radius)),
            color: tile.isVisible? tile.isCorrect? Colors.greenAccent :
              tile.canMove? Colors.lightBlueAccent : Colors.amberAccent : Colors.transparent,
            boxShadow: tile.isVisible? const [BoxShadow(color: Colors.black12, offset: Offset(2, 2))] : [],
          ),
          child: tile.isVisible? Text('${tile.value}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: calcTextSize(size)),) :
            Container(),
        ),
        tile.isVisible? Positioned(top: 12, left: 12,
          child: Text('[${tile.location!.x}, ${tile.location!.y}]', style: const TextStyle(fontSize: 10),),
        ) : Container(),
      ],
    );
  }
}

class SimpleTile extends TileWidget {

  const SimpleTile({required Tile tile, required Game game, required  double size, Key? key}):
        super(tile: tile, game: game, size: size, key: key);

  @override
  Color get background => Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: max(18, size - 2), height: max(18, size - 2),
      alignment: Alignment.center,
      margin: const EdgeInsets.only(left: 1, top: 1),
      decoration: BoxDecoration(
        // borderRadius: const BorderRadius.all(Radius.circular(2)),
        color: tile.isVisible? Colors.blueGrey : Colors.transparent,
      ),
      child: tile.isVisible? Text('${tile.value}', style: TextStyle(color: Colors.black, fontSize: calcTextSize(size)),) :
      Container(),
    );
  }
}

class GradientTile extends TileWidget{
  final Color startColor, endColor;
  final Gradient gradient;

  GradientTile({required this.startColor, required this.endColor, required Tile tile, required double size,
    required Game game, Key? key}) :
        gradient = getColor(game, tile, startColor, endColor),
        super(tile: tile, size: size, game: game, key: key);

  static Gradient getColor(Game game, Tile tile, Color startColor, Color endColor) {
    Point<int> correctLocation = game.getLocation(tile.value - 1);
    double xv = correctLocation.x/game.columns;
    double yv = correctLocation.y/game.rows;
    double distance = sqrt(xv*xv + yv*yv);
    double t = distance/1.0;
    ColorTween tween = ColorTween(begin: startColor, end: endColor);
    Color color1 = tween.lerp(t)!;
    xv = min(1.0, (correctLocation.x+1)/game.columns);
    yv = min(1.0, (correctLocation.y+1)/game.rows);
    distance = sqrt(xv*xv + yv*yv);
    t = distance/1.0;
    Color color2 = tween.lerp(t)!;
    return LinearGradient(colors: [color1, color2], begin: Alignment.topLeft, end: Alignment.bottomRight);

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: max(18, size - 1), height: max(18, size - 1),
      alignment: Alignment.center,
      // margin: const EdgeInsets.only(left: 1, top: 1),
      decoration: BoxDecoration(
        // borderRadius: const BorderRadius.all(Radius.circular(2)),
        gradient: tile.isVisible? gradient : null,
      ),
      child: tile.isVisible? Text('${tile.value}',
        style: TextStyle(color: Colors.black.withOpacity(.5), fontSize: calcTextSize(size)),) :
      Container(),
    );
  }
}

class GradientStopTile extends TileWidget{
  final Color startColor, endColor;
  final Color color;

  GradientStopTile({required this.startColor, required this.endColor, required Tile tile, required double size,
    required Game game, Key? key}) :
        color = getColor(game, tile, startColor, endColor),
        super(tile: tile, size: size, game: game, key: key);

  static Color getColor(Game game, Tile tile, Color startColor, Color endColor) {
    Point<int> correctLocation = game.getLocation(tile.value - 1);
    double xv = correctLocation.x/game.columns;
    double yv = correctLocation.y/game.rows;
    double distance = sqrt(xv*xv + yv*yv);
    double t = distance/1.0;
    ColorTween tween = ColorTween(begin: startColor, end: endColor);
    return tween.lerp(t)!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: max(18, size - 2), height: max(18, size - 2),
      alignment: Alignment.center,
      margin: const EdgeInsets.only(left: 1, top: 1),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(2)),
        color: tile.isVisible? color : Colors.transparent,
      ),
      child: tile.isVisible? Text('${tile.value}', style: TextStyle(color: Colors.black,
        fontFamily: 'Poppins', fontSize: calcTextSize(size)),) :
      Container(),
    );
  }
}

class IvoryTile extends TileWidget {
  const IvoryTile({required Tile tile, required Game game, required double size, Key? key}) :
        super(tile: tile, game: game, size: size, key: key);

  @override
  Color get background => const Color(0xFF044128);

  static const Color white = Color(0xFFFDFDFD);
  static const Color tan = Color(0xFFD8AC6E);
  static const Color lightTan = Color(0xFFE9E0D8);
  static const Color darkBlue = Color(0xFF035F72);
  static const Color lightBlue = Color(0xFF8FC7CB);
  static const Color textColor = Color(0xFF0C1935);

  static const TextStyle _textStyle = TextStyle(fontWeight: FontWeight.bold,
    shadows: [Shadow(color: Colors.black45, offset: Offset(0, -2))],
    color: textColor,
  );

  @override
  Widget build(BuildContext context) {
    double w = size - 12.0;
    double h = size - 12.0;
    double radius = size/4;

    return tile.isVisible? Padding(
        padding: const EdgeInsets.all(0),
        child: SizedBox(
          width: w, height: h,
          child: Stack(
            fit: StackFit.loose,
            children: [
              Positioned(  //bottom blue
                  bottom:0.0,
                  child: Container(
                    width: w, height: h*5.0/5.0,
                    decoration: BoxDecoration(
                        color: darkBlue,
                        borderRadius: BorderRadius.circular(radius),
                        boxShadow: const [BoxShadow(color: Colors.black45, offset: Offset(0, 5), blurRadius: 14, spreadRadius: 0),
                          BoxShadow(color: white, offset: Offset(0, 4), blurRadius: 2, spreadRadius: -4, blurStyle: BlurStyle.inner),
                        ]
                    ),
                  )
              ),
              Positioned( //bottom blue highlight
                width: w*10/10, height: h*9/10,
                left: 0, top: h/20,
                child: Container(
                  width: double.infinity, height: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: darkBlue, width: 2.0),
                    borderRadius: BorderRadius.circular(radius*5/5),
                    gradient: const RadialGradient(
                        colors: [darkBlue, darkBlue, lightBlue], stops: [0, .85, 1.0],
                        radius: .6
                    ),
                  ),
                ),
              ),
              Positioned(  //lowest white
                bottom: h/7,
                child: Container(
                  width: w, height: h*6/7,
                  decoration: BoxDecoration(
                      gradient: const RadialGradient(colors: [tan, tan, lightTan], tileMode: TileMode.clamp,
                          stops: [0, .95, 1], radius: .6, center: Alignment.center),
                      boxShadow: const [
                        BoxShadow(color: Colors.black45, offset: Offset(0, 4), blurRadius: 4),
                        BoxShadow(color: tan, offset: Offset.zero, blurRadius: 2.0, spreadRadius: -2),
                        // BoxShadow(color: tan, offset: Offset(0,1), blurRadius: 11, spreadRadius: -4),
                      ],
                      border: Border.all(color: tan),
                      borderRadius: BorderRadius.circular(radius)
                  ),
                ),
              ),
              // Positioned( //bottom highlight
              //   bottom: h/12, left: w*1/7,
              //   child: Container(
              //     width: w*5/7, height: h/6,
              //     decoration: BoxDecoration(
              //       gradient: const LinearGradient(colors: [Color(0x44BC9A6C), Color(0x00FFFFFF), Color(0xAAEEF5F5)],
              //         stops: [0, .85, 1.0], begin: Alignment.topCenter, end: Alignment.bottomCenter
              //       ),
              //       borderRadius: BorderRadius.circular(h/16),
              //       // border: Border.all(color: Colors.red)
              //     ),
              //   ),
              // ),
              Positioned( //full middle
                  top: 0,
                  child: Container(
                    width: w, height: h*3/4,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(radius),
                        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [white, Color(0xFFFDE7D6)], stops: [0, 0.9]
                        ),
                        boxShadow: const [
                          BoxShadow(color: Color(0xFFD8AC6E), offset: Offset(0,0), spreadRadius: -8, blurRadius: 0),
                        ]
                    ),
                  )
              ),
              Transform.translate(offset: Offset(0, -h/10), //Text
                child: Center(
                  // top: h/5, left: w/2 - h/5,
                  child: Text('${tile.value}', style: _textStyle.copyWith(fontSize: h*3/8,
                    fontFamily: 'MochiyPopOne',),
                  textAlign: TextAlign.center,),
                ),
              ),
            ],
          ),
        )
    ) :
    Container();
  }
}

class CandyTile extends TileWidget {

  static const Color yellow = Color(0xFFFFDF34);
  static const Color yellowShadow = Color(0xFFE8AB01);

  static const Color pink = Color(0xFfFD9FF3);
  static const Color pinkShadow = Color(0xFFFC51B4);

  static const Color green = Color(0xFF64DC9B);
  static const Color greenShadow = Color(0xFF218B55);

  static const Color red = Color(0xFFF1252F);

  const CandyTile({required Tile tile, required Game game,
    required double size, Key? key}) :
        super(tile: tile, game: game, size: size, key: key);

  @override
  Color get background => const Color(0xFF335EFA);

  @override
  double calcTextSize(double size) {
    return min(144.0 ,max(12.0, size - 96));
  }

  @override
  Widget build(BuildContext context) {
    int row = tile.location!.y;
    int rows = game.rows;
    int mid = rows~/2;
    bool isMid = rows%2 ==1 &&row == (rows+1)~/2;
    bool isLess = row < mid;
    Offset offset = isMid? Offset.zero : isLess? const Offset(0, -18) : const Offset(0, 18);
    // double vSize = isMid? size : size - 20;
    return Container(
      width: max(18, size - 20), height: max(18, size - 20),
      alignment: Alignment.center,
      margin: const EdgeInsets.only(left: 1, top: 1, bottom: 18),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        color: tile.isVisible? pink : Colors.transparent,
        boxShadow: tile.isVisible? [
          BoxShadow(color: pinkShadow, blurRadius: 0, offset: offset)
        ]: null,
      ),
      child: tile.isVisible? Text('${tile.value}',
        style: TextStyle(color: red, fontSize: calcTextSize(size),
          fontFamily: 'MochiyPopOne',),) :
      Container(),
    );

  }
}

class PlasticTile extends TileWidget {
  static const Color purple = Color(0xFFE2E9FC);
  static const Color text = Color(0xFFEDF2FF);
  static const Color highlight = Color(0xFFEFF1FE);
  static const Color shadow = Color(0xFFCBC1FB);

  const PlasticTile({required Tile tile, required Game game,
    required double size, Key? key}):
        super(tile: tile, game: game, size: size, key: key);

  @override
  Color get background => const Color(0xFFEFEFEF);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: max(18, size - 4), height: max(18, size - 4),
      alignment: Alignment.center,
      margin: const EdgeInsets.only(left: 1, top: 1, bottom: 18),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        color: tile.isVisible? purple : Colors.transparent,
        boxShadow: tile.isVisible? const [
          BoxShadow(color: shadow, blurRadius: 2, offset: Offset(1, 1)),
          BoxShadow(color: highlight, blurRadius: 2, offset: Offset(-1, -1)),
        ]: null,
      ),
      child: tile.isVisible? Text('${tile.value}', style: TextStyle(color: text,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(color: shadow, offset: Offset(1, 1),),
            Shadow(color: highlight, offset: Offset(-1, -1)),
          ], fontSize: calcTextSize(size)),) :
      Container(),
    );
  }
}
class ImageTile extends TileWidget {
  final ui.Image image;
  final ImageTilePainter painter;

  ImageTile(this.image, {required Tile tile, required Game game, required double size, Key? key}):
        assert (tile.location != null, 'the tile must have a location'),
        painter = ImageTilePainter(image, col: game.getLocation(tile.value - 1).x,
            row: game.getLocation(tile.value - 1).y,
            rows: game.rows, cols: game.columns,
            outputWidth: size, outputHeight: size),
        super(tile: tile, game: game, size: size, key: key);


  @override
  Widget build(BuildContext context) {
    double w = max(18, size), h = max(18, size);
    return tile.isVisible? Container(
      width: w, height: h,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black)
      ),
      child: CustomPaint(
        painter: painter,
      ),
    ) :
    Container();
  }
}


import 'package:flutter/material.dart';
import 'dart:math' show Random;

import 'package:puzzle2/game_ui/effects_widgets.dart';

class GardenContainer extends EffectsWidget {
  final int maximumFlowers;

  const GardenContainer(this.maximumFlowers, {required double progress, Key? key}) :
        super(progress: progress, key: key);
  @override
  State<GardenContainer> createState() => _GardenContainerState();
}

const Color darkGreen = Color(0xFF082D38);
const Color mediumGreen = Color(0xFF017088);
const Color lightGreen = Color(0xFF017088);

const Color lightBlue = Color(0xFF26869A);
const Color yellow = Color(0xFFEDB64E);

const Color background = Color(0xFF74ADBB);

class _GardenContainerState extends State<GardenContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Garden garden;
  late Tween<double> progressTween;

  @override
  void initState() {
    super.initState();
    garden = Garden.sized(size: 4);
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _controller.addListener(() {
      setState(() {
        garden.progress = progressTween.evaluate(_controller);
      });
    });
  }

  @override
  void didUpdateWidget(GardenContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    double oldProgress = oldWidget.progress, progress = widget.progress;
    if (progress != oldProgress) {
      print('going from $oldProgress to $progress');
      progressTween = Tween(begin: oldProgress, end: progress);
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: GardenPainter(garden),
    );
  }
}

class Garden {
  final List<Flower> flowers;
  final double floor;

  Garden._internal({this.floor = 20}) : flowers = [];

  factory Garden.sized({int size = 4, floor = 0.0,}) {
    assert(size > 0);
    Garden garden = Garden._internal(floor: floor);
    for (int k = 0; k < size; k++) {
      double sx = k/size;// + random.nextDouble()/size;
      double dy = .2 + .8*random.nextDouble();
      Flower flower = Flower(location: sx, width: 1.0/size, height: dy,
          progress: 0.0,
          left: random.nextBool(), curve: random.nextDouble(), isDark: true);
      garden.flowers.add(flower);
    }
    return garden;
  }
  set progress(double p) {
    for (Flower flower in flowers) {
      flower.progress = p;
    }
  }
}


Random random = Random();

class GardenPainter extends CustomPainter {
  final Paint backgroundPaint = Paint()..style = PaintingStyle.fill .. color = background;
  final Paint flowerPaint = Paint()..style = PaintingStyle.fill..color = darkGreen;
  final Paint flowerStalkPaint = Paint()..style = PaintingStyle.stroke..color = darkGreen..strokeWidth = 1.0;

  final Garden garden;

  GardenPainter(this.garden);

  @override
  bool shouldRepaint(GardenPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), flowerStalkPaint);
    for (Flower flower in garden.flowers) {
      flower.paint(canvas, size);
    }
  }

}

class Flower {
  final double location;
  final double width;
  final double height;
  final double floor;
  final double curve;
  final bool left;
  final Paint leafPaint, stalkPaint;
  double progress;

  Flower({required this.location, required this.width, required this.height,
    this.floor = 40.0, this.left = true,
    required this.curve, required this.progress, bool isDark = true}) :
        leafPaint = Paint()..style = PaintingStyle.fill..color = isDark? darkGreen : mediumGreen,
        stalkPaint = Paint() ..style = PaintingStyle.stroke .. color = isDark? darkGreen : mediumGreen.. strokeWidth = 2.0;

  void drawLeaf(Canvas canvas, Rect rect) {
    Path path = Path();
    Offset s1 = rect.topLeft, s2 = rect.bottomRight;
    path.moveTo(s1.dx, s1.dy);
    Offset c1 = rect.topRight;
    path.quadraticBezierTo(c1.dx, c1.dy, s2.dx, s2.dy);
    Offset c2 = rect.bottomLeft;
    path.quadraticBezierTo(c2.dx, c2.dy, s1.dx, s1.dy);
    canvas.drawPath(path, leafPaint);
    canvas.drawLine(rect.center, rect.bottomRight, stalkPaint);

    rect = Rect.fromLTWH(rect.right, rect.top, rect.width, rect.height);
    path = Path();
    s1 = rect.bottomLeft; s2 = rect.topRight;
    c1 = rect.topLeft; c2 = rect.bottomRight;
    path.moveTo(rect.left, rect.bottom);
    path.quadraticBezierTo(c1.dx, c1.dy, s2.dx, s2.dy);
    path.quadraticBezierTo(c2.dx, c2.dy, s1.dx, s1.dy);
    canvas.drawPath(path, leafPaint);
  }
  void paint(Canvas canvas, Size size) {
    double h = size.height;
    double w = size.width;

    Rect rect = Rect.fromLTWH(w*location, h - h*height*progress - floor, w*width*progress, h);
    // canvas.drawRect(rect, stalkPaint);
    // log('RECT: $rect');

    canvas.drawLine(rect.bottomCenter, rect.topCenter, stalkPaint);

    Rect leaf1Rect = Rect.fromLTWH(rect.centerLeft.dx, rect.centerLeft.dy-h/8, rect.width/2, h/4);
    drawLeaf(canvas,leaf1Rect);

    Rect topLeaf = Rect.fromLTWH(rect.center.dx - w/10, rect.top, w/10, h/8);
    drawLeaf(canvas, topLeaf);
    // canvas.drawRect(topLeaf, stalkPaint);
  }
}
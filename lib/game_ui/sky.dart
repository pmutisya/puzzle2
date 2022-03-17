import 'package:flutter/material.dart';
import 'dart:math';

Random random = Random();

class Star{
  double x;
  double progress;
  double radius;
  Color color;

  Star(this.x, this.progress) :
    radius = random.nextDouble()*4+1,
    color = Color.fromRGBO(255, 200, 200, random.nextDouble()*.5 + .5);

  void advance() {
    progress += .001;
    if (progress > 1.0) {
      progress = 0;
    }
  }
}

class SkyPainter extends CustomPainter {
  final Paint starPaint = Paint()..style = PaintingStyle.fill..color = Colors.white70;
  final List<Star> stars;

  SkyPainter(this.stars);

  @override
  bool shouldRepaint(covariant SkyPainter oldDelegate) {
    return true;
  }
  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width, h = size.height;
    for (Star star in stars) {
      double x = w*star.x;
      double y = h - h*star.progress;
      Path path = Path();
      path.addOval(Rect.fromLTWH(x, y, star.radius, star.radius));

      canvas.drawPath(path, starPaint);
      canvas.drawShadow(path, star.color, 5.0, true);
    }
  }
}

class SkyCanvas extends StatefulWidget {
  const SkyCanvas({Key? key}) : super(key: key);

  @override
  State<SkyCanvas> createState() => _SkyCanvasState();
}

class _SkyCanvasState extends State<SkyCanvas> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Star> stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _controller.addListener(() {
      setState(() {
        for(Star star in stars) {
          star.advance();
        }
      });
    });
    stars = [];
    for (int k =0; k < 20; k++) {
      stars.add(Star(random.nextDouble(), random.nextDouble()));
    }
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.black, Color(0xFF222266)],
          stops: [0.25, 1.0]
        )
      ),
      child: CustomPaint(
        size: const Size(double.infinity, double.infinity),
        painter: SkyPainter(stars),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: SkyCanvas(),
  ));
}
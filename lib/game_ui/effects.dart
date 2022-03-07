import 'dart:math';

import 'package:flutter/material.dart';

Random random = Random();

class Shapes {
  static Path getStar(int spokes, Offset center, double outerRadius, double innerRadius) {
    Path path = Path();
    double rot = pi/2*3;
    double x = center.dx, y = center.dy, step = pi/spokes;

    path.moveTo(center.dx, center.dy - outerRadius);
    for (int k =0; k < spokes; k++) {
      x = center.dx + cos(rot)*outerRadius;
      y = center.dy + sin(rot)*outerRadius;
      path.lineTo(x, y);
      rot += step;

      x = center.dx + cos(rot)*innerRadius;
      y = center.dy + sin(rot)*innerRadius;
      path.lineTo(x, y);

      rot += step;
    }
    path.lineTo(center.dx, center.dy - outerRadius);
    path.close();
    return path;
  }
}

class StarsPainter extends CustomPainter {
  final List<Alignment> stars;
  final Paint starPaint;
  final Color color;
  final double radius;

  StarsPainter(this.stars, {this.color = Colors.white, this.radius = 1.0}) :
        starPaint = Paint()..color = color..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width, h = size.height;
    double rx = w/2, ry = h/2;
    Offset c = size.center(Offset.zero);

    double ss = size.shortestSide;
    double outerRadius = ss/25, innerRadius = ss/45;

    starPaint.color = color.withOpacity(radius);

    for (Alignment s in stars) {
      Offset center = Offset(c.dx + s.x * rx * radius, c.dy + s.y * ry * radius);
      Path star = Shapes.getStar(5, center, outerRadius, innerRadius);
      canvas.drawPath(star, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}
class BeamsPainter extends CustomPainter {
  final int beams;
  // final List<double> thetas;
  final Color color;
  final Alignment center;
  final Paint beamPaint;

  final double angle;

  final double innerRadius;

  BeamsPainter({this.angle = 0.0, this.beams = 5, this.color = Colors.red,
    this.center = Alignment.center, this.innerRadius = 0.01}):
  // thetas = List.generate(beams, (index) => random.nextDouble()*pi/8),
        beamPaint = Paint()..style = PaintingStyle.fill..color = color;

  @override
  void paint(Canvas canvas, Size size) {
    double h = size.height, w = size.width;
    Rect rect = Rect.fromLTWH(0, 0, w, h);
    double rx = w/2, ry = h/2;
    Offset cp = Offset(rx + center.x*rx, ry + center.y*ry);

    canvas.save();
    canvas.clipRect(rect);
    rx = w*2; ry = h*2;
    double sa = pi/4 + angle;

    for (int k = 0; k < beams; k++) {
      Path beam = Path();
      double theta = pi/10; //thetas[k];
      beam.moveTo(cp.dx + rx*innerRadius*cos(sa), cp.dy + ry*innerRadius*sin(sa));
      beam.lineTo(cp.dx + rx*cos(sa), cp.dy + ry*sin(sa));
      beam.lineTo(cp.dx + rx*cos(sa+theta), cp.dy + ry*sin(sa+theta));
      beam.close();
      canvas.drawPath(beam, beamPaint);
      sa += pi*2.0/beams;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BeamsPainter oldDelegate) {
    return true;
  }

}

class BeamTester extends StatefulWidget {
  const BeamTester({Key? key}) : super(key: key);

  @override
  State<BeamTester> createState() => _BeamTesterState();
}

class _BeamTesterState extends State<BeamTester> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Tween<double> innerRadiusTween = Tween(begin: .5, end: 0.01);
  Tween<double> angleTween = Tween(begin: 0.0, end: pi);
  ColorTween colorTween = ColorTween(begin: Colors.green, end: Colors.red);

  late List<Alignment> stars, blueStars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _controller.addListener(() {setState(() {
    });});
    stars = []; blueStars = [];
    for (int k = 0; k < 20; k++) {
      stars.add(Alignment(random.nextDouble()*2 - 1, random.nextDouble()*2 - 1));
    }
    for (int k = 0; k < 5; k++) {
      blueStars.add(Alignment(random.nextDouble()*2 - 1, random.nextDouble()*2 - 1));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Colors.orangeAccent,
            width: double.infinity, height: double.infinity,
          ),
          CustomPaint(
            painter: BeamsPainter(
              innerRadius: innerRadiusTween.evaluate(_controller),
              angle: angleTween.evaluate(_controller),
              color: colorTween.evaluate(_controller)!,
            ),
          ),
          CustomPaint(
            painter: BeamsPainter(
              beams: 11,
              angle: angleTween.evaluate(_controller),
              innerRadius: 0, color: Colors.deepOrangeAccent.withOpacity(.5),
            ),
          ),
          CustomPaint(
            painter: StarsPainter(stars, radius: _controller.value),
          ),
          CustomPaint(
            painter: StarsPainter(blueStars, color: Colors.indigo, radius: _controller.value),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(child: const Icon(Icons.play_arrow),
        onPressed: () { _controller.forward(from: 0);},),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    title: 'Effects Tester',
    home: BeamTester(),
  ));
}
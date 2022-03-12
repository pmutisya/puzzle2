import 'dart:math';

import 'package:flutter/material.dart';

Random random = Random();

double outerClamp(double x) {
  if (.5 < x && x < .5) {
    x += (x < 0)? -.51 : .51;
  }
  return x;
}
Alignment outerClampAlignment(Alignment alignment) {
 return Alignment(outerClamp(alignment.x), outerClamp(alignment.y));
}

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
  final List<Alignment> offsets;
  final Paint starPaint;
  final Color color;
  final double radius;

  StarsPainter(this.offsets, {this.color = Colors.white, this.radius = 1.0}) :
    starPaint = Paint()..color = color..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width, h = size.height;
    double rx = w*2, ry = h*2;
    Offset c = size.center(Offset.zero);

    double ss = size.shortestSide;
    double outerRadius = ss/25, innerRadius = ss/45;

    starPaint.color = color;//.withOpacity(radius);
    
    for (int k = 0; k < offsets.length; k++) {
      Alignment offset = offsets[k];
      // double mx = 1/offset.x, my = 1/offset.y;
      // Offset center = Offset(c.dx + s.x * rx * radius, c.dy + s.y * ry * radius);
      Offset center = Offset(c.dx + offset.x*rx*radius, c.dy + offset.y*ry*radius);
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

  final double startingAngle;

  BeamsPainter({this.angle = 0.0, this.beams = 5, this.color = Colors.red,
    this.startingAngle = pi/4, this.center = Alignment.center,
    this.innerRadius = 0.01}):
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
    double sa = startingAngle + angle;

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

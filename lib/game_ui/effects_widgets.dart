import 'package:flutter/material.dart';

import 'dart:math' show pi;

import 'effects.dart';

class StarsField extends StatefulWidget {
  final double progress;
  final int starCount;
  final Color starColor;
  const StarsField({required this.progress,
    this.starColor = Colors.white, this.starCount = 5, Key? key}) : super(key: key);

  @override
  State<StarsField> createState() => StarsFieldState();
}

class StarsFieldState extends State<StarsField> {
  List<Alignment> alignments = [];

  @override
  void initState() {
    super.initState();

    for (int k =0; k < widget.starCount; k++) {
      alignments.add(Alignment(outerClamp(random.nextDouble()*2 - 1),
          outerClamp(random.nextDouble()*2 - 1)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: StarsPainter(alignments, radius: widget.progress, color: widget.starColor),
    );
  }
}

class BeamsEffect extends StatefulWidget {
  final double progress;
  final Color color;
  final int numberOfBeams;
  final Alignment alignment;
  final double innerRadius;
  final bool reverse;
  final double startingAngle;

  const BeamsEffect({Key? key, this.progress = 0,
    this.color = Colors.red, this.numberOfBeams = 5, this.innerRadius = .001,
    this.reverse = false, this.startingAngle = pi/4,
    this.alignment = Alignment.center}) :
      // assert(angle >= 0 && angle <= 2.0*pi, 'Angle must be between 0 and 2𝞹'),
      super(key: key);

  @override
  State<BeamsEffect> createState() => _BeamsEffectState();
}

class _BeamsEffectState extends State<BeamsEffect> {


  @override
  Widget build(BuildContext context) {
    double angle = widget.reverse? 2.0*pi*(1 - widget.progress) : 2.0*pi*widget.progress;
    return CustomPaint(
      painter: BeamsPainter(angle: angle, beams: widget.numberOfBeams,
          color: widget.color, innerRadius: 0.01, center: widget.alignment,
          startingAngle: widget.startingAngle),
    );
  }
}

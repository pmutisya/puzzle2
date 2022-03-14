import 'package:flutter/material.dart';

import 'dart:math' show pi;

import 'effects.dart';

abstract class EffectsWidget extends StatefulWidget {
  final double progress;
  const EffectsWidget({required this.progress, Key? key}) : super(key: key);
}

class ColoredPanelEffect extends EffectsWidget {
  final Color startColor, endColor;
  final Color color;

  ColoredPanelEffect({
    required progress, required this.startColor, required this.endColor, Key? key
  }):
    color = ColorTween(begin: startColor, end: endColor).lerp(progress)!,
  super(progress: progress, key: key);

  @override
  State<StatefulWidget> createState() {
    return _ColoredPanelState();
  }
}

class _ColoredPanelState extends State<ColoredPanelEffect> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.color,
      width: double.infinity, height: double.infinity,
    );
  }
}

class StarsField extends EffectsWidget {
  final int starCount;
  final Color starColor;
  const StarsField({required double progress,
    this.starColor = Colors.white, this.starCount = 5, Key? key}) : super(progress: progress, key: key);

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
      size: const Size(double.infinity, double.infinity),
      painter: StarsPainter(alignments, radius: widget.progress, color: widget.starColor),
    );
  }
}

class BeamsEffect extends EffectsWidget {
  final Color color;
  final int numberOfBeams;
  final Alignment alignment;
  final double innerRadius;
  final bool reverse;
  final double startingAngle;

  const BeamsEffect({Key? key, progress = 0,
    this.color = Colors.red, this.numberOfBeams = 5, this.innerRadius = .001,
    this.reverse = false, this.startingAngle = pi/4,
    this.alignment = Alignment.center}) :
      // assert(angle >= 0 && angle <= 2.0*pi, 'Angle must be between 0 and 2𝞹'),
      super(progress: progress, key: key);

  @override
  State<BeamsEffect> createState() => _BeamsEffectState();
}

class _BeamsEffectState extends State<BeamsEffect> {


  @override
  Widget build(BuildContext context) {
    double angle = widget.reverse? 2.0*pi*(1 - widget.progress) : 2.0*pi*widget.progress;
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: BeamsPainter(angle: angle, beams: widget.numberOfBeams,
          color: widget.color, innerRadius: 0.01, center: widget.alignment,
          startingAngle: widget.startingAngle),
    );
  }
}


class CircularGlowWidget extends EffectsWidget {
  final Color centerColor;
  final Duration glowDuration;
  final double maxRadius, minRadius;

  const CircularGlowWidget({Key? key, required this.centerColor,
    this.maxRadius = .5, this.minRadius = 0,
    required this.glowDuration}) : super(progress: 0, key: key);

  @override
  State<CircularGlowWidget> createState() => _CircularGlowWidgetState();
}

class _CircularGlowWidgetState extends State<CircularGlowWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Tween<double> radiusTween;

  @override
  void initState() {
    super.initState();
    radiusTween = Tween(begin: widget.minRadius, end: widget.maxRadius);
    _controller = AnimationController(vsync: this, duration: widget.glowDuration);
    _controller.addListener(() {
      setState(() {
      });
    });
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: radiusTween.evaluate(_controller),
            colors: [widget.centerColor, widget.centerColor.withOpacity(0)],
          )
      ),
    );
  }
}

class EffectsTester extends StatefulWidget {
  const EffectsTester({Key? key}) : super(key: key);

  @override
  State<EffectsTester> createState() => _EffectsTesterState();
}

class _EffectsTesterState extends State<EffectsTester> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Tween<double> innerRadiusTween = Tween(begin: .5, end: 0.01);
  Tween<double> angleTween = Tween(begin: 0.0, end: pi);
  ColorTween colorTween = ColorTween(begin: Colors.green, end: Colors.red);

  // late List<Alignment> stars, blueStars;
  // late List<double> angles, blueAngles;
  late List<Alignment> alignments, blueAlignments;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _controller.addListener(() {setState(() {
    });});

    alignments = List.generate(20, (index) => Alignment(outerClamp(random.nextDouble()*2 - 1),
        outerClamp(random.nextDouble()*2 - 1)));
    blueAlignments = List.generate(5, (index) => Alignment(outerClamp(random.nextDouble()*2 - 1),
        outerClamp(random.nextDouble()*2 - 1)));
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

          BeamsEffect(progress: _controller.value, reverse: true, color: Colors.blue,
            numberOfBeams: 3, startingAngle: 0,),
          BeamsEffect(progress: _controller.value, numberOfBeams: 11,
            innerRadius: _controller.value/1000,
            color: Colors.deepOrangeAccent.withOpacity(.5),),
          BeamsEffect(progress: 2*_controller.value, reverse: true, numberOfBeams: 5,),
          StarsField(progress: _controller.value, starCount: 10, starColor: Colors.white,),
          StarsField(progress: _controller.value,starCount: 5, starColor: Colors.indigo,),
          const CircularGlowWidget(centerColor: Colors.yellow, minRadius: .15,
              glowDuration: Duration(milliseconds: 2000))
        ],
      ),
      floatingActionButton: FloatingActionButton(child: const Icon(Icons.play_arrow),
        onPressed: () {
          _controller.forward(from: 0);},),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    title: 'Effects Tester',
    home: EffectsTester(),
  ));
}
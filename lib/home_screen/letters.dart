import 'package:flutter/material.dart';
import 'dart:math';

import 'package:puzzle2/style.dart';

class Letters extends StatefulWidget {
  final List<Point<int>> locations;

  const Letters(this.locations, {Key? key}) : super(key: key);

  @override
  State<Letters> createState() => LettersState();
}

class LettersState extends State<Letters> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _flippingController;
  late int columns;
  late int rows;
  static const List<Color> colors = [highlight, text, disabledText];
  int colorIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _controller.addListener(() {
      setState(() {
      });
    });
    _flippingController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _flippingController.addListener(() { 
      setState(() {
      });
    });
    _flippingController.addStatusListener((status) { 
      if (status == AnimationStatus.completed) {
        _flipTiles();
      }
      else if (status == AnimationStatus.forward) {
        setState(() {
          colorIndex++;
          if (colorIndex >= colors.length) {
            colorIndex = 0;
          }
        });
      }
    });
    _flippingController.repeat(reverse: true, period: const Duration(milliseconds: 5000),);
    
    _controller.value = 1.0;
    columns = 0;
    rows = 0;
    for (Point<int> loc in widget.locations) {
      columns = max(columns, loc.x);
      rows = max(rows, loc.y);
    }
    _flippingController.forward(from: 0);
    _controller.forward(from: 0);
  }

  static Random random = Random();

  Future<void> _flipTiles() async {
    return Future.delayed(Duration(milliseconds: random.nextInt(10000)), () {
      if (!_flippingController.isDismissed) {
        _flippingController.forward(from: 0.0);
      }
    });
  }
  @override
  void dispose() {
    _controller.dispose();
    _flippingController.reset();
    _flippingController.dispose();
    super.dispose();
  }

  void play() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      double hw = min(constraints.maxWidth/(columns + 1), constraints.maxHeight/(rows+1));
      List<Widget> squares = [];
      double dx = constraints.maxWidth/2 - (columns*hw)/2;
      for (Point<int> p in widget.locations) {
        Square square = Square(hw, p, color: colors[colorIndex],rotationPercent: _flippingController.value,);
        squares.add(Positioned(
          child: square,
          left: dx + p.x*hw, top: p.y*hw + (1 - _controller.value)*constraints.maxHeight,
        ));
      }
      return Stack(
        children: squares,
      );
      
    });
  }
}

@immutable
class Square extends StatelessWidget {
  final double size;
  final Point<int> location;
  final double rotationPercent;

  final Color color;

  const Square(this.size, this.location, {this.color = Colors.white, this.rotationPercent = 0, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget child =  Container(
      margin: const EdgeInsets.all(2),
      height: size - 2, width: size - 2,
      decoration: BoxDecoration(
        color: color,
        // border: Border.all(color: Colors.white, width: 1,)
      ),
    );
    if (rotationPercent == 0) {
      return child;
    }
    // if (rotationPercent < .5) {
    //   child = Container(height: size, width: size, color: Colors.blueGrey,);
    // }
    return Transform(
      alignment: FractionalOffset.center,
      transform: Matrix4.identity()..
        setEntry(3, 2, 0.0015)..
        rotateX(pi*(rotationPercent)),
      child: child,
    );
  }
}

List<Point<int>> buildWord(List<int> locations) {
  List<Point<int>> points = [];
  for(int k = 0; k < locations.length; k+=2) {
    points.add(Point(locations[k], locations[k+1]));
  }
  return points;
}

List<int> tiles = [1,0,1,1,0,1,1,1,2,1,1,2,1,3,1,4,
  4,0,4,2,4,3,4,4, //i
  6,0,6,1,6,2,6,3,6,4,7,4, //L
  9,0,10,0,11,0,
  9,1,
  9,2,10,2,
  9,3,
  9,4,10,4,11,4, //E
  13,0,14,0,15,0,
  13,1,
  13,2,14,2,15,2,
  15,3,
  13,4,14,4,15,4, //S
];

class Tester extends StatefulWidget {
  const Tester({Key? key}) : super(key: key);

  @override
  State<Tester> createState() => _TesterState();
}

class _TesterState extends State<Tester> {
  GlobalKey<LettersState> key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue,
        child: Letters(buildWord(tiles), key: key,),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.play_arrow),
        onPressed: () {
          key.currentState?.play();
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: Tester(),
  ));
}
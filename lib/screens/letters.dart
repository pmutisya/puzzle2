import 'package:flutter/material.dart';
import 'dart:math';

class Letters extends StatefulWidget {
  final List<Point<int>> locations;

  const Letters(this.locations, {Key? key}) : super(key: key);

  @override
  State<Letters> createState() => LettersState();
}

class LettersState extends State<Letters> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int columns;
  late int rows;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _controller.addListener(() {
      setState(() {
      });
    });
    _controller.value = 1.0;
    columns = 0;
    rows = 0;
    for (Point<int> loc in widget.locations) {
      columns = max(columns, loc.x);
      rows = max(rows, loc.y);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
      int k =0;
      double dx = constraints.maxWidth/2 - (columns*hw)/2;
      for (Point<int> p in widget.locations) {
        Square square = Square(hw, p);
        squares.add(Positioned(
          child: square,
          left: dx + p.x*hw, top: p.y*hw + (1 - _controller.value)*constraints.maxHeight,
        ));
        k++;
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
  
  const Square(this.size, this.location, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size, width: size,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.orangeAccent, width: 1,)
      ),
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
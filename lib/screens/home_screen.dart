import 'dart:math';

import 'package:flutter/material.dart';
import 'package:puzzle2/move_model.dart';

import '../game_board.dart';
import '../domain.dart';
import 'letters.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  Tween<double> scaleTween = Tween(begin: 1.0, end: .95);
  ColorTween colorTween = ColorTween(begin: Colors.blue, end: Colors.purple);
  late Game game;
  late GlobalKey<GameBoardState> gameBoardKey;
  late MoveModel movesModel;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 5000));
    game = Game(16);
    movesModel = game.movesModel;
    gameBoardKey = GlobalKey();

    game.reset();
    _controller.addListener(() {setState(() {
    });});
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              width: double.infinity, height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.black, colorTween.evaluate(_controller)!],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter
                )
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Transform.scale(
                scale: scaleTween.evaluate(_controller),
                child: Transform.translate(
                  offset: Offset(0.0, sin(_controller.value*2*pi)*20),
                  child: GameBoard(game, mode: 'gradient stop',))),
            ),
            Positioned(
              left: 0, top: 20,
              child: Container(
                padding: const EdgeInsets.all(10.0),
                height: constraints.maxHeight/5, width: constraints.maxWidth - 40,
                child: Letters(buildWord(tiles))),
            ),
            Positioned(
              left: 0, bottom: 20,
              child: Container(
                color: Colors.black12,
                width: constraints.maxWidth,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: const [
                    StartButton(3),
                    StartButton(4),
                    StartButton(5),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}

class StartButton extends StatefulWidget {
  final int size;
  const StartButton(this.size, {Key? key}) :
    assert(size == 3 || size == 4 || size == 5, "Choose 3x3, 4x4 or 5x5"),
    super(key: key);

  @override
  State<StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<StartButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int size;

  @override
  void initState() {
    super.initState();
    size = widget.size;
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
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
        color: Colors.black38
      ),
      padding: const EdgeInsets.all(20),
      child: ClipPath(
        clipper: HexClipper(),
        child: Container(
          color: Colors.black38,
          padding: const EdgeInsets.all(20),
          child: Text('$size x $size', style: const TextStyle(color: Colors.white),))),
    );
  }
}

class HexClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.addPolygon([
      Offset(0, size.height/2),
      Offset(size.width * 1 / 3, size.height),
      Offset(size.width * 2 / 3, size.height),
      Offset(size.width, size.height / 2),
      Offset(size.width * 2 / 3, 0),
      Offset(size.width * 1 / 3, 0)
    ], true);
    return path;
  }
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

void main() {
  runApp(
    const MaterialApp(
      title: 'Home Screen Tester',
      home: Material(
        child: HomeScreen(),
      ),
    )
  );
}

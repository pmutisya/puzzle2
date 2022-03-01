import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../domain.dart';
import '../game_controller.dart';
import '../game_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late GameController gameController;
  late Game game;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    gameController = GameController.startSorted(16);
    game = gameController.game;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        SvgPicture.asset('assets/svg/comic_bg.svg'),
        Padding(padding: const EdgeInsets.all(20), child: GameBoard(gameController, mode: 'ivory',)),
      ]
    );
  }
}

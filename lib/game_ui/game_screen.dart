import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:puzzle2/game_ui/phone_screen.dart';

import '../domain.dart';
import '../move_model.dart';
import '../game_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late MoveModel gameController;
  late Game game;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    game = Game(16);
    gameController = game.movesModel;
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
        SvgPicture.asset('assets/svg/comic_bg.svg', fit: BoxFit.cover),
        Padding(padding: const EdgeInsets.all(20), child: GameBoard(game, mode: 'ivory',)),
        PhoneScreen(game),
      ]
    );
  }
}

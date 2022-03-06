import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:puzzle2/game_ui/adapting_game_screen.dart';

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

  int gamesPlayed = 0;
  int gamesWon = 0;

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
        AdaptingGameScreen(game),
      ]
    );
  }
}

class ResultsWidget extends StatefulWidget {
  const ResultsWidget({Key? key,}) : super(key: key);

  @override
  State<ResultsWidget> createState() => _ResultsWidgetState();
}

class _ResultsWidgetState extends State<ResultsWidget> with SingleTickerProviderStateMixin {
  int gamesPlayed = 0;
  int gamesWon = 0;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


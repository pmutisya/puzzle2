import 'package:flutter/material.dart';
import 'package:puzzle2/game_board.dart';
import 'package:puzzle2/game_ui/game_controller.dart';

import 'domain.dart';
import 'move_model.dart';
import 'game_ui/game_widgets.dart';

class GameApplication extends StatefulWidget {
  const GameApplication({Key? key}) : super(key: key);

  @override
  _GameApplicationState createState() => _GameApplicationState();
}

class _GameApplicationState extends State<GameApplication> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late MoveModel gameMovesModel;
  late Game game;

  GlobalKey<GameBoardState> gameboardKey = GlobalKey();

  int gamesPlayed = 0;
  int gamesWon = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    game = Game(16);
    gameMovesModel = game.movesModel;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    GameBoard gameBoard = GameBoard(game, showingOverlay: true, key: gameboardKey,
      mode: 'rounded', assetImage: 'assets/images/image_bg.jpg',
    );
    GameController gameController = GameController(game, gameboardKey);
    return Stack(
      fit: StackFit.expand,
      children: [
        // SvgPicture.asset('assets/svg/comic_bg.svg', fit: BoxFit.cover),
        GameEffectLayer(game),
        Padding(padding: const EdgeInsets.all(20),
          child: gameBoard),
        Positioned(
          right: 10, top: 10,
          child: ResultsWidget(game),
        ),
        Positioned(
          right: 10, bottom: 10,
          child: GameStartButton(game, gameController),
        ),
        Positioned(
          left: 10, bottom: 10,
          child: ScoreWidget(game),
        ),
      ]
    );
  }
}

class GameTheme {
  final List<GameEffectLayer> effects;
  final List<GameEffectLayer>? aboveEffects;
  final String tileType;

  const GameTheme({required this.effects, required this.tileType, this.aboveEffects});
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:puzzle2/game_board.dart';
import 'package:puzzle2/game_ui/game_controller.dart';
import 'package:puzzle2/themes.dart';

import '../domain.dart';
import '../main.dart';
import '../move_model.dart';
import '../game_ui/game_widgets.dart';

class GamePlayingScreen extends StatefulWidget {
  final GameTheme theme;
  final int gameSize;
  final ResultsListener listener;

  const GamePlayingScreen(this.theme, this.gameSize, this.listener, {Key? key}) : super(key: key);

  @override
  _GamePlayingScreenState createState() => _GamePlayingScreenState();
}

class _GamePlayingScreenState extends State<GamePlayingScreen> with
  GameListener, SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late MoveModel gameMovesModel;
  late Game game;
  late GameTheme theme;

  late GameBoard gameBoard;
  late GameController gameController;

  GlobalKey<GameBoardState> gameBoardKey = GlobalKey();

  Timer? delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    game = Game(widget.gameSize);
    game.addGameListener(this);
    print('SIZE: ${widget.gameSize}');
    print('created a game of size ${game.columns}x${game.rows}');
    theme = widget.theme;
    print('THEME: $theme');

    GameTimes.instance.startGame(game);

    gameMovesModel = game.movesModel;
    gameBoard = GameBoard(game, key: gameBoardKey,
      mode: theme.tileType, assetImage: 'assets/images/image_bg.jpg',
    );
    gameController = GameController(game, gameBoardKey);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      gameController.shuffle();
    });
  }

  @override
  void didUpdateWidget(GamePlayingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    theme = widget.theme;
    game = Game(widget.gameSize);
    game.addGameListener(this);
    gameBoard = GameBoard(game, key: gameBoardKey,
      mode: theme.tileType, assetImage: 'assets/images/image_bg.jpg',
    );

    setState(() {
      GameTimes.instance.startGame(game);
    });
  }
  @override
  void dispose() {
    if (delayTimer != null && delayTimer!.isActive) {
      delayTimer!.cancel();
    }
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game, gameBoard: gameBoard, theme: theme,),
          // Positioned(
          //   right: 10, bottom: 10,
          //   child: GameStartButton(game, gameController),
          // ),
          Positioned(
            left: 10, bottom: 10,
            child: GameClock(game),
          ),
          Positioned(left: 10, top: 10,
            child: BackButton(
              onPressed: (){
                widget.listener(game);
            },
          ))
        ]
      ),
    );
  }

  @override
  void gameRestarted() {
  }

  @override
  void gameWon() {
    print('GAME WON!!2');
    setState(() {

    });
    _delayedSwitch();
  }

  void _delayedSwitch() {
    print('delayed switch');
    delayTimer = Timer(const Duration(milliseconds: 2500),(){
      widget.listener(game,);
    });
  }
  @override
  void moveComplete(int score) {
  }

  @override
  void moveStarted() {
  }
}

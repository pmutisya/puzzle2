import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keymap/keymap.dart';
import 'package:puzzle2/game_board.dart';
import 'package:puzzle2/game_ui/game_controller.dart';
import 'package:puzzle2/themes.dart';

import '../app_controller.dart';
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

  String? assetLoadedText;

  @override
  void initState() {
    super.initState();
    loadAssetText();

    _controller = AnimationController(vsync: this);
    game = Game(widget.gameSize);
    game.addGameListener(this);
    theme = widget.theme;

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

  Future<void> loadAssetText() async {
    assetLoadedText = await DefaultAssetBundle.of(context).loadString('assets/playing.md');
    setState(() {
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

  void moveRight() {
    gameBoardKey.currentState?.moveRight();
  }
  void moveLeft() {
    gameBoardKey.currentState?.moveLeft();
  }
  void moveUp() {
    gameBoardKey.currentState?.moveUp();
  }
  void moveDown() {
    gameBoardKey.currentState?.moveDown();
  }


  @override
  Widget build(BuildContext context) {
    return KeyboardWidget(
      helpText: assetLoadedText, columnCount: 2,
      bindings: [
        KeyAction(LogicalKeyboardKey.keyL, 'Move the square to the right over', moveLeft),
        KeyAction(LogicalKeyboardKey.keyJ, 'Move the square to the left over', moveRight),
        KeyAction(LogicalKeyboardKey.keyK, 'Move the square below up', moveUp),
        KeyAction(LogicalKeyboardKey.keyI, 'Move the square above down', moveDown),
        KeyAction(LogicalKeyboardKey.keyB, 'Go back home', (){
          widget.listener(game);
        },),
      ],
      child: Scaffold(
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
      ),
    );
  }

  @override
  void gameRestarted() {
  }

  @override
  void gameWon() {
    setState(() {
    });
    _delayedSwitch();
  }

  void _delayedSwitch() {
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

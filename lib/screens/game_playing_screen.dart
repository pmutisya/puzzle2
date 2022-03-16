import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keymap/keymap.dart';
import 'package:provider/provider.dart';
import 'package:puzzle2/game_board.dart';
import 'package:puzzle2/game_ui/game_controller.dart';
import 'package:puzzle2/style.dart';
import 'package:puzzle2/themes.dart';

import '../app_controller.dart';
import '../domain.dart';
import '../move_model.dart';
import '../game_ui/game_widgets.dart';

class GamePlayingScreen extends StatefulWidget {

  const GamePlayingScreen({Key? key}) : super(key: key);

  @override
  _GamePlayingScreenState createState() => _GamePlayingScreenState();
}

class _GamePlayingScreenState extends State<GamePlayingScreen> with
  GameListener, SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late MoveModel gameMovesModel;
  late Game game;

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

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      gameController.shuffle();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    game = Game(Provider.of<AppController>(context).gameSize);
    game.addGameListener(this);

    GameTheme theme = Provider.of<AppController>(context).theme;
    GameTimes.instance.startGame(game);

    gameMovesModel = game.movesModel;
    gameBoard = GameBoard(game, key: gameBoardKey,
      mode: theme.tileType, assetImage: 'assets/images/image_bg.jpg',
    );
    gameController = GameController(game, gameBoardKey);
  }

  Future<void> loadAssetText() async {
    assetLoadedText = await DefaultAssetBundle.of(context).loadString('assets/playing.md');
    setState(() {
    });
  }

  // @override
  // void didUpdateWidget(GamePlayingScreen oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   theme = widget.theme;
  //   game = Game(widget.gameSize);
  //   game.addGameListener(this);
  //   gameBoard = GameBoard(game, key: gameBoardKey,
  //     mode: theme.tileType, assetImage: 'assets/images/image_bg.jpg',
  //   );
  //
  //   setState(() {
  //     GameTimes.instance.startGame(game);
  //   });
  // }
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
          Provider.of<AppController>(context).showResults();
        },),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            GameWidget(game: game, gameBoard: gameBoard, theme: Provider.of<AppController>(context).theme,),
            // Positioned(
            //   right: 10, bottom: 10,
            //   child: GameStartButton(game, gameController),
            // ),
            Positioned(
              left: 10, bottom: 10,
              child: GameClock(game),
            ),
            Positioned(left: 10, top: 10,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: bg, shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black38, blurRadius: 4, spreadRadius: 4)
                  ]
                ),
                child: BackButton(
                  color: Colors.white,
                  onPressed: (){
                    Provider.of<AppController>(context).showResults();
                },
            ),
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
      Provider.of<AppController>(context, listen: false).showResults();
    });
  }
  @override
  void moveComplete(int score) {
  }

  @override
  void moveStarted() {
  }
}

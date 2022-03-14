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

class _GamePlayingScreenState extends State<GamePlayingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late MoveModel gameMovesModel;
  late Game game;
  late GameTheme theme;

  GlobalKey<GameBoardState> gameBoardKey = GlobalKey();

  int gamesPlayed = 0;
  int gamesWon = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    game = Game(widget.gameSize);
    print('\nSIZE: ${widget.gameSize}');
    print('created a game of size ${game.columns}x${game.rows}');
    theme = widget.theme;
    print('THEME: $theme');
    gameMovesModel = game.movesModel;
  }

  @override
  void didUpdateWidget(GamePlayingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('\n\nUPDATE!!!');
    theme = widget.theme;
    game = Game(widget.gameSize);
    print('THEME: $theme');
    print('SIZE: ${widget.gameSize}\n\n');
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    GameBoard gameBoard = GameBoard(game, key: gameBoardKey,
      mode: theme.tileType, assetImage: 'assets/images/image_bg.jpg',
    );
    GameController gameController = GameController(game, gameBoardKey);
    return Stack(
      fit: StackFit.expand,
      children: [
        // SvgPicture.asset('assets/svg/comic_bg.svg', fit: BoxFit.cover),
        GameWidget(game: game, gameBoard: gameBoard, theme: theme,),
        // Padding(padding: const EdgeInsets.all(20),
        //   child: gameBoard),
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
        Positioned(left: 10, top: 10,
          child: BackButton(
            onPressed: (){
              widget.listener(game, const Duration(seconds: 10));
          },
        ))
      ]
    );
  }
}

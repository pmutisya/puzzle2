import 'dart:math';

import 'package:flutter/material.dart';
import 'package:puzzle2/game_autoplay.dart';
import 'package:puzzle2/home_screen/theme_selector.dart';
import 'package:puzzle2/move_model.dart';
import 'package:puzzle2/themes.dart';

import '../game_board.dart';
import '../domain.dart';
import '../main.dart';
import '../home_screen/letters.dart';

class HomeScreen extends StatefulWidget {
  final SetOptionsListener listener;
  const HomeScreen(this.listener, {Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  Tween<double> scaleTween = Tween(begin: 1.0, end: .95);
  ColorTween colorTween = ColorTween(begin: Colors.indigo[900], end: Colors.deepPurple[900]);
  late Game game;
  late GlobalKey<GameBoardState> gameBoardKey;
  late MoveModel movesModel;
  GameTheme theme = const DefaultTheme();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 5000));
    game = Game(16, interactive: false);
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

  void themeSelected(GameTheme newTheme) {
    print('THEME: ${newTheme.name}');
    setState(() {
      theme = newTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Stack(
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
                    child: AutoPlayer(game, themeSelected, autoplay: false,)
                  ),
                    // child: GameBoard(game, mode: theme.tileType, assetImage: 'assets/images/image_bg.jpg',))
                ),
              ),
              Positioned(
                left: 0, top: 20,
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  height: constraints.maxHeight/5, width: constraints.maxWidth - 40,
                  child: Letters(buildWord(tiles))),
              ),
              Positioned(
                left: 0, bottom: 0,
                child: Container(
                  width: constraints.maxWidth,
                  height: 100,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      StartButton(3, theme, widget.listener),
                      StartButton(4, theme, widget.listener),
                      StartButton(5, theme, widget.listener),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: ThemeSelector([themeSelected])
            // Positioned(
            //   left: 0, bottom: 100,
            //   child: Container(
            //     alignment: Alignment.center,
            //     color: Colors.blue,
            //     child: ThemeSelector(themeSelected)),
            // ),
            ,
        );
      }
    );
  }
}

class StartButton extends StatefulWidget {
  final int size;
  final GameTheme theme;
  final SetOptionsListener listener;

  const StartButton(this.size, this.theme, this.listener, {Key? key}) :
    assert(size == 3 || size == 4 || size == 5, "Choose 3x3, 4x4 or 5x5"),
    super(key: key);

  @override
  State<StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<StartButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int size;
  bool hovering = false;

  @override
  void initState() {
    super.initState();
    size = widget.size;
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 5500));
    _controller.addListener(() {
      setState(() {
      });
    });
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      // margin: const EdgeInsets.all(10),
      child: InkWell(
        onTap: (){
          widget.listener(widget.theme, size*size);
        },
        onHover: (v) {
          setState(() {
              hovering = v;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.centerLeft, end: Alignment.centerRight,
              colors: [Colors.deepPurple, Colors.blue],
            ),
            boxShadow: [BoxShadow(
              color: hovering? Colors.lightBlueAccent : Colors.black12,
              blurRadius: 6, spreadRadius: 2,
            )],
            border: Border.all(width: 2,
              color: hovering? Colors.lightBlueAccent : Colors.transparent),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
          child: Text('$size x $size',
            style: TextStyle(color: hovering? Colors.lightBlueAccent : Colors.white,
                fontWeight: FontWeight.bold),)
        ),
      )
    );
  }
}

class OctaClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width, h = size.height;
    double s = min(w, h);
    Path path = Path();
    path.addPolygon([
      Offset(0, s/3), //1
      Offset(s/3, 0), //2
      Offset(w - s/3, 0), //3
      Offset(w, s/3), //4
      Offset(w, h - s/3), //5
      Offset(w - s/3, h), //6
      Offset(s/3, h), //7
      Offset(0, h - s/3),
      // Offset(0, size.height/2),
      // Offset(size.width * 1 / 3, size.height),
      // Offset(size.width * 2 / 3, size.height),
      // Offset(size.width, size.height / 2),
      // Offset(size.width * 2 / 3, 0),
      // Offset(size.width * 1 / 3, 0)
    ], true);
    return path;
  }
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

void main() {
  runApp(MaterialApp(
      title: 'Home Screen Tester',
      home: Material(
        child: HomeScreen((theme, size){}),
      ),
    )
  );
}

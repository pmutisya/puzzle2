import 'dart:math';

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:puzzle2/game_autoplay.dart';
import 'package:puzzle2/move_model.dart';
import 'package:puzzle2/style.dart';
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
  late Game game;
  late GlobalKey<GameBoardState> gameBoardKey;
  late MoveModel movesModel;
  GameTheme theme = const DefaultTheme();
  int gameSize = 16;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 10000));
    game = Game(16, interactive: false,);
    movesModel = game.movesModel;
    gameBoardKey = GlobalKey();

    game.reset();
    _controller.addListener(() {setState(() {
    });});
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.reset();
    _controller.dispose();
    super.dispose();
  }

  void sizeSelected(GameTheme _, int size) {
    setState(() {
      gameSize = size;
    });
    widget.listener(theme, size);
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
        double ss = min(constraints.maxWidth, constraints.maxHeight);

        return Scaffold(
          body: Stack(
            children: [
              Container(
                width: double.infinity, height: double.infinity,
                decoration: const BoxDecoration(
                  color: darkBG
                ),
              ),
              Padding(
                padding: EdgeInsets.all(ss/10),
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
                      StartButton(3, theme, sizeSelected, selected: false,),
                      StartButton(4, theme, sizeSelected, selected: false,),
                      StartButton(5, theme, sizeSelected, selected: false,),
                    ],
                  ),
                ),
              ),
              Positioned(left: 10, top: 10,
                child: HoverButton(
                  onTap: () {
                    RenderBox overlay = Overlay.of(context)!.context.findRenderObject()! as RenderBox;
                    showMenu(context: context, position:
                      RelativeRect.fromSize(const Offset(80, 10) & const Size(80, 80), overlay.size),
                      items: [
                        PopupMenuItem(child: TextButton.icon(icon: const Icon(LineIcons.crown),
                          label: Text('3x3 ${Scores.instance[3]}'), onPressed: (){},),),
                        PopupMenuItem(child: TextButton.icon(icon: const Icon(LineIcons.crown),
                          label: Text('4x4 ${Scores.instance[4]}'), onPressed: (){},),),
                        PopupMenuItem(child: TextButton.icon(icon: const Icon(LineIcons.crown),
                          label: Text('5x5 ${Scores.instance[5]}'), onPressed: (){},),),
                      ]);
                  },
                  child: Row(
                    children: const [
                      Icon(LineIcons.award),
                      // Text('High Scores')
                    ],
                  ),
                ),
              ),
            ],
          ),
          // floatingActionButton: ThemeSelector([themeSelected])
        );
      }
    );
  }

}

class StartButton extends StatefulWidget {
  final int size;
  final GameTheme theme;
  final SetOptionsListener listener;
  final bool selected;

  const StartButton(this.size, this.theme, this.listener,
    {this.selected = false, Key? key}) :
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
            gradient: (hovering || widget.selected) ? gradient : null,
            color: hovering? null : bg,
            boxShadow: [BoxShadow(
              color: hovering? Colors.lightBlueAccent : Colors.black12,
              blurRadius: 6, spreadRadius: 2,
            )],
            border: Border.all(width: 2,
              color: hovering? Colors.lightBlueAccent : Colors.transparent),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
          child: Text('$size x $size',
            style: const TextStyle(color: text, //hovering || widget.selected ? text : disabledText,
                fontWeight: FontWeight.bold),)
        ),
      )
    );
  }
}

class HoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const HoverButton({required this.child, required this.onTap, Key? key}) : super(key: key);

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool hovering = false;

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
    return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        child: InkWell(
          onTap: (){
            widget.onTap();
          },
          onHover: (v) {
            setState(() {
              hovering = v;
            });
          },
          child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hovering ? gradient : null,
                color: hovering? null : bg,
                boxShadow: [BoxShadow(
                  color: hovering? Colors.lightBlueAccent : Colors.black12,
                  blurRadius: 6, spreadRadius: 2,
                )],
                border: Border.all(width: 2,
                    color: hovering? Colors.lightBlueAccent : Colors.transparent),
              ),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
              child: widget.child,
          ),
        )
    );
  }
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

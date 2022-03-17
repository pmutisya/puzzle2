import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keymap/keymap.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:puzzle2/game_autoplay.dart';
import 'package:puzzle2/game_ui/sky.dart';
import 'package:puzzle2/move_model.dart';
import 'package:puzzle2/style.dart';

import '../app_controller.dart';
import '../game_board.dart';
import '../home_screen/letters.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Timer themeTimer;
  Tween<double> scaleTween = Tween(begin: 1.0, end: .95);
  late GlobalKey<GameBoardState> gameBoardKey;
  late GlobalKey<KeyboardWidgetState> helpKey;
  late MoveModel movesModel;
  String? assetLoadedText;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 10000));
    themeTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      Provider.of<AppController>(context, listen: false).shiftTheme();
    });

    // int size = Provider.of<AppController>(context).gameSize;
    // game = Game(size, interactive: false,);
    // movesModel = game.movesModel;
    gameBoardKey = GlobalKey();

    helpKey = GlobalKey();

    // game.reset();
    _controller.addListener(() {setState(() {
    });});
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          Provider.of<AppController>(context, listen: false).shiftTheme();
        });
      }
    });
    _controller.repeat(reverse: true);
    loadAssetText();
  }
  Future<void> loadAssetText() async {
    assetLoadedText = await DefaultAssetBundle.of(context).loadString('assets/home_screen_help.md');
    setState(() {
    });
  }

  @override
  void dispose() {
    if (themeTimer.isActive) {
      themeTimer.cancel();
    }
    _controller.dispose();
    super.dispose();
  }

  void startGameWithSize(int size) {
    Provider.of<AppController>(context).setGameSize(size);
    Provider.of<AppController>(context).startGame();
  }


  List<KeyAction> _getShortcuts() {
    return [
      KeyAction(LogicalKeyboardKey.digit3, 'Start a 3x3 Game', () {
        startGameWithSize(9);
      }),
      KeyAction(LogicalKeyboardKey.digit4, 'Start a 4x4 Game', () {
        startGameWithSize(16);
      }),
      KeyAction(LogicalKeyboardKey.digit5, 'Start a 5x5 Game', () {
        startGameWithSize(25);
      }),
    ];
  }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double ss = min(constraints.maxWidth, constraints.maxHeight);
        bool isLandscapeLarge = constraints.maxWidth > 800;

        List<Widget> children = [
          const SkyCanvas(),
          // Container(
          //   width: double.infinity, height: double.infinity,
          //   decoration: const BoxDecoration(
          //     gradient: bgGradient,
          //   ),
          // ),
          Padding(
            padding: EdgeInsets.all(ss/10),
            child: Transform.scale(
              scale: scaleTween.evaluate(_controller),
              child: Transform.translate(
                  offset: Offset(0.0, sin(_controller.value*2*pi)*20),
                  child: const AutoPlayer(autoplay: false,)
              ),
              // child: GameBoard(game, mode: theme.tileType, assetImage: 'assets/images/image_bg.jpg',))
            ),
          ),
          Positioned(
            left: 0, top: 30,
            child: Container(
                padding: const EdgeInsets.all(10.0),
                height: constraints.maxHeight/5, width: constraints.maxWidth - 40,
                child: Letters(buildWord(tiles))),
          ),
          Positioned(
            right: 20, top: 30,
            child: Tooltip(
              message: 'Show keyboard shortcuts',
              child: HoverButton(
                  onTap: () {
                    helpKey.currentState?.toggleOverlay();
                  },
                  child: const Icon(Icons.help_outline_sharp),
              ),
            ),
          ),
          Positioned(
            left: 0, bottom: 20,
            child: Container(
              width: constraints.maxWidth,
              height: 100,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: const [
                  StartButton(3, selected: false,),
                  StartButton(4, selected: false,),
                  StartButton(5, selected: false,),
                ],
              ),
            ),
          ),
          isLandscapeLarge?
          Card(
            margin: const EdgeInsets.all(20),
            elevation: 20,
            color: bg,
            child: Container(
              width: 200, height: 240,
              alignment: Alignment.center,
              // margin: const EdgeInsets.all(10),
              child: Column(mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Best Times', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                  PopupMenuItem(child: TextButton.icon(icon: const Icon(LineIcons.crown, color: yellow,),
                    label: Text('3x3 ${Scores.instance[3]}', style: const TextStyle(color: text),), onPressed: (){},),),
                  PopupMenuItem(child: TextButton.icon(icon: const Icon(LineIcons.crown, color: yellow,),
                    label: Text('4x4 ${Scores.instance[4]}', style: const TextStyle(color: text),), onPressed: (){},),),
                  PopupMenuItem(child: TextButton.icon(icon: const Icon(LineIcons.crown, color: yellow,),
                    label: Text('5x5 ${Scores.instance[5]}', style: const TextStyle(color: text),), onPressed: (){},),),
                ],
              ),
            ),
          )
          :Positioned(left: 10, top: 30,
            child: HoverButton(
              onTap: () {
                RenderBox overlay = Overlay.of(context)!.context.findRenderObject()! as RenderBox;
                showMenu(context: context, position:
                RelativeRect.fromSize(const Offset(80, 10) & const Size(80, 80), overlay.size),
                    items: [
                      PopupMenuItem(child: TextButton.icon(icon: const Icon(LineIcons.crown, color: yellow,),
                        label: Text('3x3 ${Scores.instance[3]}', style: const TextStyle(color: text),), onPressed: (){},),),
                      PopupMenuItem(child: TextButton.icon(icon: const Icon(LineIcons.crown, color: yellow,),
                        label: Text('4x4 ${Scores.instance[4]}', style: const TextStyle(color: text),), onPressed: (){},),),
                      PopupMenuItem(child: TextButton.icon(icon: const Icon(LineIcons.crown, color: yellow,),
                        label: Text('5x5 ${Scores.instance[5]}', style: const TextStyle(color: text),), onPressed: (){},),),
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
        ];
        return KeyboardWidget(
          key: helpKey,
          helpText: assetLoadedText,
          bindings: _getShortcuts(),
          child: Scaffold(
            body: Stack(
              fit: StackFit.loose,
              children: children,
            ),
          ),
        );
      }
    );
  }

}

class StartButton extends StatefulWidget {
  final int size;
  final bool selected;

  const StartButton(this.size,
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
          Provider.of<AppController>(context, listen: false).gameSize = size*size;
          Provider.of<AppController>(context, listen: false).startGame();
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

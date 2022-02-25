import 'package:flutter/material.dart';
import 'package:keymap/keymap.dart';
import 'package:puzzle2/game_board.dart';

import 'domain.dart';
import 'game_controller.dart';
import 'tiles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Tester',
      theme: ThemeData(
          fontFamily: 'Poppins'
      ),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Poppins'
      ),
      home: const GameApp(),
    );
  }
}
class GameApp extends StatefulWidget {
  const GameApp({Key? key}) : super(key: key);

  @override
  _GameAppState createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String mode = 'gradient stop';

  late Game game;
  late GameController gameController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    gameController = GameController.startSorted(16);
    game = gameController.game;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  Widget _getModeMenu() {
    return DropdownButton<String>(
      icon: const Icon(Icons.keyboard_arrow_down),
      elevation: 20,
      items: tileTypes.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem(child: Text(value), value: value,);
      }).toList(),
      value: mode,
      onChanged: (String? newValue) {
        setState(() {
          mode = newValue!;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardWidget(bindings: const [],
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: _getModeMenu(),
        ),
        body: Container(
          padding: const EdgeInsets.all(1),
          child: Stack(
            children: [
              GameBoard(game, gameController, mode: mode)
            ],
          ),
        ),
      ));
  }
}

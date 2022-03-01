import 'package:flutter/material.dart';
import 'package:keymap/keymap.dart';
import 'package:puzzle2/game_ui/game_screen.dart';

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
          fontFamily: 'MochiyPopOne'
      ),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'MochiyPopOne'
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
    return KeyboardWidget(bindings: const [],
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('GAME TEST'),
        ),
        body: Container(
          padding: const EdgeInsets.all(1),
          child: Stack(
            children: const [
              GameScreen()
              // GameBoard(gameController, mode: mode, assetImage: 'assets/images/image_bg.jpg',)
            ],
          ),
        ),
      ));
  }
}

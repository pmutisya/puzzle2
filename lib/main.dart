import 'package:flutter/material.dart';
import 'package:keymap/keymap.dart';
import 'package:puzzle2/screens/game_playing_screen.dart';
import 'package:puzzle2/themes.dart';

import 'screens/home_screen.dart';
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

typedef SetOptionsListener = Function(GameTheme theme, int size);

class _GameAppState extends State<GameApp> with TickerProviderStateMixin {
  late AnimationController _controller;
  late GameTheme theme = const DefaultTheme();
  late int gameSize = 16;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      setState(() {
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _startGame(GameTheme newTheme, int size) {
    setState(() {
      theme = newTheme;
      gameSize = size;
      _tabController.animateTo(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            HomeScreen(_startGame),
            GamePlayingScreen(theme, gameSize)
          ],
        )
    );
  }
}

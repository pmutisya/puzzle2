import 'package:flutter/material.dart';
import 'package:puzzle2/screens/game_playing_screen.dart';
import 'package:puzzle2/themes.dart';

import 'domain.dart';
import 'style.dart';
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
      theme: defaultTheme,
      darkTheme: defaultTheme,
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
typedef ResultsListener = Function(Game game, Duration time);

class _GameAppState extends State<GameApp> with TickerProviderStateMixin {
  late AnimationController _controller;
  late GameTheme theme = const ModernTheme();
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
      print('starting game sized $gameSize');
      print('WITH THEME: $theme');
      _tabController.animateTo(1);
    });
  }

  void _showResults(Game game, Duration duration) {
    setState(() {
      _tabController.animateTo(0);
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
            GamePlayingScreen(theme, gameSize, _showResults)
          ],
        )
    );
  }
}

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

class GameTime implements GameListener{
  final Game game;
  DateTime? start, end;

  GameTime(this.game):
    start = DateTime.now() {
    game.addGameListener(this);
  }
  @override
  void gameRestarted() {
    start = DateTime.now();
  }
  @override
  void gameWon() {
    end = DateTime.now();
    Scores.instance._submitTime(game.rows, end!.difference(start!));
  }
  @override
  void moveComplete(int score) {}
  @override
  void moveStarted() {}
}

class GameTimes {
  static GameTimes get instance => _instance;

  static final GameTimes _instance = GameTimes._internal();

  GameTimes._internal();

  Map<int, GameTime> times = {};

  void startGame(Game game) {
    GameTime? gameTime = GameTime(game);
    times[game.rows] = gameTime;
  }
}

class Scores {
  static Scores get instance => _instance;

  static final Scores _instance = Scores._internal();

  Scores._internal();

  Map<int, Duration> scores = {};

  _submitTime(int size, Duration duration) {
    Duration? d = scores[size];
    if (d == null || d > duration) {
      scores[size] = duration;
    }
  }
  operator [](int size) {
    Duration? d = scores[size];
    if (d == null) {
      return 'no times';
    }
    else {
      printDuration(d);
    }
  }
}
String printDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}

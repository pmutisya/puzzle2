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
typedef ResultsListener = Function(Game game);

class _GameAppState extends State<GameApp> with TickerProviderStateMixin {
  late AnimationController _controller;
  late GameTheme theme = const ModernTheme();
  late int gameSize = 16;

  bool showingHome = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    showingHome = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startGame(GameTheme newTheme, int size) {
    setState(() {
      theme = newTheme;
      gameSize = size;
      print('starting game sized $gameSize');
      print('WITH THEME: $theme');
      setState(() {
        showingHome = false;
      });
    });
  }

  void _showResults(Game game) {
    setState(() {
      showingHome = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: showingHome? HomeScreen(_startGame, theme):
          GamePlayingScreen(theme, gameSize, _showResults),
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
    print('GAME ${game.rows} WON!!');
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
    if (duration.inSeconds > 5) {
      print('WON IN ${printDuration(duration)}');
      Duration? d = scores[size];
      if (d == null || d > duration) {
        scores[size] = duration;
        print('$size NOW EQUALS ${scores[size]}');
      }
    }
  }
  operator [](int size) {
    print('Getting score for $size');
    Duration? d = scores[size];
    print('GOT: $d');
    if (d == null) {
      return 'no times';
    }
    else {
      return printDuration(d);
    }
  }
}

String printDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}

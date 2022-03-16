import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:puzzle2/app_controller.dart';
import 'package:puzzle2/screens/game_playing_screen.dart';
import 'package:puzzle2/themes.dart';

import 'domain.dart';
import 'style.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (context) => AppController(),
      child: const MyApp(),
    )
  );
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
      debugShowCheckedModeBanner: false,
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
  GameTheme theme = const DefaultTheme();
  int gameSize = 16;

  bool showingHome = true;

  late Logger logger;

  @override
  void initState() {
    super.initState();
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((logRecord) {
      if (kDebugMode) {
        print('${logRecord.loggerName}: ${logRecord.message}');
        if (logRecord.stackTrace != null) {
          print('ERROR: ${logRecord.error}');
          print('${logRecord.stackTrace}');
        }
      }
    });
    showingHome = true;
  }

  void _startGame(GameTheme newTheme, int size) {
    setState(() {
      theme = newTheme;
      gameSize = size;
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


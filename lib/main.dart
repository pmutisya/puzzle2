import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:puzzle2/app_controller.dart';
import 'package:puzzle2/screens/game_playing_screen.dart';

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

class _GameAppState extends State<GameApp> with TickerProviderStateMixin {
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
  }

  @override
  Widget build(BuildContext context) {
    bool showingHome = Provider.of<AppController>(context).displaying == Screens.homeScreen;

    return Material(
      child: showingHome? const HomeScreen():
          const GamePlayingScreen(),
    );
  }
}



import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:puzzle2/themes.dart';

import 'domain.dart';

enum Screens { homeScreen, gameScreen }

class AppController with ChangeNotifier {
  late Game game;

  static const List<GameTheme> themes = [DefaultTheme(), ImageTheme(), IvoryTheme(), ModernTheme(),];
  int selectedThemIndex = 0;
  GameTheme theme = themes[0];

  int gameSize = 16;
  Screens displaying = Screens.homeScreen;

  Logger logger = Logger('AppController');

  AppController() {
    logger.info('initialising AppController');
  }

  void shiftTheme() {
    selectedThemIndex++;
    if (selectedThemIndex >= themes.length) {
      selectedThemIndex = 0;
    }
    theme = themes[selectedThemIndex];
    notifyListeners();
  }

  void setTheme(GameTheme newTheme) {
    theme = newTheme;
    selectedThemIndex = themes.indexOf(theme);

    logger.info('Setting game theme to ${theme.name}');
    notifyListeners();
  }
  void setGameSize(int newSize) {
    gameSize = newSize;
    logger.info('setting game size to $gameSize');
    notifyListeners();
  }
  void startGame() {
    displaying = Screens.gameScreen;
    notifyListeners();
  }
  void showResults() {
    displaying = Screens.homeScreen;
    notifyListeners();
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
    if (duration.inSeconds > 5) {
      Duration? d = scores[size];
      if (d == null || d > duration) {
        scores[size] = duration;
      }
    }
  }
  operator [](int size) {
    Duration? d = scores[size];
    if (d == null) {
      return 'no times';
    }
    else {
      return printDuration(d);
    }
  }
}

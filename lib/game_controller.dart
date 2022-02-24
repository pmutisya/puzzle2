import 'package:flutter/material.dart';
import 'dart:math' show Random, Point;

import 'domain.dart';
import 'game_board.dart';

Random random = Random();

class GamePlayer extends StatefulWidget {
  const GamePlayer({Key? key}) : super(key: key);

  @override
  _GamePlayerState createState() => _GamePlayerState();
}

class _GamePlayerState extends State<GamePlayer> with GameListener, TickerProviderStateMixin {
  late AnimationController _controller;
  late Game game;
  late GlobalKey<GameBoardState> gameKey;
  late GameController gameController;


  @override
  Widget build(BuildContext context) {
    return Container();
  }
}



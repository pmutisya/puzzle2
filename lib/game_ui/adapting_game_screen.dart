import 'package:flutter/material.dart';

import '../domain.dart';

class AdaptingGameScreen extends StatefulWidget {
  final Game game;
  const AdaptingGameScreen(this.game, {Key? key}) : super(key: key);

  @override
  _AdaptingGameScreenState createState() => _AdaptingGameScreenState();
}

class _AdaptingGameScreenState extends State<AdaptingGameScreen> with SingleTickerProviderStateMixin,
  GameListener{
  late AnimationController _controller;
  late Game game;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    game = widget.game;
    game.addGameListener(this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      if (orientation == Orientation.landscape) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(child: Container(),)
          ],
        );
      }
      else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(child: Container(),)
          ],
        );
      }
    },);
  }

  @override
  void gameWon() {
    setState(() {
    });
  }

  @override
  void moveComplete(int score) {
    setState(() {
    });
  }

  @override
  void moveStarted() {
  }

  @override
  void gameRestarted() {
  }
}

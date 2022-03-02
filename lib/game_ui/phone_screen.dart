import 'package:flutter/material.dart';

import '../domain.dart';

class PhoneScreen extends StatefulWidget {
  final Game game;
  const PhoneScreen(this.game, {Key? key}) : super(key: key);

  @override
  _PhoneScreenState createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> with SingleTickerProviderStateMixin,
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
  Widget getScoreRing() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: game.won? Colors.lightGreenAccent : Colors.red,
        border: Border.all(color: Colors.black, width: 3.0),
        boxShadow: const [
          BoxShadow(color: Colors.black45, offset: Offset(4, 4), spreadRadius: 4.0, blurRadius: 8)
        ]
      ),
      padding: const EdgeInsets.all(8),
      child: Text('${(game.percentCorrect*100).round().toInt()}',
        style: const TextStyle(fontSize: 48), textAlign: TextAlign.center),
    );
  }
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      if (orientation == Orientation.landscape) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            getScoreRing(),
            Expanded(child: Container(),)
          ],
        );
      }
      else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            getScoreRing(),
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
  void moveComplete() {
    setState(() {
    });
  }

  @override
  void moveStarted() {
    // TODO: implement moveStarted
  }
}

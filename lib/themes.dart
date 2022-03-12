import 'package:flutter/material.dart';

import 'domain.dart';
import 'game_application.dart';
import 'game_ui/effects_widgets.dart';

class DefaultTheme extends GameTheme {

  const DefaultTheme():
    super(name: 'Default', tileType: 'rounded');

  @override
  List<EffectsWidget> getAboveGameEffects(double progress, Game game) {
    return [];
  }

  @override
  List<EffectsWidget> getEffects(double progress, Game game) {
    List<EffectsWidget> list = [];
    if (!game.won) {
      list.add(ColoredPanelEffect(progress: progress, startColor: Colors.orangeAccent, endColor: Colors.white));
      list.add(BeamsEffect(progress: progress, color: Colors.deepOrangeAccent,));
      list.add(BeamsEffect(numberOfBeams: 11, progress: progress, innerRadius: progress,
        color: Colors.red,));
    }
    else {
      list.add(ColoredPanelEffect(progress: progress, startColor: Colors.white, endColor: Colors.orangeAccent));
      list.add(const CircularGlowWidget(
        minRadius: .25,
        centerColor: Colors.yellow, glowDuration: Duration(milliseconds: 1500)));
    }
    return  list;
  }

  @override
  List<EffectsWidget> getWinEffects(double progress, Game game) {
    return [
      StarsField(progress: progress, starCount: 20,),
      StarsField(progress: progress, starCount: 11, starColor: Colors.indigo,),
    ];
  }
}

class IvoryTheme extends GameTheme {
  const IvoryTheme(): super(name: 'Ivory', tileType: 'ivory');

  @override
  List<EffectsWidget> getAboveGameEffects(double progress, Game game) => [];

  @override
  List<EffectsWidget> getEffects(double progress, Game game) {
    return [
      ColoredPanelEffect(progress: progress, startColor: Colors.indigo, endColor: Colors.green)
    ];
  }

  @override
  List<EffectsWidget> getWinEffects(double progress, Game game) {
    return [
      StarsField(progress: progress, starCount: 40,)
    ];
  }

}
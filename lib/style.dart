import 'package:flutter/material.dart';

const Color darkBG = Color(0xFF23212B);
const Color bg = Color(0xFF313241);
const Color highlight = Color(0xFFA15DF0);
const Color text = Color(0xFFECEDF7);
const Color disabledText = Color(0xFF7E7EAA);

const Color yellow = Color(0xFFFFD74D);
const Color green = Color(0xFF3BC66F);

const LinearGradient gradient = LinearGradient(colors: [Color(0xFF846BF2), Color(0xFF6E84F8)]);
const LinearGradient bgGradient = LinearGradient(begin: Alignment.topCenter,
    stops: [0, .75, .99],
    end: Alignment.bottomCenter, colors: [Colors.black, darkBG, highlight]);

ThemeData defaultTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Poppins',
  colorScheme: const ColorScheme(
    primary: disabledText,
    background: darkBG,
    surface: bg,
    secondary: bg,
    error: highlight,
    onSurface: text, brightness: Brightness.dark,
    onError: highlight,
    onSecondary: bg,
    onBackground: text,
    onPrimary: text,
  )
);
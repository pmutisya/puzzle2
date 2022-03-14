import 'package:flutter/material.dart';

const Color darkBG = Color(0xFF23212B);
const Color bg = Color(0xFF313241);
const Color highlight = Color(0xFFA15DF0);
const Color text = Color(0xFFECEDF7);
const Color disabledText = Color(0xFF6D6E87);

const LinearGradient gradient = LinearGradient(colors: [Color(0xFF846BF2), Color(0xFF6E84F8)]);

ThemeData defaultTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Poppins',
  colorScheme: const ColorScheme(
    primary: highlight,
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
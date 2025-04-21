import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.red,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.red,
    foregroundColor: Colors.white,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.red,
    foregroundColor: Colors.white,
  ),
  colorScheme: const ColorScheme.light(
    primary: Colors.red,
    onPrimary: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black,
  ),
  textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.red,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.red,
    foregroundColor: Colors.white,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.red,
    foregroundColor: Colors.white,
  ),
  colorScheme: const ColorScheme.dark(
    primary: Colors.red,
    onPrimary: Colors.white,
    surface: Colors.black,
    onSurface: Colors.white,
  ),
  textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
);

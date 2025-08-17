import 'package:flutter/material.dart';
import 'package:smart_prep/core/constants/text_strings.dart';
import 'package:smart_prep/core/theme/app_pallete.dart';

class AppTheme {
  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderSide: BorderSide(color: color, width: 3),
    borderRadius: BorderRadius.circular(10),
  );
  static final darkThemeMode = ThemeData.dark().copyWith(
    textTheme: ThemeData.dark().textTheme.apply(fontFamily: tFont),
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    appBarTheme: const AppBarTheme(backgroundColor: AppPallete.backgroundColor),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(27),
      enabledBorder: _border(AppPallete.borderColor),
      focusedBorder: _border(AppPallete.gradient2),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppPallete.backgroundColor,
    ),
  );
  static final lightThemeMode = ThemeData.light().copyWith(
    textTheme: ThemeData.light().textTheme.apply(fontFamily: tFont),
    scaffoldBackgroundColor: AppPallete.lightBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.lightBackgroundColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(27),
      enabledBorder: _border(AppPallete.borderColor),
      focusedBorder: _border(AppPallete.gradient4),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppPallete.lightBackgroundColor,
    ),
  );
}

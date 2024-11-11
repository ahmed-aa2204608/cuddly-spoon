import 'package:flutter/material.dart';

class PayTheme {
  static final theme = ThemeData.dark().copyWith(
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 40, 40, 40),
            foregroundColor: Colors.white)),
    colorScheme: const ColorScheme.dark(
      primary: Color.fromARGB(255, 26, 171, 255),
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.all(25),
        enabledBorder: appBorder(const Color.fromARGB(255, 88, 88, 88)),
        focusedBorder: appBorder(const Color.fromARGB(255, 26, 171, 255))),
    textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'CustomFont2',
        ),
    datePickerTheme: DatePickerThemeData(
      rangePickerBackgroundColor: const Color.fromARGB(255, 7, 7, 7),
      dayBackgroundColor:
          WidgetStateProperty.all(const Color.fromARGB(255, 26, 171, 255)),
      dayForegroundColor:
          WidgetStateProperty.all(const Color.fromARGB(255, 255, 255, 255)),
      rangeSelectionBackgroundColor: const Color.fromARGB(83, 26, 171, 255),
      rangeSelectionOverlayColor:
          WidgetStateProperty.all(const Color.fromARGB(255, 7, 7, 7)),
      yearBackgroundColor:
          WidgetStateProperty.all(const Color.fromARGB(255, 88, 88, 88)),
    ),
  );

  static OutlineInputBorder appBorder(Color color) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: color,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(15),
    );
  }
}

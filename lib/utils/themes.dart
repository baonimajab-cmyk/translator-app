import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Themes {
  static const primary = Color.fromARGB(255, 255, 0, 0);
  static const primaryColor = primary;
  static const greyButtonBackgroundColor= Colors.black12;
  static final darkTheme = ThemeData(
      useMaterial3: false,
      primaryColor: Colors.black54,
      hintColor: const Color.fromARGB(154, 111, 111, 111),
      scaffoldBackgroundColor: Colors.black,
      bottomAppBarTheme: const BottomAppBarThemeData(color: Colors.white),
      unselectedWidgetColor: Colors.grey.shade600,
      iconTheme: const IconThemeData(color: Colors.white),
      splashColor: Colors.black,
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.black12,
      ),
      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: Color.fromARGB(255, 28, 28, 30),
        secondary: Color.fromARGB(255, 49, 49, 53),
        onSecondary: Colors.white60,
        onSurface: Colors.white,
        onPrimary: Colors.white70,
        outline: Color.fromARGB(153, 54, 54, 54),
      ),
      inputDecorationTheme: InputDecorationTheme(
          fillColor: Colors.white10,
          filled: true,
          border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8))),
      appBarTheme: const AppBarTheme(
          shape: Border(
              bottom:
                  BorderSide(width: 1, color: Color.fromARGB(153, 54, 54, 54))),
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          systemOverlayStyle: SystemUiOverlayStyle(
            // Status bar color
            systemNavigationBarColor: Colors.black, // Navigation bar
            statusBarColor: Colors.black, // Status bar

            // Status bar brightness (optional)
            statusBarIconBrightness:
                Brightness.light, // For Android (dark icons)
            statusBarBrightness: Brightness.dark, // For iOS (dark icons)
          ),
          centerTitle: true,
          shadowColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
      dividerColor: const Color.fromARGB(153, 54, 54, 54),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? primary
              : Colors.white24;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? const Color.fromARGB(156, 255, 0, 0)
              : Colors.white24;
        }),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.red,
        selectionColor: Colors.red.withValues(alpha: 30), // The highlight color
        selectionHandleColor: Colors.red,
      ));

  static final lightTheme = ThemeData(
      useMaterial3: false,
      primaryColor: Colors.white,
      hintColor: Colors.grey,
      scaffoldBackgroundColor: const Color.fromARGB(255, 242, 242, 242),
      bottomAppBarTheme: const BottomAppBarThemeData(color: Colors.white),
      unselectedWidgetColor: Colors.grey.shade600,
      iconTheme: const IconThemeData(color: Colors.black),
      splashColor: Colors.white,
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.black12,
      ),
      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: Colors.white,
        secondary: Color.fromARGB(255, 242, 242, 247),
        onSecondary: Colors.black87,
        onSurface: Colors.black87,
        onPrimary: Colors.black,
        outline: Color.fromARGB(60, 60, 60, 67),
      ),
      inputDecorationTheme: InputDecorationTheme(
          fillColor: const Color.fromARGB(255, 242, 242, 247),
          filled: true,
          border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8))),
      appBarTheme: const AppBarTheme(
          shape: Border(
              bottom:
                  BorderSide(width: 1, color: Color.fromARGB(30, 60, 60, 67))),
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarColor:
                Color.fromARGB(255, 242, 242, 247), // Navigation bar
            // Status bar color
            statusBarColor: Colors.white,
            // Status bar brightness (optional)
            statusBarIconBrightness:
                Brightness.dark, // For Android (dark icons)
            statusBarBrightness: Brightness.light, // For iOS (dark icons)
          ),
          centerTitle: true,
          shadowColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
              fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500)),
      dividerColor: const Color.fromARGB(60, 60, 60, 67),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? primary
              : Colors.black12;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? const Color.fromARGB(156, 255, 0, 0)
              : Colors.black12;
        }),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.red,
        selectionColor: Colors.red.withValues(alpha: 30), // The highlight color
        selectionHandleColor: Colors.red,
      ));
}

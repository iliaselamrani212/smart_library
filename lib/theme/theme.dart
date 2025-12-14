import 'package:flutter/material.dart';

//Light Theme
ThemeData lightMode =ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    appBarTheme: const AppBarTheme(
      titleTextStyle: TextStyle(
        fontSize: 24,
      ),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
      ),
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      displayMedium: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
      ),
      headlineSmall: TextStyle(
        fontSize: 16,
      ),
    ),

    //Elevated Button Theme (light)
    elevatedButtonTheme:  ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue, // background color
          foregroundColor: Colors.white, // text color
          textStyle: const TextStyle(fontSize: 24,), // text style
          minimumSize: const Size(double.infinity, 56),
          maximumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        )
    ),

  popupMenuTheme: PopupMenuThemeData(
    textStyle: TextStyle(
      color: Colors.black,
    )
  )
);

//Dark Theme
ThemeData darkMode =ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF2F4F7F), //
    appBarTheme: const AppBarTheme(
      titleTextStyle: TextStyle(
        fontSize: 24,
      ),
      backgroundColor:  Color(0xFF2F4F7F),
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
      ),
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displayMedium: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
      ),
      headlineSmall: TextStyle(
        fontSize: 16,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F4F7F),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 24,),
          minimumSize: const Size(double.infinity, 56),
          maximumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        )
    ),

  popupMenuTheme: PopupMenuThemeData(
    textStyle: TextStyle(
      color: Colors.white,
    )
  )
);
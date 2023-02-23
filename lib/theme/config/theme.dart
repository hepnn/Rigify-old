import 'package:flutter/material.dart';

ShapeBorder customShapeBorder = const RoundedRectangleBorder(
  borderRadius: BorderRadius.only(
    bottomLeft: Radius.circular(25.0),
    bottomRight: Radius.circular(25.0),
  ),
);

final ThemeData lightTheme = ThemeData.light().copyWith(
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Colors.black,
  ),
  tabBarTheme: TabBarTheme(
    indicator: ShapeDecoration(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      color: const Color.fromARGB(255, 223, 224, 226),
      shadows: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.05),
          spreadRadius: 1,
          blurRadius: 7,
          offset: const Offset(0, 0), // changes position of shadow
        ),
      ],
    ),
    labelColor: Colors.black,
    unselectedLabelColor: Colors.grey,
  ),
  cardColor: const Color.fromARGB(255, 245, 246, 250),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.black,
    ),
  ),
  appBarTheme: const AppBarTheme(
      color: Colors.white,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
          color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
);

final ThemeData darkTheme = ThemeData.dark().copyWith(
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Colors.white,
  ),
  tabBarTheme: TabBarTheme(
    indicator: ShapeDecoration(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      color: const Color.fromARGB(255, 38, 38, 39),
      shadows: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.05),
          spreadRadius: 1,
          blurRadius: 7,
          offset: const Offset(0, 0), // changes position of shadow
        ),
      ],
    ),
    unselectedLabelColor: Colors.grey,
  ),
  cardColor: const Color.fromARGB(255, 60, 59, 59),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.white,
    ),
  ),
);

import "package:flutter/material.dart";

class AppTheme{
  static BoxDecoration get buildBoxDecoration => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFA4A4F5),
        Colors.white
      ],
    ),
  );

  static TextStyle get Titlefont =>const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.black54,
  ) ;

}



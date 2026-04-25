import 'package:flutter/material.dart';
import 'package:flame/extensions.dart';

class GameConfig {
  // --- Responsive & Layout Settings ---
  static const double maxWidth = 1200.0;
  static const double desktopBreakpoint = 900.0;
  static const double desktopMargin = 40.0;
  
  // --- Game Resolution Settings ---
  // Using a fixed logical resolution ensures consistent scaling
  static final Vector2 fixedResolution = Vector2(600, 1000);

  // --- Snake Gameplay Settings ---
  static const double cellSize = 20.0;
  static const double initialSpeed = 0.15;
  static const double speedIncrement = 0.95; // Multiplier

  static const List<Color> matchColors = [
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
  ];
  
  // --- UI Colors ---
  static const Color backgroundColor = Color(0xFF212121);
  static const Color snakeHeadColor = Colors.green;
  static const Color foodColor = Colors.red;
}

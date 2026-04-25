import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config.dart';

class Food extends RectangleComponent with HasGameReference {
  final Color foodColor;
  //static const double cellSize = 20.0;
  

  Food({
    required Vector2 position,
    required this.foodColor,
  }) : super(
          position: position,
          size: Vector2.all(GameConfig.cellSize),
          //anchor: Anchor.topLeft,
        ) {
    // Set the paint color based on the passed color
    paint = Paint()..color = foodColor;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Add a slight decorative border to make it look like a "collectible"
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = Colors.white30
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      ),
    );
  }
}

/* 





class Food extends RectangleComponent {
  final Color foodColor;

  Food({
    required Vector2 position,
    required this.foodColor,
  }) : super(
          position: position,
          size: Vector2.all(GameConfig.cellSize),
          paint: Paint()..color = foodColor,
        );
}


 */
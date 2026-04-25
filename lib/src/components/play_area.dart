import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config.dart';

class PlayArea extends RectangleComponent with HasGameReference {
  PlayArea()
      : super(
          paint: Paint()..color = GameConfig.backgroundColor,
          // We set the size based on our Fixed Resolution in config
          size: GameConfig.fixedResolution,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Add a border to the play area to define the "walls"
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = Colors.white10
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      ),
    );
  }
}


import 'dart:async';
import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Direction { up, down, left, right }

class SnakeGame extends FlameGame with KeyboardEvents, TapCallbacks {
  static const double cellSize = 20.0;
  
  List<Vector2> snakeBody = [Vector2(5, 5)];
  Vector2 foodLocation = Vector2(10, 10);
  Direction currentDirection = Direction.right;
  double moveTimer = 0;
  double speed = 0.15; 
  bool isGameOver = false;

  final List<Color> snakeColors = [
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
  ];

  @override
  FutureOr<void> onLoad() {
    spawnFood();
    return super.onLoad();
  }

  void spawnFood() {
    final random = Random();
    int maxX = (size.x / cellSize).floor();
    int maxY = (size.y / cellSize).floor();
    foodLocation = Vector2(
      random.nextInt(maxX).toDouble(),
      random.nextInt(maxY).toDouble(),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    moveTimer += dt;
    if (moveTimer >= speed) {
      moveTimer = 0;
      moveSnake();
    }
  }

  void moveSnake() {
    final head = snakeBody.first.clone();

    switch (currentDirection) {
      case Direction.up: head.y -= 1; break;
      case Direction.down: head.y += 1; break;
      case Direction.left: head.x -= 1; break;
      case Direction.right: head.x += 1; break;
    }
    // no walls
    int maxX = (size.x / cellSize).floor();
    int maxY = (size.x / cellSize).floor();

    // Collision: Walls
    if (head.x < 0) head.x = maxX - 1.0; 
    if (head.x >= maxX) head.x = 0; 
    if (head.y < 0) head.y = maxY - 1.0;
    if (head.y >= maxY) head.y = 0;  
    

    // Collision: Self
    if (snakeBody.contains(head)) {
      isGameOver = true;
      return;
    }

    snakeBody.insert(0, head);

    // Collision: Food
    if (head == foodLocation) {
      spawnFood();
      // Optional: increase speed slightly every time it eats
      if (speed > 0.05) speed -= 0.005;
    } else {
      snakeBody.removeLast();
    }
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp) && currentDirection != Direction.down) {
      currentDirection = Direction.up;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown) && currentDirection != Direction.up) {
      currentDirection = Direction.down;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) && currentDirection != Direction.right) {
      currentDirection = Direction.left;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight) && currentDirection != Direction.left) {
      currentDirection = Direction.right;
    }
    return KeyEventResult.handled;
  }

  @override
  void onTapDown(TapDownEvent event) {
    final touchPoint = event.localPosition;
    if (touchPoint.y < size.y / 3 && currentDirection != Direction.down) {
      currentDirection = Direction.up;
    } else if (touchPoint.y > size.y * 2 / 3 && currentDirection != Direction.up) {
      currentDirection = Direction.down;
    } else if (touchPoint.x < size.x / 2 && currentDirection != Direction.right) {
      currentDirection = Direction.left;
    } else if (touchPoint.x > size.x / 2 && currentDirection != Direction.left) {
      currentDirection = Direction.right;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw Background
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFF1A1A1A));

    // Draw Food
    canvas.drawRect(
      Rect.fromLTWH(foodLocation.x * cellSize, foodLocation.y * cellSize, cellSize, cellSize),
      Paint()..color = Colors.red,
    );

    // Draw Snake
    for (int i = 0; i < snakeBody.length; i++) {
      final paint = Paint()..color = snakeColors[i % snakeColors.length];
      canvas.drawRect(
        Rect.fromLTWH(
          snakeBody[i].x * cellSize, 
          snakeBody[i].y * cellSize, 
          cellSize - 1, 
          cellSize - 1
        ),
        paint,
      );
    }
  }
}

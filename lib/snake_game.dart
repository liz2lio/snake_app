import 'dart:async';
import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Direction { up, down, left, right }

class SnakeSegment {
  Vector2 position;
  Color color;
  SnakeSegment(this.position, this.color
  );
}

class SnakeGame extends FlameGame with KeyboardEvents, TapCallbacks {
  static const double cellSize = 20.0;
  List<SnakeSegment> snakeBody = [];
  
  Vector2 foodLocation = Vector2(10, 10);
  late Color foodColor;
  Direction currentDirection = Direction.right;

  double moveTimer = 0;
  double speed = 0.15; 
  bool isGameOver = false;

  double foodTimer = 0;
  static const double foodExpiry = 10.0;

  final List<Color> snakeColors = [
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
  ];

  @override
  FutureOr<void> onLoad() {

    final random = Random();
    for (int i = 0; i < 3; i++) {
      snakeBody.add(SnakeSegment(
        Vector2(5.0-i, 5.0),
        snakeColors[random.nextInt(snakeColors.length)]
      ));
    }
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
    foodColor = snakeColors[random.nextInt(snakeColors.length)];   

    foodTimer = 0; 
  }

 @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    foodTimer += dt;
    if (foodTimer >= foodExpiry) {
      //moveTimer = 0;
      spawnFood();
    }
    moveTimer += dt;
    if (moveTimer >= speed) {
      moveTimer = 0;
      moveSnake();
  }
  }
  void moveSnake() {
    
    final newHead = snakeBody.first.position.clone();

    switch (currentDirection) {
      case Direction.up: newHead.y -= 1; break;
      case Direction.down: newHead.y += 1; break;
      case Direction.left: newHead.x -= 1; break;
      case Direction.right: newHead.x += 1; break;
    }

    // no walls
   int maxX = (size.x / cellSize).floor();
   int maxY = (size.y / cellSize).floor();

    if (newHead.x < 0) newHead.x = maxX - 1.0;
    if (newHead.x >= maxX) newHead.x = 0;
    if (newHead.y < 0) newHead.y = maxY - 1.0;
    if (newHead.y >= maxY) newHead.y = 0;
    
    //check for collisions with self
    if (snakeBody.any((s) => s.position == newHead)) {              
     isGameOver = true;
      return;
    }

    //if we eat food
    if (newHead == foodLocation) {
  //add to body and spawn new food
    snakeBody.insert(0, SnakeSegment(newHead, foodColor));
    checkColorMatch();
    spawnFood();

  //increase speed
    if (speed > 0.05) {
      speed *= 0.95; 
    }
  } else {
  for (int i = snakeBody.length - 1; i > 0; i--) {
    snakeBody[i].position = snakeBody[i - 1].position.clone();
  }
// update the body
  snakeBody.first.position = newHead;
  }
 } 
  /*  // Collision: Food
  if (newHead == foodLocation) {
    checkColorMatch();
    spawnFood();
  } else {
    snakeBody.removeLast();
  }
  */
  void checkColorMatch() {
    if (snakeBody.length < 3) return;
    
    List<int> toRemove = [];
    for (int i = 0; i <= snakeBody.length - 3; i++) {
      if (snakeBody[i].color == snakeBody[i + 1].color &&
          snakeBody[i].color == snakeBody[i + 2].color) {
        toRemove.addAll([i, i + 1, i + 2]);
        break;
      }
    }
    if (toRemove.isNotEmpty) {
      toRemove.sort((a, b) => b.compareTo(a));
      for (var index in toRemove) {
        snakeBody.removeAt(index);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw Background
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFF1A1A1A));

    // Draw Food
    canvas.drawRect(
      Rect.fromLTWH(foodLocation.x * cellSize, foodLocation.y * cellSize, cellSize - 2, cellSize -2),
      Paint()..color = foodColor,
    );

    // Draw Snake
    for (var segment in snakeBody) {
     
      canvas.drawRect(
        Rect.fromLTWH(
          segment.position.x * cellSize, 
          segment.position.y * cellSize, 
          cellSize - 1, 
          cellSize - 1
        ),
        Paint()..color =segment.color,
      );
    }
  }
  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is KeyDownEvent;

    if (isKeyDown) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowUp) && currentDirection != Direction.down) {
      currentDirection = Direction.up;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown) && currentDirection != Direction.up) {
      currentDirection = Direction.down;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) && currentDirection != Direction.right) {
      currentDirection = Direction.left;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight) && currentDirection != Direction.left) {
      currentDirection = Direction.right;
    }
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

}

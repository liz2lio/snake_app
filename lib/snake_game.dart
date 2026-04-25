import 'dart:async';
import 'dart:math';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/config.dart';

enum Direction { up, down, left, right }
enum GameState { start, playing, gameOver, won }

class SnakeSegment {
  Vector2 position;
  Color color;
  SnakeSegment(this.position, this.color);
}

class SnakeGame extends FlameGame with KeyboardEvents, TapCallbacks {
  final ValueNotifier<GameState> state = ValueNotifier(GameState.start);
  final ValueNotifier<int> score = ValueNotifier(0);
  final ValueNotifier<int> highScore = ValueNotifier<int>(0);

  // Use the cell size from config for consistency
  static const double cellSize = GameConfig.cellSize;
  List<SnakeSegment> snakeBody = [];

  Vector2 foodLocation = Vector2(10, 10);
  late Color foodColor;
  Direction currentDirection = Direction.right;

  double foodTimer = 0;
  double moveTimer = 0;
  double speed = GameConfig.initialSpeed;

  final List<Color> snakeColors = GameConfig.matchColors;

  @override
  FutureOr<void> onLoad() {
    // We don't initialize snakeBody here anymore, resetGame() handles it.
    camera.viewport = FixedAspectRatioViewport(aspectRatio: 6/10);
    camera.viewfinder.anchor = Anchor.topLeft;
    spawnFood();
    return super.onLoad();
  }

  void spawnFood() {
    final random = Random();
    // GameConfig resolution
    int maxX = (size.x / cellSize).floor();
    int maxY = (size.y / cellSize).floor();

    foodLocation = Vector2(
      random.nextInt(maxX -1).toDouble(),
      random.nextInt(maxY -1).toDouble(),
    );

    foodColor = GameConfig.matchColors[random.nextInt(GameConfig.matchColors.length)];
  
    foodTimer = 0.0;
  }


  void setLevel(String level) {
    switch (level) {
      case 'Easy': speed = GameConfig.initialSpeed * 1.5; 
      break;
      case 'Moderate': speed = GameConfig.initialSpeed; 
      break;
      case 'Hard': speed = GameConfig.initialSpeed * 0.6; 
      break;
    }
    resetGame();
  }

  void resetGame() {
    final random = Random();
    score.value = 0;
    snakeBody.clear();
    currentDirection = Direction.right;
    
    // Initialize 3 segments
    for (int i = 0; i < 3; i++) {
      snakeBody.add(SnakeSegment(
        Vector2(5.0 - i, 5.0),
        snakeColors[random.nextInt(snakeColors.length)],
      ));
    }
    
    spawnFood();
    state.value = GameState.playing;  
  }

  void onDie() {
    state.value = GameState.gameOver;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (state.value != GameState.playing) return;

    foodTimer += dt;
    if (foodTimer >= 10.0) {
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

    int maxX = (GameConfig.fixedResolution.x / GameConfig.cellSize).floor();
    int maxY = (GameConfig.fixedResolution.y / GameConfig.cellSize).floor();

    // Wrap-around logic
    if (newHead.x < 0) newHead.x = maxX - 1.0;
    if (newHead.x >= maxX) newHead.x = 0;

    if (newHead.y < 0) {
        newHead.y = maxY - 1.0; 
    } else if (newHead.y >= maxY) {
        newHead.y = 0; 
    }


    // --- COLLISION CHECK: SELF ---
    
    for (var segment in snakeBody) {
      if (newHead.x == segment.position.x && newHead.y == segment.position.y) {
        onDie();
        return;
      }
    }

    // --- COLLISION CHECK: FOOD ---

      if (newHead.distanceTo(foodLocation) < 0.1) {
        updateScore(10);

      snakeBody.insert(0, SnakeSegment(newHead, foodColor));
      
      checkColorMatch();
      spawnFood();

      if (speed > 0.05) {
        speed *= GameConfig.speedIncrement;
      }
    } else {
      // Normal movement
      for (int i = snakeBody.length - 1; i > 0; i--) {
        snakeBody[i].position = snakeBody[i - 1].position.clone();
      }
      snakeBody.first.position = newHead;
    }
  }

  void checkColorMatch() {
    if (snakeBody.length < 3) return;

    for (int i = 0; i <= snakeBody.length - 3; i++) {
      if (snakeBody[i].color == snakeBody[i + 1].color &&
          snakeBody[i].color == snakeBody[i + 2].color) {
        
        // 3 color matches
        snakeBody.removeRange(i, i + 3);
        //score.value += 50;
        updateScore(50);
        // Win condition check
        if (score.value >= 1000) {
          state.value = GameState.won;
        }
        break; 
      }
    }
  }

@override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    
    // respawn 
    if (state.value == GameState.playing) {
      int maxX = (size.x / cellSize).floor();
      int maxY = (size.y / cellSize).floor();
      
      if (foodLocation.x >= maxX || foodLocation.y >= maxY) {
        spawnFood();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
       
    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, GameConfig.fixedResolution.x, GameConfig.fixedResolution.y),
      Paint()..color = const Color.fromARGB(255, 59, 58, 58),
    ); 

    
    // Draw Food 
    canvas.drawRect(
      Rect.fromLTWH(
        foodLocation.x * cellSize, 
        foodLocation.y * cellSize, 
        cellSize - 2, cellSize - 2),
      
      Paint()..color = foodColor,
    );


    // Draw Snake
    for (var segment in snakeBody) {
      canvas.drawRect(
        Rect.fromLTWH(
          segment.position.x * cellSize,
          segment.position.y * cellSize,
          cellSize - 1,
          cellSize - 1,
        ),
        Paint()..color = segment.color,
      );
    }
    super.render(canvas);
  }

  void updateScore(int points) {
    score.value += points;

    if (score.value > highScore.value) {
      highScore.value = score.value;
    }
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
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
}



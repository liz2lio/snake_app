import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
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
  late final ValueNotifier<List<String>> completedLevels = ValueNotifier([]);

  // Use the cell size from config for consistency
  static const double cellSize = GameConfig.cellSize;
  List<SnakeSegment> snakeBody = [];

  Vector2 foodLocation = Vector2(10, 10);
  late Color foodColor;
  Direction currentDirection = Direction.right;

  double foodTimer = 0;
  double moveTimer = 0;
  double speed = GameConfig.initialSpeed;

  String currentLevel = 'Moderate';

  final List<Color> snakeColors = GameConfig.matchColors;

  @override
  FutureOr<void> onLoad() async {
    await loadProgress(); //load saved data
        
    camera.viewport = FixedAspectRatioViewport(aspectRatio: 6/10);
    camera.viewfinder.anchor = Anchor.topLeft;
    spawnFood();
    return super.onLoad();
  }

  //load from local storage
  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    completedLevels.value = prefs.getStringList('completedLevels') ?? [];

    highScore.value = prefs.getInt('highScore') ?? 0;

    // Load game state
    await loadGameState();
  }

  //save to local storage
  Future<void> saveProgress(String level) async {
    if (!completedLevels.value.contains(level)) {
      completedLevels.value.add(level);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('completedLevels', completedLevels.value);
    }
  }

  // Load game state from shared preferences
  Future<void> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final gameStateJson = prefs.getString('gameState');
    if (gameStateJson != null) {
      try {
        final gameState = jsonDecode(gameStateJson) as Map<String, dynamic>;

        // Load snake body
        final snakeBodyData = gameState['snakeBody'] as List<dynamic>;
        snakeBody = snakeBodyData.map((segment) {
          final pos = segment['position'];
          return SnakeSegment(
            Vector2(pos['x'].toDouble(), pos['y'].toDouble()),
            Color(segment['color'] as int),
          );
        }).toList();

        // Load food
        final foodPos = gameState['foodLocation'];
        foodLocation = Vector2(foodPos['x'].toDouble(), foodPos['y'].toDouble());
        foodColor = Color(gameState['foodColor'] as int);

        // Load other state
        currentDirection = Direction.values[gameState['currentDirection'] as int];
        score.value = gameState['score'] as int;
        speed = gameState['speed'] as double;
        currentLevel = gameState['currentLevel'] as String;
        state.value = GameState.values[gameState['gameState'] as int];
        foodTimer = gameState['foodTimer'] as double;
        moveTimer = gameState['moveTimer'] as double;

        // If loaded state is playing, continue
        if (state.value == GameState.playing) {
          // Game is loaded and ready
        }
      } catch (e) {
        // If loading fails, start fresh
        resetGame(initialState: GameState.start);
      }
    } else {
      // No saved state, start fresh
      resetGame(initialState: GameState.start);
    }
  }

  // Save game state to shared preferences
  Future<void> saveGameState() async {
    if (state.value != GameState.playing) return; // Only save when playing

    final prefs = await SharedPreferences.getInstance();
    final gameState = {
      'snakeBody': snakeBody.map((segment) => {
        'position': {'x': segment.position.x, 'y': segment.position.y},
        'color': segment.color.value,
      }).toList(),
      'foodLocation': {'x': foodLocation.x, 'y': foodLocation.y},
      'foodColor': foodColor.value,
      'currentDirection': currentDirection.index,
      'score': score.value,
      'speed': speed,
      'currentLevel': currentLevel,
      'gameState': state.value.index,
      'foodTimer': foodTimer,
      'moveTimer': moveTimer,
    };
    await prefs.setString('gameState', jsonEncode(gameState));
  }

  // Clear saved game state
  Future<void> clearSavedGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gameState');
  }

  //mark level complete
  Future<void> markLevelComplete(String levelName) async {
    final prefs = await SharedPreferences.getInstance();
    List <String> completed = prefs.getStringList('completedLevels') ?? [];

    if (!completed.contains(levelName)) {
      completed.add(levelName);

      await prefs.setStringList('completedLevels',completed);

      completedLevels.value = List.from(completed);
    }
  }

  //food
  void spawnFood() {
    final random = Random();
    
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
    currentLevel = level;
    
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

  void resetGame({GameState initialState = GameState.playing}) {
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
    state.value = initialState;

    // Clear saved game state when starting new game
    clearSavedGameState();
  }

  void onDie() {
    state.value = GameState.gameOver;
    // Clear saved state on death
    clearSavedGameState();
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

    // Save game state after each move
    saveGameState();
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
          markLevelComplete(currentLevel);
          // Clear saved state on win
          clearSavedGameState();
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

  void updateScore(int points) async {
    score.value += points;

    if (score.value > highScore.value) {
      highScore.value = score.value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', highScore.value);
    }
  }

  void changeDirection(Direction newDirection) {
    if ((currentDirection == Direction.up && newDirection != Direction.down) ||
        (currentDirection == Direction.down && newDirection != Direction.up) ||
        (currentDirection == Direction.left && newDirection != Direction.right) ||
        (currentDirection == Direction.right && newDirection != Direction.left)) {
      currentDirection = newDirection;
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



import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:snake_app/snake_game.dart';
import 'src/config.dart';
import 'src/widgets/score_card.dart';
import 'src/widgets/game_menu.dart';

void main() => runApp(const MaterialApp(home: MainGamePage()));

class MainGamePage extends StatefulWidget {
  const MainGamePage({super.key});

  @override
  State<MainGamePage> createState() => _MainGamePageState();
}

class _MainGamePageState extends State<MainGamePage> {
  late SnakeGame _game;

  @override
  void initState() {
    super.initState();
    _game = SnakeGame();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > GameConfig.desktopBreakpoint;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: GameConfig.maxWidth),
          child: Container(
            margin: EdgeInsets.all(isDesktop ? GameConfig.desktopMargin : 0),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: isDesktop ? BorderRadius.circular(20) : BorderRadius.zero,
              border: isDesktop ? Border.all(color: Colors.white10) : null,
            ),
            child: GameWidget<SnakeGame>(
              game: _game,
              overlayBuilderMap: {
                // 1. The HUD Score Overlay
                'ScoreOverlay': (context, game) {
                  return ScoreCard(score: game.score);
                },

                // 2. The Universal Menu (Start, Game Over, Win)
                'MenuOverlay': (context, game) {
                  return ValueListenableBuilder<GameState>(
                    valueListenable: game.state,
                    builder: (context, state, _) {
                      // Hide the menu if the game is currently being played
                      if (state == GameState.playing) {
                        return const SizedBox.shrink();
                      }

                      return ValueListenableBuilder<int>(
                        valueListenable: game.highScore,
                        builder: (context, currentHigh, _) {
                          return GameMenu(
                            state: state,
                            score: game.score.value,
                            highScore: currentHigh,
                            onLevelSelect: (level) => game.setLevel(level),
                          );
                          }, 
                      );
                    },
                  );
                },

                // 3. Controls Overlay for touch devices
                'ControlsOverlay': (context, game) {
                  return ControlsOverlay(game: game as SnakeGame);
                },
              },
              
              initialActiveOverlays: const ['ScoreOverlay', 'MenuOverlay', 'ControlsOverlay'],
            ),
          ),
        ),
      ),
    );
  }
}

class ControlsOverlay extends StatelessWidget {
  final SnakeGame game;

  const ControlsOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonSize = 60.0;

    return Stack(
      children: [
        // Left button
        Positioned(
          left: 20,
          top: size.height / 2 - buttonSize / 2,
          child: SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: ElevatedButton(
              onPressed: () => game.changeDirection(Direction.left),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.7),
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.arrow_left, size: 30),
            ),
          ),
        ),
        // Right button
        Positioned(
          right: 20,
          top: size.height / 2 - buttonSize / 2,
          child: SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: ElevatedButton(
              onPressed: () => game.changeDirection(Direction.right),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.7),
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.arrow_right, size: 30),
            ),
          ),
        ),
        // Up button
        Positioned(
          top: 20,
          left: size.width / 2 - buttonSize / 2,
          child: SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: ElevatedButton(
              onPressed: () => game.changeDirection(Direction.up),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.7),
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.arrow_upward, size: 30),
            ),
          ),
        ),
        // Down button
        Positioned(
          bottom: 20,
          left: size.width / 2 - buttonSize / 2,
          child: SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: ElevatedButton(
              onPressed: () => game.changeDirection(Direction.down),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.7),
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.arrow_downward, size: 30),
            ),
          ),
        ),
      ],
    );
  }
}



import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:snake_app/snake_game.dart';
import 'src/config.dart';
import 'src/widgets/score_card.dart';
import 'src/widgets/game_menu.dart';

void main() => runApp(const MaterialApp(
      home: MainGamePage(),
      debugShowCheckedModeBanner: false,
    ));

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
                // 1. HUD Score Overlay
                'ScoreOverlay': (context, game) {
                  return IgnorePointer(
                    ignoring: true,
                    child: ScoreCard(score: game.score),
                  );
                },

                // 2. The Universal Menu (Start, Game Over, Win)
                'MenuOverlay': (context, game) {
                  return ValueListenableBuilder<GameState>(
                    valueListenable: game.state,
                    builder: (context, state, _) {
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

                // 3. Updated Clustered Keypad Overlay
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
    return ValueListenableBuilder<GameState>(
      valueListenable: game.state,
      builder: (context, state, _) {
        // Only show buttons during active gameplay
        if (state != GameState.playing) return const SizedBox.shrink();

        return Stack(
          children: [
            Positioned(
              bottom: 40, // Clustered at the bottom for easy thumb access
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // UP BUTTON
                  _buildKey(Icons.arrow_upward, () => game.changeDirection(Direction.up)),
                  const SizedBox(height: 8), 
                  
                  // ROW: LEFT, DOWN, RIGHT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildKey(Icons.arrow_back, () => game.changeDirection(Direction.left)),
                      const SizedBox(width: 8), 
                      _buildKey(Icons.arrow_downward, () => game.changeDirection(Direction.down)),
                      const SizedBox(width: 8), 
                      _buildKey(Icons.arrow_forward, () => game.changeDirection(Direction.right)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKey(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 65,
      height: 65,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.black.withOpacity(0.6),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white24, width: 1),
          ),
        ),
        child: Icon(icon, size: 32),
      ),
    );
  }
}



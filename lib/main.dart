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
            child: GestureDetector(
              onPanEnd: (details) {
                final velocity = details.velocity.pixelsPerSecond;
                const double threshold = 500.0; // Minimum velocity to register as swipe

                if (velocity.dx.abs() > velocity.dy.abs()) {
                  // Horizontal swipe
                  if (velocity.dx > threshold) {
                    _game.changeDirection(Direction.right);
                  } else if (velocity.dx < -threshold) {
                    _game.changeDirection(Direction.left);
                  }
                } else {
                  // Vertical swipe
                  if (velocity.dy > threshold) {
                    _game.changeDirection(Direction.down);
                  } else if (velocity.dy < -threshold) {
                    _game.changeDirection(Direction.up);
                  }
                }
              },
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
                },
                
                initialActiveOverlays: const ['ScoreOverlay', 'MenuOverlay'],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



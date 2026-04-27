import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:snake_app/snake_game.dart';
import 'src/config.dart';
import 'src/widgets/score_card.dart';
import 'src/widgets/game_menu.dart';
import 'src/widgets/game_controls.dart';

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
                // 1. HUD Score Overlay (IgnorePointer ensures touch goes through to game)
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

                // 3. The New Externalized Controls Overlay
                'ControlsOverlay': (context, game) {
                  return GameControls(game: game);
                },
              },
              initialActiveOverlays: const [
                'ScoreOverlay',
                'MenuOverlay',
                'ControlsOverlay'
              ],
            ),
          ),
        ),
      ),
    );
  }
}



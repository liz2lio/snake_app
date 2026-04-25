import 'package:flutter/material.dart';
import 'package:flame/game.dart';
//import 'snake_game.dart';
import 'src/config.dart';
import 'src/widgets/score_card.dart';
import 'package:snake_app/snake_game.dart';


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
                'ScoreOverlay': (context, game) {
                try {
                  final dynamic snakeGame = game;
                  return ScoreCard(score: snakeGame.score);
                } catch (e) {
                  // Handle the case where the game is not of type SnakeGame
                  return const SizedBox.shrink();
                }
                
                
                //final dynamic dynamicGame = game;
                //return ScoreCard(score: dynamicGame.score);
              },
              },
              initialActiveOverlays: const ['ScoreOverlay'],
            ),
          ),
        ),
      ),
    );
  }
}



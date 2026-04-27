import 'package:flutter/material.dart';
import '../../snake_game.dart'; 

class GameControls extends StatelessWidget {
  final SnakeGame game;

  const GameControls({super.key, required this.game});

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
              bottom: 40, 
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildKey(Icons.arrow_upward, () => game.changeDirection(Direction.up)),
                  const SizedBox(height: 8),
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
          backgroundColor: const Color.fromARGB(255, 27, 27, 27),
          foregroundColor: Colors.white,
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



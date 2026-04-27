import 'package:flutter/material.dart';
import '../../snake_game.dart'; // To access the GameState enum

class GameMenu extends StatelessWidget {
  final GameState state;
  final int score;
  final int highScore;
  final Function(String) onLevelSelect;

  const GameMenu({
    super.key,
    required this.state,
    required this.score,
    required this.highScore,
    required this.onLevelSelect,
  });

  @override
  Widget build(BuildContext context) {
    String title;
    Color titleColor;

    // Determine UI flavor based on state
    switch (state) {
      case GameState.gameOver:
        title = "GAME OVER";
        titleColor = Colors.redAccent;
        break;
      case GameState.won:
        title = "YOU WON!";
        titleColor = Colors.greenAccent;
        break;
      default:
        title = "SNAKE & MATCH";
        titleColor = Colors.white;
    }

    return Container(
      color: const Color.fromARGB(255, 43, 41, 41),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: titleColor,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 10),

            //show current score
            Text("Score: $score", 
              style: const TextStyle(
                color: Colors.white, fontSize: 24)), 
            
              const SizedBox(height: 30),

            const Text("CHOOSE LEVEL", 
                       style: TextStyle(color: Colors.white54, fontSize: 14, letterSpacing: 2)),
            const SizedBox(height: 20),
            
            
            // Layout difficulty buttons
            Wrap(
              spacing: 20,
              children: ['Easy', 'Moderate', 'Hard'].map((lvl) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () => onLevelSelect(lvl),
                  child: Text(lvl),
                );
              }).toList(),
            ),

            const SizedBox(height: 50),
            Text("HIGHEST SCORE: $highScore", 
                 style: const TextStyle(color: Colors.white24, fontSize: 12)),
        ],  
        ),
        
      ),
    );
  }
}



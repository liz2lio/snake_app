import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  final dynamic score;

  //final ValueNotifier<int> score;
  const ScoreCard({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    if (score == null) {
      return const SizedBox.shrink(); // Return an empty widget if score is not a ValueNotifier<int>
    }
    return ValueListenableBuilder<int>(
      valueListenable: score,
      builder: (context, scoreValue, child) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'SCORE: $scoreValue',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        );
      },
    );
  }
}



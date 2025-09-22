import 'package:flutter/material.dart';
import '../ui/widgets/game_header.dart';
import 'quiz_page.dart';
import '../state/game_state.dart';

class ResultsPage extends StatelessWidget {
  final int totalPoints;
  final int maxPoints;
  final String missionTitle;
  final String missionId;
  final String? nextMissionId;
  final int passingScore;
  const ResultsPage({
    super.key,
    required this.totalPoints,
    required this.maxPoints,
    required this.missionTitle,
    required this.missionId,
    required this.nextMissionId,
    required this.passingScore,
  });

  @override
  Widget build(BuildContext context) {
    final passed = totalPoints >= passingScore;
    if (passed) {
      GameState.instance.markCompleted(missionId);
    }
    return Scaffold(
      appBar: const GameHeader(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(
              missionTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Text(
              'You scored $totalPoints out of $maxPoints LEADO crowns',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Text(
              passed ? 'Trophy Unlocked! 🎉' : 'Keep trying to pass this mission!',
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            if (passed && nextMissionId != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => QuizPage(missionId: nextMissionId!)),
                  );
                },
                child: const Text('Next Mission'),
              )
            else
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => QuizPage(missionId: missionId)),
                  );
                },
                child: const Text('Retry Mission'),
              ),
          ],
        ),
      ),
    );
  }
}

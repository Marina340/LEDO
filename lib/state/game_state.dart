import 'package:flutter/foundation.dart';

class GameState {
  GameState._internal();
  static final GameState instance = GameState._internal();

  // Coins earned across missions
  final ValueNotifier<int> coins = ValueNotifier<int>(0);

  // Completed mission IDs
  final Set<String> completedMissions = <String>{};

  // In-memory mission progress: missionId -> content index and score
  final Map<String, int> _missionIndex = <String, int>{};
  final Map<String, int> _missionScore = <String, int>{};

  void addCoins(int count) {
    coins.value += count;
  }

  bool isCompleted(String missionId) => completedMissions.contains(missionId);
  void markCompleted(String missionId) => completedMissions.add(missionId);

  void reset() {
    coins.value = 0;
    completedMissions.clear();
    _missionIndex.clear();
    _missionScore.clear();
  }

  // Progress APIs
  int getContentIndex(String missionId) => _missionIndex[missionId] ?? 0;
  int getScore(String missionId) => _missionScore[missionId] ?? 0;
  void saveProgress(String missionId, int contentIndex, int score) {
    _missionIndex[missionId] = contentIndex;
    _missionScore[missionId] = score;
  }
  void clearProgress(String missionId) {
    _missionIndex.remove(missionId);
    _missionScore.remove(missionId);
  }
}

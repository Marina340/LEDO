import 'package:flutter/foundation.dart';
import '../services/preferences_service.dart';

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
  // Selected answers per mission: missionId -> {contentIndex -> optionIndex}
  final Map<String, Map<int, int>> _answers = <String, Map<int, int>>{};

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
    // Also persist as last progress for resume
    PreferencesService.instance.saveLastProgress(
      missionId: missionId,
      contentIndex: contentIndex,
      score: score,
    );
  }
  void clearProgress(String missionId) {
    _missionIndex.remove(missionId);
    _missionScore.remove(missionId);
    _answers.remove(missionId);
    // If the cleared mission is the one saved in prefs, clear it there as well
    if (PreferencesService.instance.lastMissionId == missionId) {
      PreferencesService.instance.clearLastProgress();
    }
  }

  // Answer selection APIs
  int? getAnswerIndex(String missionId, int contentIndex) {
    final map = _answers[missionId];
    if (map == null) return null;
    return map[contentIndex];
  }

  void saveAnswerIndex(String missionId, int contentIndex, int optionIndex) {
    final map = _answers.putIfAbsent(missionId, () => <int, int>{});
    map[contentIndex] = optionIndex;
  }

  // Hydrate from preferences (last known mission progress)
  void hydrateFromPrefs() {
    final missionId = PreferencesService.instance.lastMissionId;
    if (missionId != null) {
      _missionIndex[missionId] = PreferencesService.instance.lastContentIndex;
      _missionScore[missionId] = PreferencesService.instance.lastScore;
    }
  }
}

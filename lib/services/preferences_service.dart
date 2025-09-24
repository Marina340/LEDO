import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService._internal();
  static final PreferencesService instance = PreferencesService._internal();

  static const _kOnboarded = 'pref_onboarded';
  static const _kUsername = 'pref_username';
  static const _kLastMissionId = 'pref_last_mission_id';
  static const _kLastContentIndex = 'pref_last_content_index';
  static const _kLastScore = 'pref_last_score';

  late SharedPreferences _prefs;

  static Future<void> init() async {
    instance._prefs = await SharedPreferences.getInstance();
  }

  // Onboarding
  bool get onboarded => _prefs.getBool(_kOnboarded) ?? false;
  Future<bool> setOnboarded(bool value) => _prefs.setBool(_kOnboarded, value);

  // Username
  String get username => _prefs.getString(_kUsername) ?? '';
  Future<bool> setUsername(String value) => _prefs.setString(_kUsername, value);

  // Last progress (single active mission resume)
  String? get lastMissionId => _prefs.getString(_kLastMissionId);
  int get lastContentIndex => _prefs.getInt(_kLastContentIndex) ?? 0;
  int get lastScore => _prefs.getInt(_kLastScore) ?? 0;

  Future<void> saveLastProgress({
    required String missionId,
    required int contentIndex,
    required int score,
  }) async {
    await _prefs.setString(_kLastMissionId, missionId);
    await _prefs.setInt(_kLastContentIndex, contentIndex);
    await _prefs.setInt(_kLastScore, score);
  }

  Future<void> clearLastProgress() async {
    await _prefs.remove(_kLastMissionId);
    await _prefs.remove(_kLastContentIndex);
    await _prefs.remove(_kLastScore);
  }
}

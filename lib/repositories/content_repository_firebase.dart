import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';
import 'content_repository.dart';

/// Firebase-backed content repository.
///
/// Supports two schemas for missions/{id}:
/// 1) Flat fields with `content` array (recommended)
/// 2) A legacy `details` field containing the full mission JSON as a string
///
/// User progress path (default): users/{uid}/mission_progress/{missionId}
class FirebaseContentRepository implements ContentRepository {
  final FirebaseFirestore _firestore;
  final String Function() _getUserId;
  final String usersCollection;
  final String missionProgressSubcollection;
  final String missionsCollection;

  FirebaseContentRepository({
    required FirebaseFirestore firestore,
    required String Function() getUserId,
    this.usersCollection = 'users',
    this.missionProgressSubcollection = 'progress',
    this.missionsCollection = 'missions',
  })  : _firestore = firestore,
        _getUserId = getUserId;

  // Onboarding can stay local or be fetched from Firestore if you add it later
  @override
  Future<List<DialogueLine>> fetchOnboardingDialogue() async {
    // Optionally fetch from Firestore: _firestore.collection('onboarding').doc('dialogue')
    return const [
      DialogueLine(id: 'onb1', text: 'Hey!'),
      DialogueLine(id: 'onb2', text: 'You must be new here!'),
      DialogueLine(
        id: 'onb3',
        text:
            "Well, my name is LEADO and we're about to go on a learning journey together!",
        character: 'LEADO',
      ),
      DialogueLine(
        id: 'onb5',
        text: 'Welcome on board, {username}!',
        character: 'LEADO',
      ),
      DialogueLine(
        id: 'onb6',
        text:
            'How about we answer a few questions together to know ourselves better?',
        character: 'LEADO',
      ),
      DialogueLine(
        id: 'onb7',
        text: 'If you get stuck, just ask ME! Tap the help icon anytime.',
        character: 'LEADO',
      ),
    ];
  }

  // Missions
  @override
  Future<Mission> fetchMission1() => fetchMissionById('m1');

  @override
  Future<Mission> fetchMission2() => fetchMissionById('m2');

  @override
  Future<Mission> fetchMission3() => fetchMissionById('m3');

  @override
  Future<Mission> fetchMissionById(String id) async {
    // Try exact id (e.g., 'm1')
    var ref = _firestore.collection(missionsCollection).doc(id);
    var snap = await ref.get();
    if (!snap.exists) {
      // Try alternate pattern like 'mission1' if id was 'm1'
      final altId = id.startsWith('m') && id.length > 1
          ? 'mission${id.substring(1)}'
          : id;
      ref = _firestore.collection(missionsCollection).doc(altId);
      snap = await ref.get();
      if (!snap.exists) {
        throw StateError('Mission document not found: $id (also tried $altId)');
      }
    }
    final data = snap.data() as Map<String, dynamic>;
    return _parseMissionFromData(id, data);
  }

  // Progress
  @override
  Future<void> saveMissionProgress(MissionProgress progress) async {
    final uid = _getUserId();
    final ref = _firestore
        .collection(usersCollection)
        .doc(uid)
        .collection(missionProgressSubcollection)
        .doc(progress.missionId);

    await ref.set({
      'missionId': progress.missionId,
      'score': progress.score,
      'maxScore': progress.maxScore,
      'isCompleted': progress.isCompleted,
      'completedAt': progress.completedAt,
      'answers': progress.answers,
    }, SetOptions(merge: true));

    // Optional: mirror key user-level status on the user document
    final userDoc = _firestore.collection(usersCollection).doc(uid);
    await userDoc.set({
      'currentMissionId': progress.missionId,
      'totalPoints': progress.score,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<MissionProgress?> getMissionProgress(String missionId) async {
    final uid = _getUserId();
    final ref = _firestore
        .collection(usersCollection)
        .doc(uid)
        .collection(missionProgressSubcollection)
        .doc(missionId);

    final snap = await ref.get();
    if (!snap.exists) return null;
    final data = snap.data() as Map<String, dynamic>;

    return MissionProgress(
      missionId: data['missionId'] as String? ?? missionId,
      score: (data['score'] as num?)?.toInt() ?? 0,
      maxScore: (data['maxScore'] as num?)?.toInt() ?? 0,
      answers: Map<String, dynamic>.from(data['answers'] as Map? ?? {}),
      isCompleted: (data['isCompleted'] as bool?) ?? false,
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  // ------------------- Parsers -------------------

  Mission _parseMissionFromData(String id, Map<String, dynamic> data) {
    // If the document uses a legacy `details` string field containing the JSON
    if (data['details'] is String && (data['details'] as String).isNotEmpty) {
      try {
        final details = jsonDecode(data['details'] as String) as Map<String, dynamic>;
        return _parseMissionJson(details);
      } catch (e) {
        // Fall through to try flat schema
      }
    }

    // Flat schema: fields at top-level and `content` array
    final dynamic rawContent = data['content'];
    List<dynamic> contentList = const [];
    if (rawContent is List) {
      contentList = rawContent.cast<dynamic>();
    } else if (rawContent is String) {
      try {
        final decoded = jsonDecode(rawContent);
        if (decoded is List) {
          contentList = decoded.cast<dynamic>();
        } else if (decoded is Map<String, dynamic>) {
          // Some docs store the FULL mission JSON in the `content` field
          return _parseMissionJson(decoded);
        }
      } catch (_) {
        // ignore, keep empty content
      }
    }
    return Mission(
      id: (data['id'] as String?) ?? id,
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      imageUrl: data['imageUrl'] as String?,
      pointsPerAnswer: (data['pointsPerAnswer'] as num?)?.toInt() ?? 2,
      timeLimit: (data['timeLimit'] as num?)?.toInt(),
      requiredScore: (data['requiredScore'] as num?)?.toInt(),
      nextMissionId: data['nextMissionId'] as String?,
      content: contentList.map(_parseContentBlock).toList(),
    );
  }

  Mission _parseMissionJson(Map<String, dynamic> json) {
    final dynamic rawContent = json['content'];
    List<dynamic> contentList = const [];
    if (rawContent is List) {
      contentList = rawContent.cast<dynamic>();
    } else if (rawContent is String) {
      try {
        final decoded = jsonDecode(rawContent);
        if (decoded is List) {
          contentList = decoded.cast<dynamic>();
        }
      } catch (_) {
        // ignore, keep empty content
      }
    }
    return Mission(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      pointsPerAnswer: (json['pointsPerAnswer'] as num?)?.toInt() ?? 2,
      timeLimit: (json['timeLimit'] as num?)?.toInt(),
      requiredScore: (json['requiredScore'] as num?)?.toInt(),
      nextMissionId: json['nextMissionId'] as String?,
      content: contentList.map(_parseContentBlock).toList(),
    );
  }

  dynamic _parseContentBlock(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final type = raw['type'] as String? ?? '';
      if (type == 'dialogue') {
        return DialogueLine(
          id: raw['id'] as String? ?? '',
          text: raw['text'] as String? ?? '',
          imagePath: raw['imagePath'] as String?,
          character: raw['character'] as String?,
          waitForInput: (raw['waitForInput'] as bool?) ?? false,
        );
      }
      if (type == 'question') {
        return _parseQuestion(raw);
      }
    }
    // Unknown content type, ignore by returning a DialogueLine placeholder
    return const DialogueLine(id: 'unknown', text: '');
  }

  Question _parseQuestion(Map<String, dynamic> raw) {
    final optionsRaw = (raw['options'] as List?)?.cast<dynamic>() ?? const [];
    return Question(
      id: raw['id'] as String? ?? '',
      prompt: raw['prompt'] as String? ?? '',
      promptImage: raw['promptImage'] as String?,
      type: _parseQuestionType(raw['questionType'] as String?),
      options: optionsRaw.map(_parseAnswerOption).whereType<AnswerOption>().toList(),
      hint: raw['hint'] as String?,
      maxAttempts: (raw['maxAttempts'] as num?)?.toInt() ?? 3,
      showHintAfterIncorrect: (raw['showHintAfterIncorrect'] as bool?) ?? true,
    );
  }

  AnswerOption? _parseAnswerOption(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    return AnswerOption(
      id: raw['id'] as String? ?? '',
      text: raw['text'] as String? ?? '',
      imageUrl: raw['imageUrl'] as String?,
      isCorrect: (raw['isCorrect'] as bool?) ?? true,
      group: raw['group'] as String?,
    );
  }

  QuestionType _parseQuestionType(String? s) {
    switch (s) {
      case 'mcq':
        return QuestionType.mcq;
      case 'trueFalse':
        return QuestionType.trueFalse;
      case 'matching':
        return QuestionType.matching;
      case 'fillIn':
        return QuestionType.fillIn;
      case 'dragDrop':
        return QuestionType.dragDrop;
      case 'grouping':
        return QuestionType.grouping;
      default:
        return QuestionType.mcq;
    }
  }
}

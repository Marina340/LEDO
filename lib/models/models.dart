import 'package:flutter/material.dart';

enum QuestionType {
  dialogue,
  mcq,
  trueFalse,
  matching,
  fillIn,
  dragDrop,
  grouping,
}

class DialogueLine {
  final String id;
  final String text;
  final String? imagePath;
  final String? character; // e.g., 'LEADO', 'Narrator'
  final bool waitForInput;
  
  const DialogueLine({
    required this.id, 
    required this.text,
    this.imagePath,
    this.character,
    this.waitForInput = false,
  });
}

class AnswerOption {
  final String id;
  final String text;
  final String? imageUrl;
  final bool isCorrect;
  final String? group; // used for matching/grouping categories
  
  const AnswerOption({
    required this.id, 
    required this.text, 
    this.imageUrl,
    this.isCorrect = true, // All answers are correct in Mission 1
    this.group,
  });
}

class Question {
  final String id;
  final String prompt;
  final String? promptImage;
  final QuestionType type;
  final List<AnswerOption> options;
  final String? hint;
  final int maxAttempts;
  final bool showHintAfterIncorrect;
  
  const Question({
    required this.id,
    required this.prompt,
    this.promptImage,
    required this.type,
    required this.options,
    this.hint,
    this.maxAttempts = 3,
    this.showHintAfterIncorrect = true,
  });
  
  bool get hasImages => options.any((o) => o.imageUrl != null) || promptImage != null;
}

class Mission {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final List<dynamic> content; // Can be Question or DialogueLine
  final int pointsPerAnswer;
  final int? timeLimit; // in seconds, null for no time limit
  final int? requiredScore; // Minimum score to pass
  final String? nextMissionId;
  
  const Mission({
    required this.id,
    required this.title,
    this.description = '',
    this.imageUrl,
    required this.content,
    this.pointsPerAnswer = 2,
    this.timeLimit,
    this.requiredScore,
    this.nextMissionId,
  });
  
  int get maxPossiblePoints {
    int questionCount = 0;
    for (var item in content) {
      if (item is Question) questionCount++;
    }
    return questionCount * pointsPerAnswer;
  }
  
  int get passingScore => requiredScore ?? (maxPossiblePoints * 0.7).floor();

  // Back-compat helpers for existing pages
  List<Question> get questions => content.whereType<Question>().toList();
  int get totalPoints => maxPossiblePoints;
}

class MissionProgress {
  final String missionId;
  final int score;
  final int maxScore;
  final Map<String, dynamic> answers; // questionId -> {selectedOptionId, isCorrect, attempts}
  final bool isCompleted;
  final DateTime? completedAt;
  
  const MissionProgress({
    required this.missionId,
    this.score = 0,
    required this.maxScore,
    required this.answers,
    this.isCompleted = false,
    this.completedAt,
  });
  
  MissionProgress copyWith({
    int? score,
    Map<String, dynamic>? answers,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return MissionProgress(
      missionId: missionId,
      score: score ?? this.score,
      maxScore: maxScore,
      answers: answers ?? this.answers,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

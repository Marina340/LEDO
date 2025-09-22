import '../models/models.dart';

abstract class ContentRepository {
  // Onboarding
  Future<List<DialogueLine>> fetchOnboardingDialogue();
  
  // Missions
  Future<Mission> fetchMission1();
  Future<Mission> fetchMission2();
  Future<Mission> fetchMission3();
  Future<Mission> fetchMissionById(String id);
  
  // Progress
  Future<void> saveMissionProgress(MissionProgress progress);
  Future<MissionProgress?> getMissionProgress(String missionId);
}

class MockContentRepository implements ContentRepository {
  @override
  Future<List<DialogueLine>> fetchOnboardingDialogue() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return const [
      DialogueLine(id: 'onb1', text: 'Hey!'),
      DialogueLine(id: 'onb2', text: 'You must be new here!'),
      DialogueLine(
        id: 'onb3',
        text: "Well, my name is LEADO and we're about to go on a learning journey together!",
        character: 'LEADO',
      ),
      // onb4 is handled by nickname input UI
      DialogueLine(
        id: 'onb5', 
        text: 'Welcome on board, {username}!',
        character: 'LEADO',
      ),
      DialogueLine(
        id: 'onb6',
        text: 'How about we answer a few questions together to know ourselves better?',
        character: 'LEADO',
      ),
      DialogueLine(
        id: 'onb7',
        text: 'If you get stuck, just ask ME! Tap the help icon anytime.',
        character: 'LEADO',
      ),
    ];
  }

  @override
  Future<Mission> fetchMissionById(String id) async {
    switch (id) {
      case 'm1':
        return fetchMission1();
      case 'm2':
        return fetchMission2();
      case 'm3':
        return fetchMission3();
      default:
        return fetchMission1();
    }
  }

  @override
  Future<Mission> fetchMission1() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Mission(
      id: 'm1',
      title: 'Level 1 – Mission 1',
      description: 'Discover your leadership style',
      pointsPerAnswer: 2,
      requiredScore: 20,
      nextMissionId: 'm2',
      content: const [
        // Level 1 A – Intro to LEADO
        DialogueLine(id: 'm1a1', text: 'Hey!', character: 'LEADO'),
        DialogueLine(id: 'm1a2', text: 'You must be new here!', character: 'LEADO'),
        DialogueLine(id: 'm1a3', text: "Well, my name is LEADO and we're about to go a learning journey together!", character: 'LEADO'),
        DialogueLine(id: 'm1a4', text: 'What nickname would you like me to call you by?', character: 'LEADO'),
        DialogueLine(id: 'm1a5', text: 'Excellent!', character: 'LEADO'),
        DialogueLine(id: 'm1a6', text: 'How about we answer a few questions together, shall we?', character: 'LEADO'),

        // Level 1 B – Ready and neutral questions start
        DialogueLine(id: 'm1b1', text: 'Ready when you are!', character: 'LEADO'),
        Question(
          id: 'q1',
          prompt: 'How would you react if you were put on a new team?',
          type: QuestionType.mcq,
          options: [
            AnswerOption(id: 'q1a', text: 'Nervous and a bit scared'),
            AnswerOption(id: 'q1b', text: 'Excited to meet new people!!'),
            AnswerOption(id: 'q1c', text: '“meh” (neutral)'),
            AnswerOption(id: 'q1d', text: 'Hate it! Not a fan of change.'),
          ],
        ),
        Question(
          id: 'q2',
          prompt: 'How would you react if you were told to lead a group?',
          type: QuestionType.mcq,
          options: [
            AnswerOption(id: 'q2a', text: 'Bring it on!!'),
            AnswerOption(id: 'q2b', text: 'I wouldn’t sleep for days!'),
            AnswerOption(id: 'q2c', text: 'Not my cup of tea.'),
            AnswerOption(id: 'q2d', text: 'New experiences lead to new gains'),
          ],
        ),
        Question(
          id: 'q3',
          prompt: 'What would you do if you disagreed with another team member?',
          type: QuestionType.mcq,
          options: [
            AnswerOption(id: 'q3a', text: 'Calmly explain my opinion.'),
            AnswerOption(id: 'q3b', text: 'I’d just go with it.'),
            AnswerOption(id: 'q3c', text: 'I would argue it out.'),
            AnswerOption(id: 'q3d', text: 'If logical, I’d agree to save time and effort.'),
          ],
        ),
        Question(
          id: 'q4',
          prompt: 'What would you do if you disagreed with a team leader?',
          type: QuestionType.mcq,
          options: [
            AnswerOption(id: 'q4a', text: 'Calmly explain my opinion.'),
            AnswerOption(id: 'q4b', text: 'I’d just go with it.'),
            AnswerOption(id: 'q4c', text: 'I would argue it out.'),
            AnswerOption(id: 'q4d', text: 'If logical, I’d agree to save time and effort.'),
          ],
        ),

        // Motivation
        DialogueLine(id: 'm1b2', text: "Alright! you're 2 crowns away from the Bronze trophy! keep going!", character: 'LEADO'),

        Question(
          id: 'q5',
          prompt: 'How would you deal in a conflict with a friend?',
          type: QuestionType.mcq,
          options: [
            AnswerOption(id: 'q5a', text: 'Fighting mode!!'),
            AnswerOption(id: 'q5b', text: 'Resolve the issue calmly.'),
            AnswerOption(id: 'q5c', text: 'Pretend like nothing happened'),
            AnswerOption(id: 'q5d', text: 'Apologize even if it’s not my fault.'),
          ],
        ),
        Question(
          id: 'q6',
          prompt: 'How do you like to celebrate a personal success?',
          type: QuestionType.mcq,
          options: [
            AnswerOption(id: 'q6a', text: 'Go out and party!!'),
            AnswerOption(id: 'q6b', text: 'It’s not a big deal.'),
            AnswerOption(id: 'q6c', text: 'Post on social media.'),
            AnswerOption(id: 'q6d', text: 'Buy myself a gift.'),
          ],
        ),
        Question(
          id: 'q7',
          prompt: 'What would you do if you got lost in a supermarket?',
          type: QuestionType.mcq,
          options: [
            AnswerOption(id: 'q7a', text: 'Ask for directions'),
            AnswerOption(id: 'q7b', text: 'Figure it out myself.'),
            AnswerOption(id: 'q7c', text: 'Just go home.'),
            AnswerOption(id: 'q7d', text: 'Seek help after trying.'),
          ],
        ),

        // Motivation and transition to true/false quiz
        DialogueLine(id: 'm1c1', text: 'Well, that was fun! I\'m so glad I\'m getting to know more about you!', character: 'LEADO'),
        DialogueLine(id: 'm1c2', text: 'It\'s fascinating how our behaviors and reactions are different from one another!', character: 'LEADO'),
        DialogueLine(id: 'm1c3', text: 'Now let\'s take a little quiz together, alright?', character: 'LEADO'),
        DialogueLine(id: 'm1c4', text: "Let's begin!", character: 'LEADO'),

        // Level 1 D – True/False (with correctness)
        Question(
          id: 'q8',
          prompt: 'All people act and work the same way within groups/teams.',
          type: QuestionType.trueFalse,
          options: [
            AnswerOption(id: 'q8a', text: 'True', isCorrect: false),
            AnswerOption(id: 'q8b', text: 'False', isCorrect: true),
          ],
        ),
        Question(
          id: 'q9',
          prompt: 'A good leader finds the best way to get the best out of each member.',
          type: QuestionType.trueFalse,
          options: [
            AnswerOption(id: 'q9a', text: 'True', isCorrect: true),
            AnswerOption(id: 'q9b', text: 'False', isCorrect: false),
          ],
        ),
        Question(
          id: 'q10',
          prompt: 'A good team member is more focused on the task than the people around them.',
          type: QuestionType.trueFalse,
          options: [
            AnswerOption(id: 'q10a', text: 'True', isCorrect: false),
            AnswerOption(id: 'q10b', text: 'False', isCorrect: true),
          ],
        ),
        Question(
          id: 'q11',
          prompt: 'Understanding how others think allows us all to communicate better.',
          type: QuestionType.trueFalse,
          options: [
            AnswerOption(id: 'q11a', text: 'True', isCorrect: true),
            AnswerOption(id: 'q11b', text: 'False', isCorrect: false),
          ],
        ),
        Question(
          id: 'q12',
          prompt: 'Understanding each other’s behaviors helps us deal with others and leads to a stronger team.',
          type: QuestionType.trueFalse,
          options: [
            AnswerOption(id: 'q12a', text: 'True', isCorrect: true),
            AnswerOption(id: 'q12b', text: 'False', isCorrect: false),
          ],
        ),
      ],
    );
  }

  @override
  Future<Mission> fetchMission2() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Mission(
      id: 'm2',
      title: 'Level 2 – Mission 2',
      description: 'Understand the common rules before answering any personality test',
      pointsPerAnswer: 2,
      nextMissionId: 'm3',
      content: [
        const DialogueLine(
          id: 'm2d1',
          text: 'Welcome to Mission 2! In this mission, we\'ll learn about the common rules for personality tests.',
          character: 'LEADO',
        ),
        const DialogueLine(
          id: 'm2d2',
          text: 'Remember, there are no right or wrong answers in personality tests. Just be yourself!',
          character: 'LEADO',
        ),
        
        // DO vs DON'T Questions
        Question(
          id: 'm2q1',
          prompt: 'Which of these should you DO when taking a personality test?',
          type: QuestionType.mcq,
          options: const [
            AnswerOption(id: 'm2q1a', text: 'Answer quickly with your first instinct', isCorrect: true),
            AnswerOption(id: 'm2q1b', text: 'Overthink each answer', isCorrect: false),
            AnswerOption(id: 'm2q1c', text: 'Try to guess what the test wants to hear', isCorrect: false),
            AnswerOption(id: 'm2q1d', text: 'Leave questions blank if unsure', isCorrect: false),
          ],
          hint: 'The best approach is to answer naturally without overthinking.',
        ),
        
        Question(
          id: 'm2q2',
          prompt: 'What should you AVOID when taking a personality test?',
          type: QuestionType.mcq,
          options: const [
            AnswerOption(id: 'm2q2a', text: 'Answering honestly', isCorrect: false),
            AnswerOption(id: 'm2q2b', text: 'Trying to appear perfect', isCorrect: true),
            AnswerOption(id: 'm2q2c', text: 'Reading each question carefully', isCorrect: false),
            AnswerOption(id: 'm2q2d', text: 'Taking your time', isCorrect: false),
          ],
          hint: 'Remember, no one is perfect! Be authentic in your responses.',
        ),
        
        // True/False Questions
        Question(
          id: 'm2q3',
          prompt: 'You should always answer based on how you think you should be, not how you actually are.',
          type: QuestionType.trueFalse,
          options: const [
            AnswerOption(id: 'm2q3t', text: 'TRUE', isCorrect: false),
            AnswerOption(id: 'm2q3f', text: 'FALSE', isCorrect: true),
          ],
          hint: 'Personality tests are most accurate when you respond as your authentic self.',
        ),
        
        // Scenario-based Question
        Question(
          id: 'm2q4',
          prompt: 'You come across a question that could have multiple interpretations. What should you do?',
          type: QuestionType.mcq,
          options: const [
            AnswerOption(id: 'm2q4a', text: 'Answer with your best understanding', isCorrect: true),
            AnswerOption(id: 'm2q4b', text: 'Skip the question', isCorrect: false),
            AnswerOption(id: 'm2q4c', text: 'Answer randomly', isCorrect: false),
            AnswerOption(id: 'm2q4d', text: 'Look up the answer', isCorrect: false),
          ],
        ),
        
        // Matching Question
        Question(
          id: 'm2q5',
          prompt: 'Match each statement with the correct category (DO or DON\'T)',
          type: QuestionType.matching,
          options: const [
            AnswerOption(id: 'm2q5d1', text: 'Answer honestly', group: 'DO'),
            AnswerOption(id: 'm2q5d2', text: 'Overthink your responses', group: 'DON\'T'),
            AnswerOption(id: 'm2q5d3', text: 'Trust your first instinct', group: 'DO'),
            AnswerOption(id: 'm2q5d4', text: 'Try to impress the test', group: 'DON\'T'),
          ],
          maxAttempts: 2,
        ),
        
        const DialogueLine(
          id: 'm2d_end',
          text: 'Great job! You\'ve completed the personality test guidelines. Remember these tips for accurate results!',
          character: 'LEADO',
        ),
      ],
    );
  }

  @override
  Future<Mission> fetchMission3() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Mission(
      id: 'm3',
      title: 'Level 2 – Mission 3',
      description: 'DOs and DON\'Ts of Personality Tests',
      pointsPerAnswer: 2,
      content: [
        const DialogueLine(
          id: 'm3d1',
          text: 'Welcome to the final mission! Here we\'ll learn the key DOs and DON\'Ts of taking personality tests.',
          character: 'LEADO',
        ),
        
        // DOs Section
        const DialogueLine(
          id: 'm3d2',
          text: 'Here are the key things you SHOULD DO when taking a personality test:',
          character: 'LEADO',
        ),
        
        // DOs Questions
        Question(
          id: 'm3q1',
          prompt: 'Which of these is a good practice when taking a personality test?',
          type: QuestionType.mcq,
          options: const [
            AnswerOption(id: 'm3q1a', text: 'Answer quickly with your first instinct', isCorrect: true),
            AnswerOption(id: 'm3q1b', text: 'Overthink each response', isCorrect: false),
            AnswerOption(id: 'm3q1c', text: 'Try to predict the outcome', isCorrect: false),
            AnswerOption(id: 'm3q1d', text: 'Ask others how to answer', isCorrect: false),
          ],
          hint: 'Your first instinct is usually the most honest response!',
        ),
        
        // DON'Ts Section
        const DialogueLine(
          id: 'm3d3',
          text: 'Now, let\'s look at what you should AVOID when taking a personality test:',
          character: 'LEADO',
        ),
        
        // DON'Ts Questions
        Question(
          id: 'm3q2',
          prompt: 'Which of these should you avoid when taking a personality test?',
          type: QuestionType.mcq,
          options: const [
            AnswerOption(id: 'm3q2a', text: 'Answering honestly', isCorrect: false),
            AnswerOption(id: 'm3q2b', text: 'Trying to appear perfect', isCorrect: true),
            AnswerOption(id: 'm3q2c', text: 'Taking your time', isCorrect: false),
            AnswerOption(id: 'm3q2d', text: 'Reading questions carefully', isCorrect: false),
          ],
          hint: 'Remember, no one is perfect! Authenticity is key.',
        ),
        
        // True/False Questions
        Question(
          id: 'm3q3',
          prompt: 'You should answer based on how you think you should be, not how you actually are.',
          type: QuestionType.trueFalse,
          options: const [
            AnswerOption(id: 'm3q3t', text: 'TRUE', isCorrect: false),
            AnswerOption(id: 'm3q3f', text: 'FALSE', isCorrect: true),
          ],
          hint: 'The test is designed to understand the real you, not an idealized version.',
        ),
        
        // Matching Exercise
        Question(
          id: 'm3q4',
          prompt: 'Match each statement with the correct category (DO or DON\'T)',
          type: QuestionType.matching,
          options: const [
            AnswerOption(id: 'm3q4d1', text: 'Answer honestly', group: 'DO'),
            AnswerOption(id: 'm3q4d2', text: 'Overthink your responses', group: 'DON\'T'),
            AnswerOption(id: 'm3q4d3', text: 'Trust your first instinct', group: 'DO'),
            AnswerOption(id: 'm3q4d4', text: 'Try to impress the test', group: 'DON\'T'),
            AnswerOption(id: 'm3q4d5', text: 'Be consistent in your answers', group: 'DO'),
            AnswerOption(id: 'm3q4d6', text: 'Answer how you think you should', group: 'DON\'T'),
          ],
          maxAttempts: 2,
        ),
        
        // Final Dialogue
        const DialogueLine(
          id: 'm3d_end',
          text: 'Amazing work! You\'ve completed all the personality test training. Remember these guidelines for the most accurate results!',
          character: 'LEADO',
        ),
      ],
    );
  }

  @override
  Future<void> saveMissionProgress(MissionProgress progress) async {
    // In a real app, this would save to a database
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<MissionProgress?> getMissionProgress(String missionId) async {
    // In a real app, this would fetch from a database
    await Future.delayed(const Duration(milliseconds: 100));
    return null; // No progress yet
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../repositories/content_repository.dart';
import '../ui/widgets/option_tile.dart';
import '../ui/widgets/primary_button.dart';
import '../ui/widgets/game_header.dart';
import '../state/game_state.dart';
import 'results_page.dart';

class QuizPage extends StatefulWidget {
  final String missionId;
  const QuizPage({super.key, this.missionId = 'm1'});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final ContentRepository _repo = MockContentRepository();
  Mission? _mission;
  int _contentIndex = 0; // index within Mission.content
  int _score = 0;
  int? _selectedIdx; // index within options
  bool? _isCorrect; // correctness revealed
  bool _loading = true;
  bool _optionsVisible = true;
  double _optionsOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final mission = await _repo.fetchMissionById(widget.missionId);
    setState(() {
      _mission = mission;
      // Restore saved progress
      _contentIndex = GameState.instance.getContentIndex(widget.missionId);
      _score = GameState.instance.getScore(widget.missionId);
      _loading = false;
    });
    _hydrateSelection();
    _revealOptionsWithDelay();
  }

  void _onSelect(int optionIdx) async {
    if (_selectedIdx != null) return; // prevent double taps
    HapticFeedback.selectionClick();
    final q = _mission!.content[_contentIndex] as Question;
    final selected = q.options[optionIdx];
    final correct = selected.isCorrect; // null = neutral
    setState(() {
      _selectedIdx = optionIdx;
      _isCorrect = correct;
      if (correct == true) {
        _score += _mission!.pointsPerAnswer;
        GameState.instance.addCoins(_mission!.pointsPerAnswer);
      } else if (correct == null) {
        // Neutral scoring: award points regardless of which option
        _score += _mission!.pointsPerAnswer;
        GameState.instance.addCoins(_mission!.pointsPerAnswer);
      }
    });
    // Save progress immediately after answering
    GameState.instance.saveProgress(widget.missionId, _contentIndex, _score);
    GameState.instance.saveAnswerIndex(widget.missionId, _contentIndex, optionIdx);
  }

  void _next() {
    if (_contentIndex < _mission!.content.length - 1) {
      setState(() {
        _contentIndex++;
        _selectedIdx = null;
        _isCorrect = null;
        _optionsVisible = false;
      });
      // Persist progress after moving forward
      GameState.instance.saveProgress(widget.missionId, _contentIndex, _score);
      // Restore selection if previously answered
      _hydrateSelection();
      // Motivational popup after question 4 in Mission 1
      final questions = _mission!.questions;
      final currIsQuestion = _mission!.content[_contentIndex] is Question;
      if (_mission!.id == 'm1' && currIsQuestion) {
        final pos = questions.indexOf(_mission!.content[_contentIndex] as Question);
        if (pos == 4) {
          _showCongratsPopup("You're 2 crowns away from the Bronze trophy! Keep going!");
        }
      }
      _revealOptionsWithDelay();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultsPage(
            totalPoints: _score,
            maxPoints: _mission!.totalPoints,
            missionTitle: _mission!.title,
            missionId: _mission!.id,
            nextMissionId: _mission!.nextMissionId,
            passingScore: _mission!.passingScore,
          ),
        ),
      );
      // Clear progress on finish
      GameState.instance.clearProgress(widget.missionId);
    }
  }

  void _handleBack() {
    if (_contentIndex > 0) {
      setState(() {
        _contentIndex--;
        _selectedIdx = null;
        _isCorrect = null;
        _optionsVisible = false;
      });
      // Persist progress after moving back
      GameState.instance.saveProgress(widget.missionId, _contentIndex, _score);
      _hydrateSelection();
      _revealOptionsWithDelay();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _hydrateSelection() {
    final savedIdx = GameState.instance.getAnswerIndex(widget.missionId, _contentIndex);
    if (savedIdx != null && _mission != null) {
      final item = _mission!.content[_contentIndex];
      if (item is Question) {
        final opt = item.options[savedIdx];
        setState(() {
          _selectedIdx = savedIdx;
          _isCorrect = opt.isCorrect;
        });
      }
    } else {
      setState(() {
        _selectedIdx = null;
        _isCorrect = null;
      });
    }
  }

  void _revealOptionsWithDelay() async {
    // Simulate the requested 3s before answers roll down gradually
    final isQuestion = _mission != null && _mission!.content[_contentIndex] is Question;
    final delay = isQuestion ? const Duration(seconds: 3) : const Duration(milliseconds: 250);
    await Future.delayed(delay);
    if (!mounted) return;
    setState(() {
      _optionsVisible = true;
      _optionsOpacity = 0.0;
    });
    await Future.delayed(const Duration(milliseconds: 30));
    if (!mounted) return;
    setState(() => _optionsOpacity = 1.0);
  }

  Future<void> _showCongratsPopup(String message) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFFFFC107), size: 48),
                const SizedBox(height: 12),
                const Text('Congratulations!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                PrimaryButton(label: 'Awesome', onPressed: () => Navigator.of(ctx).pop()),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _mission == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final content = _mission!.content;
    final item = content[_contentIndex];
    final questions = _mission!.questions;
    int currentQNumber = 0;
    double progress = 0;
    if (item is Question) {
      currentQNumber = questions.indexOf(item) + 1;
      progress = currentQNumber / questions.length;
    } else {
      // keep the last progress
      progress = (_selectedIdx != null ? currentQNumber : currentQNumber) / (questions.isEmpty ? 1 : questions.length);
    }

    return Scaffold(
      appBar: GameHeader(
        showBack: true,
        onBack: _handleBack,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title removed to keep header minimal and centered
            // Progress and score pill
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value: progress,
                        backgroundColor: Colors.grey.shade300,
                        color: const Color(0xFF35C69D),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${_score}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Image.asset('assets/images/coin.png', height: 16),
                      const SizedBox(width: 6),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (item is Question) Center(
              child: Text(
                'Question $currentQNumber out of ${questions.length}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 16),
            if (item is DialogueLine) ...[
              AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(item.text, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const Spacer(),
              PrimaryButton(label: 'Next', onPressed: _next),
            ] else ...[
              // Question prompt and options
              Text((item as Question).prompt, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Choose the best guess!'),
              const SizedBox(height: 16),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _optionsOpacity,
                child: !_optionsVisible
                    ? const SizedBox.shrink()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(item.options.length, (i) {
                          final option = item.options[i];
                          bool? correctState;
                          if (_selectedIdx != null) {
                            if (_selectedIdx == i) correctState = _isCorrect;
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: SizedBox(
                              width: double.infinity,
                              child: OptionTile(
                                text: option.text,
                                selected: _selectedIdx == i,
                                correct: correctState,
                                onTap: () => _onSelect(i),
                              ),
                            ),
                          );
                        }),
                      ),
              ),
              const Spacer(),
              PrimaryButton(
                label: currentQNumber < questions.length ? 'Next' : 'Finish',
                onPressed: _selectedIdx != null ? _next : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

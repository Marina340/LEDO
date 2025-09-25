import 'package:flutter/material.dart';
import '../models/models.dart';
import '../repositories/content_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/content_repository_firebase.dart';
import '../services/auth_service.dart';
import 'quiz_page.dart';
import '../ui/widgets/primary_button.dart';
import '../ui/widgets/chat_bubble.dart';
import '../services/preferences_service.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final ContentRepository _repo = FirebaseContentRepository(
    firestore: FirebaseFirestore.instance,
    // Read UID from AuthService (backed by FirebaseAuth)
    getUserId: () => AuthService().currentUser!.uid,
  );
  final TextEditingController _nameCtrl = TextEditingController();
  List<DialogueLine> _lines = const [];
  int _idx = 0;
  String _username = '';
  bool _loading = true;
  bool _showCountdown = false;
  int _countdown = 3;

  @override
  void initState() {
    super.initState();
    _load();
    // Prefill username if available
    _username = PreferencesService.instance.username;
    if (_username.isNotEmpty) {
      _nameCtrl.text = _username;
    }
  }

  Future<void> _load() async {
    final lines = await _repo.fetchOnboardingDialogue();
    setState(() {
      _lines = lines;
      _loading = false;
    });
  }

  void _next() {
    // Step 3 is the nickname input page (index 3, id onb4 in spec)
    if (_idx < _lines.length - 1) {
      setState(() => _idx++);
    } else {
      // After onboarding dialogs -> additional helper screen and countdown then quiz
      _startCountdown();
    }
  }

  void _startCountdown() async {
    setState(() {
      _showCountdown = true;
      _countdown = 3;
    });
    for (int i = 3; i >= 1; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _countdown = i - 1);
    }
    if (!mounted) return;
    // Persist onboarding completion and username before starting quiz
    await PreferencesService.instance.setOnboarded(true);
    if (_username.isNotEmpty) {
      await PreferencesService.instance.setUsername(_username);
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const QuizPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_showCountdown) {
      return Scaffold(
        body: Center(
          child: Text(
            _countdown == 0 ? 'Go!' : '$_countdown',
            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // Build dialog content
    final isNameStep = _idx == 0; // We'll ask name first for clarity

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F6F2), Color(0xFFF7FAF9)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Chat area
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      if (isNameStep) ...[
                        const ChatBubble(
                          avatarPath: 'assets/images/logo.png',
                          text: 'LEADO(1): Hey!\nLEADO(2): You must be new here!\nLEADO(3): Well, my name is LEADO and we\'re about to go on a learning journey together!\n\nLEADO(4): What nickname would you like me to call you by?',
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _nameCtrl,
                          maxLength: 10,
                          cursorColor: Color(0xFF35C69D),
                          decoration: InputDecoration(
                            hintText: 'Nickname (max 10 characters)',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFF35C69D), width: 2),
                            ),
                          ),
                          onChanged: (v) => setState(() {}),
                        ),
                      ] else ...[
                        ChatBubble(
                          avatarPath: 'assets/images/logo.png',
                          text: _currentLineText().replaceAll('{username}', _username),
                        ),
                        if (_idx == 1) ...[
                          const SizedBox(height: 8),
                          const ChatBubble(
                            avatarPath: 'assets/images/logo.png',
                            text: 'How about we answer a few questions together to know ourselves better?',
                          ),
                        ],
                        if (_idx == 2) ...[
                          const SizedBox(height: 8),
                          const ChatBubble(
                            avatarPath: 'assets/images/logo.png',
                            text: 'If you get stuck, Just ask ME!! Tap the help icon.',
                          ),
                        ],
                      ]
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: isNameStep
                      ? 'Next'
                      : _idx == 2
                          ? 'Let\'s go'
                          : 'Let\'s give it a shot',
                  onPressed: isNameStep
                      ? (_nameCtrl.text.trim().isEmpty
                          ? null
                          : () {
                              setState(() {
                                _username = _nameCtrl.text.trim();
                                _idx = 1;
                              });
                            })
                      : _next,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _currentLineText() {
    if (_idx == 1) return 'Welcome on board, {username}!';
    if (_idx == 2) return 'If you get stuck, Just ask ME!!';
    return _lines[_idx].text;
  }
}

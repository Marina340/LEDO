import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../state/game_state.dart';
import 'onboarding_page.dart';
import '../services/preferences_service.dart';
import 'quiz_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;
    final prefs = PreferencesService.instance;
    final hasResume = prefs.lastMissionId != null;
    final username = prefs.username.isNotEmpty ? prefs.username : (user?.email ?? 'Friend');

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => authService.signOut(),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F6F2), Color(0xFFF7FAF9)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFF35C69D),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        "Welcome, $username",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.emoji_events_rounded, color: Color(0xFFFFC107)),
                          SizedBox(width: 8),
                          Text('Your Journey', style: TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (hasResume) ...[
                        _PrimaryActionButton(
                          icon: Icons.play_arrow_rounded,
                          label: 'Resume where I left off',
                          onPressed: () {
                            final missionId = prefs.lastMissionId ?? 'm1';
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => QuizPage(missionId: missionId)),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _SecondaryTextButton(
                          icon: Icons.refresh_rounded,
                          label: 'Start over',
                          onPressed: () {
                            // Reset local in-memory state and preferences
                            GameState.instance.reset();
                            PreferencesService.instance.clearLastProgress();

                            // Reset user's totalPoints in Firestore
                            final uid = authService.currentUser?.uid;
                            if (uid != null) {
                              FirebaseFirestore.instance.collection('users').doc(uid).set({
                                'totalPoints': 0,
                                'updatedAt': FieldValue.serverTimestamp(),
                              }, SetOptions(merge: true));
                            }

                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const OnboardingPage()),
                            );
                          },
                        ),
                      ] else ...[
                        _PrimaryActionButton(
                          icon: Icons.rocket_launch_outlined,
                          label: 'Start',
                          onPressed: () {
                            if (prefs.onboarded) {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const QuizPage()),
                              );
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const OnboardingPage()),
                              );
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const _PrimaryActionButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF35C69D),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class _SecondaryTextButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const _SecondaryTextButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(icon, color: Colors.black54),
      label: Text(label, style: const TextStyle(color: Colors.black87)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        foregroundColor: Colors.black87,
      ),
      onPressed: onPressed,
    );
  }
}

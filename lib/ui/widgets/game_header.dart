import 'package:flutter/material.dart';
import '../../state/game_state.dart';

class GameHeader extends StatelessWidget implements PreferredSizeWidget {
  final int coins;
  final bool? showBack; // if null, auto-detect via Navigator.canPop
  final VoidCallback? onBack;
  final bool? showAvatar;
  const GameHeader({super.key, this.coins = 0, this.showBack, this.onBack, this.showAvatar});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final shouldShowBack = showBack ?? canPop;

    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (shouldShowBack)
            Positioned(
              left: 0,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onBack ?? () {
                    if (Navigator.of(context).canPop()) Navigator.of(context).maybePop();
                  },
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  ),
                ),
              ),
            ),
          // Centered Logo
          Image.asset('assets/images/logo.png', height: 32),

          // Right-aligned user avatar
          if (showAvatar ?? true) Positioned(
            right: 0,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF35C69D),
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

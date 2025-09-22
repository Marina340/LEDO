import 'package:flutter/material.dart';
import '../../state/game_state.dart';

class GameHeader extends StatelessWidget implements PreferredSizeWidget {
  final int coins;
  const GameHeader({super.key, this.coins = 0});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Centered Logo
          Image.asset('assets/images/logo.png', height: 32),

          // Right-aligned coins pill
          ValueListenableBuilder<int>(
            valueListenable: GameState.instance.coins,
            builder: (context, value, _) {
              return Positioned(
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/coin.jpg', height: 16),
                      const SizedBox(width: 6),
                      Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

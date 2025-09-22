import 'package:flutter/material.dart';

class OptionTile extends StatelessWidget {
  final String text;
  final bool selected;
  final bool? correct; // null = not revealed yet, true green, false red
  final VoidCallback? onTap;

  const OptionTile({
    super.key,
    required this.text,
    this.selected = false,
    this.correct,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color border = Colors.grey.shade400;
    Color bg = Colors.white;
    Color fg = Colors.black87;

    if (correct == true) {
      bg = const Color(0xFF35C69D); // green from design vibe
      fg = Colors.white;
      border = bg;
    } else if (correct == false) {
      bg = const Color(0xFFE57373); // red
      fg = Colors.white;
      border = bg;
    } else if (selected) {
      // Neutral selection (no correctness revealed yet)
      bg = const Color(0xFFFFF3E0); // light orange
      border = const Color(0xFFFF9800); // orange
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 1.2),
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: 16, color: fg, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  const PrimaryButton({super.key, required this.label, this.onPressed, this.filled = true});

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF35C69D); // brand green
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: filled ? color : Colors.white,
          foregroundColor: filled ? Colors.white : color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: color, width: 2)),
          elevation: filled ? 1 : 0,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.white,
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

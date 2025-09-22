import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String avatarPath;
  final String text;
  final bool isUser;

  const ChatBubble({
    super.key,
    required this.avatarPath,
    required this.text,
    this.isUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isUser ? const Color(0xFF35C69D) : Colors.white;
    final textColor = isUser ? Colors.white : Colors.black87;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser) ...[
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 18,
            child: Image.asset(avatarPath, height: 22),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isUser ? const Color(0xFF35C69D) : Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(text, style: TextStyle(color: textColor, fontSize: 16, height: 1.4)),
          ),
        ),
        if (isUser) ...[
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 18,
            child: Text('U', style: TextStyle(color: Colors.grey.shade800)),
          ),
        ],
      ],
    );
  }
}

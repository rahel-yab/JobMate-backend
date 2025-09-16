import 'package:flutter/material.dart';

class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;
  final VoidCallback onToggleLanguage;
  final String? title;
  final String? subtitle;

  const ChatHeader({
    super.key,
    required this.onBack,
    required this.onToggleLanguage,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFEAF6F4),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: onBack,
      ),
      title: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF005148),
            child: Text("JM", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title ?? "JobMate",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                subtitle ?? "Your AI Career Buddy",
                style: const TextStyle(fontSize: 12, color: Color(0xFF1E1E1E)),
              ),
            ],
          ),
        ],
      ),
      // Removed the language toggle button that was appearing as a banner
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

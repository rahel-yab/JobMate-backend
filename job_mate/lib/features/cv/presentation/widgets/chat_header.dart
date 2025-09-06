import 'package:flutter/material.dart';

class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;
  final VoidCallback onToggleLanguage;
  final VoidCallback onShowHistory; // ✅ Added

  const ChatHeader({
    super.key,
    required this.onBack,
    required this.onToggleLanguage,
    required this.onShowHistory, // ✅ Required
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
            children: const [
              Text(
                "JobMate",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                "Your AI Career Buddy",
                style: TextStyle(fontSize: 12, color: Color(0xFF1E1E1E)),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history, color: Colors.black),
          onPressed: onShowHistory, // ✅ History button
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: TextButton.icon(
            onPressed: onToggleLanguage,
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.language, color: Colors.black, size: 20),
            label: const Text(
              "አማ",
              style: TextStyle(color: Colors.black, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

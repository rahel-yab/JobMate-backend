import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF144A3F),
            child: Text('JM', style: TextStyle(color: Colors.white, fontSize: 10)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6F4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AnimatedDot(animation: _animation, delay: 0),
                const SizedBox(width: 4),
                _AnimatedDot(animation: _animation, delay: 200),
                const SizedBox(width: 4),
                _AnimatedDot(animation: _animation, delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedDot extends StatelessWidget {
  final Animation<double> animation;
  final int delay;

  const _AnimatedDot({required this.animation, required this.delay});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: Interval(
            delay / 1500,
            (delay + 500) / 1500,
            curve: Curves.easeInOut,
          ),
        ),
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFF005148),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
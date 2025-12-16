import 'dart:async';

import 'package:flutter/material.dart';
import 'package:github_genui/theme/github_theme.dart';

/// Animated typing dots indicator.
class TypingDots extends StatefulWidget {
  /// Creates the typing dots widget.
  const TypingDots({super.key});

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    unawaited(_controller.repeat());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) => Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, _buildDot),
    ),
  );

  Widget _buildDot(int index) {
    final delay = index * 0.2;
    final value = (_controller.value + delay) % 1.0;
    final opacity = 0.3 + (0.7 * _bounce(value));
    final scale = 0.8 + (0.4 * _bounce(value));

    return Container(
      margin: EdgeInsets.only(left: index > 0 ? 4 : 0),
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: GitHubColors.fgMuted.withValues(alpha: opacity),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  double _bounce(double t) {
    if (t < 0.5) return 4 * t * t * t;
    return 1 - ((-2 * t + 2) * (-2 * t + 2) * (-2 * t + 2)) / 2;
  }
}

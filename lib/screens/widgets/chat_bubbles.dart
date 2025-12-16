import 'package:flutter/material.dart';
import 'package:github_genui/screens/widgets/typing_dots.dart';
import 'package:github_genui/theme/github_theme.dart';

/// Message type enum.
enum ChatBubbleType {
  /// User message.
  user,

  /// Assistant message.
  assistant,

  /// GenUI surface message.
  surface,

  /// Error message.
  error,
}

/// Chat bubble message data.
typedef ChatBubbleMessage = ({
  ChatBubbleType type,
  String? text,
  String? surfaceId,
});

/// Animated message wrapper with slide + fade animation.
class AnimatedMessageBubble extends StatelessWidget {
  /// Creates an animated message bubble.
  const AnimatedMessageBubble({required this.child, super.key});

  /// The child widget to animate.
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOutCubic,
    builder: (context, value, child) => Transform.translate(
      offset: Offset(0, 20 * (1 - value)),
      child: Opacity(opacity: value, child: child),
    ),
    child: child,
  );
}

/// User message bubble (right-aligned, blue gradient).
class UserBubble extends StatelessWidget {
  /// Creates a user bubble.
  const UserBubble({required this.text, super.key});

  /// Message text.
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 48),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [GitHubColors.accentEmphasis, Color(0xFF1a4f8c)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: GitHubColors.accentEmphasis.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: GitHubColors.accentEmphasis, width: 2),
          ),
          child: const CircleAvatar(
            radius: 16,
            backgroundColor: GitHubColors.canvasSubtle,
            child: Icon(Icons.person, size: 18, color: GitHubColors.accentFg),
          ),
        ),
      ],
    ),
  );
}

/// Assistant message bubble (left-aligned, with gradient avatar).
class AssistantBubble extends StatelessWidget {
  /// Creates an assistant bubble.
  const AssistantBubble({required this.text, super.key});

  /// Message text.
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AssistantAvatar(),
        const SizedBox(width: 12),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GitHubColors.canvasSubtle,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(color: GitHubColors.borderDefault),
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: GitHubColors.fgDefault,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    ),
  );
}

/// Surface message bubble (for GenUI surfaces).
class SurfaceBubble extends StatelessWidget {
  /// Creates a surface bubble.
  const SurfaceBubble({required this.surface, super.key});

  /// The surface widget to display.
  final Widget surface;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AssistantAvatar(),
        const SizedBox(width: 12),
        Expanded(child: surface),
        const SizedBox(width: 16),
      ],
    ),
  );
}

/// Error message bubble.
class ErrorBubble extends StatelessWidget {
  /// Creates an error bubble.
  const ErrorBubble({required this.text, super.key});

  /// Error message text.
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GitHubColors.dangerEmphasis.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GitHubColors.dangerEmphasis),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: GitHubColors.dangerFg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: GitHubColors.dangerFg),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Loading indicator bubble with typing dots.
class LoadingBubble extends StatelessWidget {
  /// Creates a loading bubble.
  const LoadingBubble({super.key});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
    builder: (context, value, child) => Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 10 * (1 - value)),
        child: child,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Row(
        children: [
          _buildPulsingAvatar(),
          const SizedBox(width: 12),
          _buildTypingBubble(),
        ],
      ),
    ),
  );

  Widget _buildPulsingAvatar() => Container(
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        colors: [GitHubColors.successEmphasis, GitHubColors.accentEmphasis],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: GitHubColors.successEmphasis.withValues(alpha: 0.5),
          blurRadius: 10,
        ),
      ],
    ),
    child: const CircleAvatar(
      radius: 16,
      backgroundColor: GitHubColors.canvasSubtle,
      child: SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: GitHubColors.successFg,
        ),
      ),
    ),
  );

  Widget _buildTypingBubble() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: GitHubColors.canvasSubtle,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      border: Border.all(color: GitHubColors.borderDefault),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TypingDots(),
        SizedBox(width: 8),
        Text(
          'Thinking...',
          style: TextStyle(
            color: GitHubColors.fgMuted,
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    ),
  );
}

/// Assistant avatar with gradient border.
class AssistantAvatar extends StatelessWidget {
  /// Creates an assistant avatar.
  const AssistantAvatar({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        colors: [GitHubColors.successEmphasis, GitHubColors.accentEmphasis],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: GitHubColors.successEmphasis.withValues(alpha: 0.4),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: const CircleAvatar(
      radius: 16,
      backgroundColor: GitHubColors.canvasSubtle,
      child: Icon(Icons.auto_awesome, size: 18, color: GitHubColors.successFg),
    ),
  );
}

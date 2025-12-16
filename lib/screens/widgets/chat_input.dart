import 'package:flutter/material.dart';
import 'package:github_genui/theme/github_theme.dart';

/// Chat input area with text field and send button.
class ChatInput extends StatelessWidget {
  /// Creates the chat input widget.
  const ChatInput({
    required this.controller,
    required this.onSend,
    required this.enabled,
    super.key,
  });

  /// Text editing controller.
  final TextEditingController controller;

  /// Callback when send button is pressed.
  final VoidCallback onSend;

  /// Whether the input is enabled.
  final bool enabled;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: const BoxDecoration(
      color: GitHubColors.canvasSubtle,
      border: Border(top: BorderSide(color: GitHubColors.borderDefault)),
    ),
    child: SafeArea(
      top: false,
      child: Row(
        children: [
          Expanded(child: _buildTextField()),
          const SizedBox(width: 8),
          _SendButton(enabled: enabled, onTap: onSend),
        ],
      ),
    ),
  );

  Widget _buildTextField() => Container(
    constraints: const BoxConstraints(maxHeight: 100),
    decoration: BoxDecoration(
      color: GitHubColors.canvasDefault,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: GitHubColors.borderDefault),
    ),
    child: TextField(
      controller: controller,
      decoration: const InputDecoration(
        hintText: 'Ask about GitHub...',
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        hintStyle: TextStyle(color: GitHubColors.fgSubtle, fontSize: 14),
        isDense: true,
      ),
      style: const TextStyle(fontSize: 14),
      onSubmitted: (_) => onSend(),
      enabled: enabled,
      maxLines: null,
      textInputAction: TextInputAction.send,
    ),
  );
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      gradient: LinearGradient(
        colors: enabled
            ? [GitHubColors.accentEmphasis, const Color(0xFF1a4f8c)]
            : [GitHubColors.borderDefault, GitHubColors.borderMuted],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shape: BoxShape.circle,
      boxShadow: enabled
          ? [
              BoxShadow(
                color: GitHubColors.accentEmphasis.withValues(alpha: 0.5),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: enabled ? 1 : 0.85),
      duration: const Duration(milliseconds: 200),
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: DecoratedBox(
          decoration: decoration,
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: enabled ? onTap : null,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

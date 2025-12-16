import 'package:flutter/material.dart';
import 'package:github_genui/screens/chat_screen.dart';
import 'package:github_genui/theme/github_theme.dart';

void main() => runApp(const GitHubGenUIApp());

/// Main application widget for GitHubGenUI.
class GitHubGenUIApp extends StatelessWidget {
  /// Creates the GitHubGenUI app.
  const GitHubGenUIApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'GitHub',
    debugShowCheckedModeBanner: false,
    theme: githubDarkTheme(),
    home: const ChatScreen(),
  );
}

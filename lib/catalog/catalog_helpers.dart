import 'package:flutter/material.dart';
import 'package:github_genui/theme/github_theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// Type-safe JSON extraction helpers for catalog widgets.

/// Extracts a String value from a map.
String str(Map<String, dynamic> m, String k) => switch (m[k]) {
  final String s => s,
  _ => '',
};

/// Extracts an optional String value from a map.
String? strOpt(Map<String, dynamic> m, String k) => switch (m[k]) {
  final String s => s,
  _ => null,
};

/// Extracts an int value from a map.
int integer(Map<String, dynamic> m, String k) => switch (m[k]) {
  final int i => i,
  _ => 0,
};

/// Extracts an optional int value from a map.
int? intOpt(Map<String, dynamic> m, String k) => switch (m[k]) {
  final int i => i,
  _ => null,
};

/// Extracts a bool value from a map.
bool boolean(Map<String, dynamic> m, String k) => switch (m[k]) {
  final bool b => b,
  _ => false,
};

/// Extracts a nested map from a map.
Map<String, dynamic> mapValue(Map<String, dynamic> m, String k) =>
    switch (m[k]) {
      final Map<String, dynamic> map => map,
      _ => {},
    };

/// Extracts a list from a map.
List<dynamic> listValue(Map<String, dynamic> m, String k) => switch (m[k]) {
  final List<dynamic> list => list,
  _ => [],
};

/// Extracts topics list as strings.
List<String> topicsList(Map<String, dynamic> m, String k) => [
  for (final t in listValue(m, k))
    if (t case final String s) s,
];

/// Formats a count for display (e.g., 1.2k, 3.5m).
String formatCount(int count) {
  if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(1)}m';
  } else if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}k';
  }
  return count.toString();
}

/// Gets color for a programming language.
Color getLanguageColor(String language) {
  const colors = {
    'Dart': Color(0xFF00B4AB),
    'JavaScript': Color(0xFFF1E05A),
    'TypeScript': Color(0xFF3178C6),
    'Python': Color(0xFF3572A5),
    'Java': Color(0xFFB07219),
    'Kotlin': Color(0xFFA97BFF),
    'Swift': Color(0xFFFFAC45),
    'Go': Color(0xFF00ADD8),
    'Rust': Color(0xFFDEA584),
    'C++': Color(0xFFF34B7D),
    'C': Color(0xFF555555),
    'C#': Color(0xFF178600),
    'Ruby': Color(0xFF701516),
    'PHP': Color(0xFF4F5D95),
    'HTML': Color(0xFFE34C26),
    'CSS': Color(0xFF563D7C),
    'Shell': Color(0xFF89E051),
    'Vue': Color(0xFF41B883),
  };
  return colors[language] ?? GitHubColors.fgMuted;
}

/// Parses a hex color string to Color.
Color parseColor(String? hex) {
  if (hex == null || hex.isEmpty) return GitHubColors.fgMuted;
  final cleaned = hex.replaceFirst('#', '');
  if (cleaned.length == 6) {
    return Color(int.parse('FF$cleaned', radix: 16));
  }
  return GitHubColors.fgMuted;
}

/// Gets an IconData from a name.
IconData getIcon(String name) {
  const icons = {
    'star': Icons.star_outline,
    'fork': Icons.call_split,
    'eye': Icons.visibility_outlined,
    'issue': Icons.circle_outlined,
    'pr': Icons.call_merge,
    'commit': Icons.commit,
    'repo': Icons.book_outlined,
    'user': Icons.person_outline,
    'code': Icons.code,
    'branch': Icons.account_tree_outlined,
  };
  return icons[name] ?? Icons.help_outline;
}

/// Callback for URL launch.
VoidCallback? onTapUrl(String? url) =>
    url != null ? () => launchUrl(Uri.parse(url)) : null;

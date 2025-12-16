/// Catalog helper functions for formatting and styling.
library;

import 'package:flutter/material.dart';
import 'package:github_genui/theme/github_theme.dart';

/// Format large numbers with k/m suffixes.
String formatCount(int count) {
  if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(1)}m';
  } else if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}k';
  }
  return count.toString();
}

/// Get the color for a programming language.
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

/// Parse a hex color string.
Color parseColor(String? hex) {
  if (hex == null || hex.isEmpty) return GitHubColors.fgMuted;
  final cleaned = hex.replaceFirst('#', '');
  if (cleaned.length == 6) {
    return Color(int.parse('FF$cleaned', radix: 16));
  }
  return GitHubColors.fgMuted;
}

/// Get an icon by name.
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

/// Type-safe extraction of String from dynamic map.
String str(Map<String, dynamic> m, String k) => switch (m[k]) {
  final String s => s,
  _ => '',
};

/// Type-safe extraction of optional String from dynamic map.
String? strOpt(Map<String, dynamic> m, String k) => switch (m[k]) {
  final String s => s,
  _ => null,
};

/// Type-safe extraction of int from dynamic map.
int intVal(Map<String, dynamic> m, String k) => switch (m[k]) {
  final int i => i,
  _ => 0,
};

/// Type-safe extraction of bool from dynamic map.
bool boolVal(Map<String, dynamic> m, String k) => switch (m[k]) {
  final bool b => b,
  _ => false,
};

/// Type-safe extraction of List from dynamic map.
List<dynamic> listVal(Map<String, dynamic> m, String k) => switch (m[k]) {
  final List<dynamic> l => l,
  _ => <dynamic>[],
};

/// Type-safe extraction of Map from dynamic map.
Map<String, dynamic> mapVal(Map<String, dynamic> m, String k) => switch (m[k]) {
  final Map<String, dynamic> map => map,
  _ => <String, dynamic>{},
};

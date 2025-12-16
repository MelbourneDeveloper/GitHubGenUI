import 'package:flutter/material.dart';

/// GitHub's dark mode color palette.
class GitHubColors {
  /// Default canvas background.
  static const Color canvasDefault = Color(0xFF0d1117);

  /// Subtle canvas background.
  static const Color canvasSubtle = Color(0xFF161b22);

  /// Inset canvas background.
  static const Color canvasInset = Color(0xFF010409);

  /// Default foreground text.
  static const Color fgDefault = Color(0xFFc9d1d9);

  /// Muted foreground text.
  static const Color fgMuted = Color(0xFF8b949e);

  /// Subtle foreground text.
  static const Color fgSubtle = Color(0xFF6e7681);

  /// Default border color.
  static const Color borderDefault = Color(0xFF30363d);

  /// Muted border color.
  static const Color borderMuted = Color(0xFF21262d);

  /// Accent foreground (links).
  static const Color accentFg = Color(0xFF58a6ff);

  /// Accent emphasis (buttons).
  static const Color accentEmphasis = Color(0xFF1f6feb);

  /// Success foreground.
  static const Color successFg = Color(0xFF3fb950);

  /// Success emphasis.
  static const Color successEmphasis = Color(0xFF238636);

  /// Danger foreground.
  static const Color dangerFg = Color(0xFFf85149);

  /// Danger emphasis.
  static const Color dangerEmphasis = Color(0xFFda3633);

  /// Warning foreground.
  static const Color warningFg = Color(0xFFd29922);

  /// Attention foreground.
  static const Color attentionFg = Color(0xFFe3b341);

  /// Done/Merged foreground.
  static const Color doneFg = Color(0xFFa371f7);

  /// Sponsors foreground.
  static const Color sponsorsFg = Color(0xFFdb61a2);

  /// Assistant bubble gradient start.
  static const Color assistantBubbleStart = Color(0xFF1c2128);

  /// Assistant bubble gradient end.
  static const Color assistantBubbleEnd = Color(0xFF161b22);

  /// User bubble gradient start.
  static const Color userBubbleStart = Color(0xFF1f6feb);

  /// User bubble gradient end.
  static const Color userBubbleEnd = Color(0xFF1a4f8c);
}

/// Standard border radius values.
class GitHubRadius {
  /// Small radius for chips/badges.
  static const double small = 6;

  /// Medium radius for cards.
  static const double medium = 12;

  /// Large radius for bubbles.
  static const double large = 18;

  /// Full radius for circles.
  static const double full = 999;
}

/// Decoration for user chat bubbles.
BoxDecoration userBubbleDecoration() => BoxDecoration(
  gradient: const LinearGradient(
    colors: [GitHubColors.userBubbleStart, GitHubColors.userBubbleEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  borderRadius: const BorderRadius.only(
    topLeft: Radius.circular(GitHubRadius.large),
    topRight: Radius.circular(GitHubRadius.large),
    bottomLeft: Radius.circular(GitHubRadius.large),
    bottomRight: Radius.circular(4),
  ),
  boxShadow: [
    BoxShadow(
      color: GitHubColors.accentEmphasis.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ],
);

/// Decoration for assistant chat bubbles.
BoxDecoration assistantBubbleDecoration() => BoxDecoration(
  gradient: const LinearGradient(
    colors: [
      GitHubColors.assistantBubbleStart,
      GitHubColors.assistantBubbleEnd,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  borderRadius: const BorderRadius.only(
    topLeft: Radius.circular(4),
    topRight: Radius.circular(GitHubRadius.large),
    bottomLeft: Radius.circular(GitHubRadius.large),
    bottomRight: Radius.circular(GitHubRadius.large),
  ),
  border: Border.all(color: GitHubColors.borderDefault.withValues(alpha: 0.5)),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ],
);

/// GitHub dark theme for Flutter.
ThemeData githubDarkTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: GitHubColors.canvasDefault,
  primaryColor: GitHubColors.accentEmphasis,
  colorScheme: const ColorScheme.dark(
    surface: GitHubColors.canvasDefault,
    primary: GitHubColors.accentEmphasis,
    secondary: GitHubColors.successEmphasis,
    error: GitHubColors.dangerEmphasis,
    onSurface: GitHubColors.fgDefault,
    onPrimary: Colors.white,
    outline: GitHubColors.borderDefault,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: GitHubColors.canvasSubtle,
    foregroundColor: GitHubColors.fgDefault,
    elevation: 0,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(
      color: GitHubColors.fgDefault,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: CardThemeData(
    color: GitHubColors.canvasSubtle,
    elevation: 2,
    shadowColor: Colors.black.withValues(alpha: 0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(GitHubRadius.medium),
      side: const BorderSide(color: GitHubColors.borderDefault),
    ),
    margin: const EdgeInsets.symmetric(vertical: 4),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: GitHubColors.canvasSubtle,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(GitHubRadius.medium),
      borderSide: const BorderSide(color: GitHubColors.borderDefault),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(GitHubRadius.medium),
      borderSide: const BorderSide(color: GitHubColors.borderDefault),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(GitHubRadius.medium),
      borderSide: const BorderSide(
        color: GitHubColors.accentEmphasis,
        width: 2,
      ),
    ),
    hintStyle: const TextStyle(color: GitHubColors.fgMuted),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: GitHubColors.successEmphasis,
      foregroundColor: Colors.white,
      elevation: 2,
      shadowColor: GitHubColors.successEmphasis.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GitHubRadius.medium),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: GitHubColors.fgDefault,
      side: const BorderSide(color: GitHubColors.borderDefault),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GitHubRadius.medium),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: GitHubColors.accentFg),
  ),
  iconTheme: const IconThemeData(color: GitHubColors.fgMuted, size: 20),
  dividerTheme: const DividerThemeData(
    color: GitHubColors.borderMuted,
    thickness: 1,
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: GitHubColors.fgMuted,
    textColor: GitHubColors.fgDefault,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: GitHubColors.canvasSubtle,
    labelStyle: const TextStyle(color: GitHubColors.fgDefault, fontSize: 12),
    side: const BorderSide(color: GitHubColors.borderDefault),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  tabBarTheme: const TabBarThemeData(
    labelColor: GitHubColors.fgDefault,
    unselectedLabelColor: GitHubColors.fgMuted,
    indicatorColor: GitHubColors.dangerFg,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: GitHubColors.canvasSubtle,
    selectedItemColor: GitHubColors.fgDefault,
    unselectedItemColor: GitHubColors.fgMuted,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      color: GitHubColors.fgDefault,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: TextStyle(
      color: GitHubColors.fgDefault,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: TextStyle(
      color: GitHubColors.fgDefault,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      color: GitHubColors.fgDefault,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      color: GitHubColors.fgDefault,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      color: GitHubColors.fgDefault,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(color: GitHubColors.fgDefault),
    bodyMedium: TextStyle(color: GitHubColors.fgDefault),
    bodySmall: TextStyle(color: GitHubColors.fgMuted),
    labelLarge: TextStyle(color: GitHubColors.fgDefault),
    labelMedium: TextStyle(color: GitHubColors.fgMuted),
    labelSmall: TextStyle(color: GitHubColors.fgSubtle),
  ),
);

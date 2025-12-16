import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_genui/catalog/catalog_helpers.dart';
import 'package:github_genui/theme/github_theme.dart';

void main() {
  group('str', () {
    test('extracts string value', () {
      final map = <String, dynamic>{'name': 'test', 'count': 42};
      expect(str(map, 'name'), 'test');
    });

    test('returns empty string for missing key', () {
      final map = <String, dynamic>{'name': 'test'};
      expect(str(map, 'missing'), '');
    });

    test('returns empty string for non-string value', () {
      final map = <String, dynamic>{'count': 42};
      expect(str(map, 'count'), '');
    });
  });

  group('strOpt', () {
    test('extracts string value', () {
      final map = <String, dynamic>{'name': 'test'};
      expect(strOpt(map, 'name'), 'test');
    });

    test('returns null for missing key', () {
      final map = <String, dynamic>{'name': 'test'};
      expect(strOpt(map, 'missing'), isNull);
    });

    test('returns null for non-string value', () {
      final map = <String, dynamic>{'count': 42};
      expect(strOpt(map, 'count'), isNull);
    });
  });

  group('integer', () {
    test('extracts int value', () {
      final map = <String, dynamic>{'count': 42};
      expect(integer(map, 'count'), 42);
    });

    test('returns 0 for missing key', () {
      final map = <String, dynamic>{'count': 42};
      expect(integer(map, 'missing'), 0);
    });

    test('returns 0 for non-int value', () {
      final map = <String, dynamic>{'name': 'test'};
      expect(integer(map, 'name'), 0);
    });
  });

  group('intOpt', () {
    test('extracts int value', () {
      final map = <String, dynamic>{'count': 42};
      expect(intOpt(map, 'count'), 42);
    });

    test('returns null for missing key', () {
      final map = <String, dynamic>{'count': 42};
      expect(intOpt(map, 'missing'), isNull);
    });

    test('returns null for non-int value', () {
      final map = <String, dynamic>{'name': 'test'};
      expect(intOpt(map, 'name'), isNull);
    });
  });

  group('boolean', () {
    test('extracts true value', () {
      final map = <String, dynamic>{'active': true};
      expect(boolean(map, 'active'), true);
    });

    test('extracts false value', () {
      final map = <String, dynamic>{'active': false};
      expect(boolean(map, 'active'), false);
    });

    test('returns false for missing key', () {
      final map = <String, dynamic>{'name': 'test'};
      expect(boolean(map, 'missing'), false);
    });

    test('returns false for non-bool value', () {
      final map = <String, dynamic>{'count': 42};
      expect(boolean(map, 'count'), false);
    });
  });

  group('mapValue', () {
    test('extracts nested map', () {
      final nested = <String, dynamic>{'id': 1, 'name': 'nested'};
      final map = <String, dynamic>{'data': nested};
      expect(mapValue(map, 'data'), nested);
    });

    test('returns empty map for missing key', () {
      final map = <String, dynamic>{'name': 'test'};
      expect(mapValue(map, 'missing'), isEmpty);
    });

    test('returns empty map for non-map value', () {
      final map = <String, dynamic>{'count': 42};
      expect(mapValue(map, 'count'), isEmpty);
    });
  });

  group('listValue', () {
    test('extracts list', () {
      final list = [1, 2, 3];
      final map = <String, dynamic>{'items': list};
      expect(listValue(map, 'items'), list);
    });

    test('returns empty list for missing key', () {
      final map = <String, dynamic>{'name': 'test'};
      expect(listValue(map, 'missing'), isEmpty);
    });

    test('returns empty list for non-list value', () {
      final map = <String, dynamic>{'count': 42};
      expect(listValue(map, 'count'), isEmpty);
    });
  });

  group('topicsList', () {
    test('extracts string list', () {
      final map = <String, dynamic>{
        'topics': ['dart', 'flutter', 'mobile'],
      };
      expect(topicsList(map, 'topics'), ['dart', 'flutter', 'mobile']);
    });

    test('filters non-string values', () {
      final map = <String, dynamic>{
        'topics': ['dart', 42, 'flutter', null, 'mobile'],
      };
      expect(topicsList(map, 'topics'), ['dart', 'flutter', 'mobile']);
    });

    test('returns empty list for missing key', () {
      final map = <String, dynamic>{'name': 'test'};
      expect(topicsList(map, 'missing'), isEmpty);
    });
  });

  group('formatCount', () {
    test('formats millions', () {
      expect(formatCount(1000000), '1.0m');
      expect(formatCount(1500000), '1.5m');
      expect(formatCount(12345678), '12.3m');
    });

    test('formats thousands', () {
      expect(formatCount(1000), '1.0k');
      expect(formatCount(1500), '1.5k');
      expect(formatCount(12345), '12.3k');
      expect(formatCount(999999), '1000.0k');
    });

    test('preserves small numbers', () {
      expect(formatCount(0), '0');
      expect(formatCount(1), '1');
      expect(formatCount(999), '999');
    });
  });

  group('getLanguageColor', () {
    test('returns Dart color', () {
      expect(getLanguageColor('Dart'), const Color(0xFF00B4AB));
    });

    test('returns JavaScript color', () {
      expect(getLanguageColor('JavaScript'), const Color(0xFFF1E05A));
    });

    test('returns TypeScript color', () {
      expect(getLanguageColor('TypeScript'), const Color(0xFF3178C6));
    });

    test('returns Python color', () {
      expect(getLanguageColor('Python'), const Color(0xFF3572A5));
    });

    test('returns fallback for unknown language', () {
      expect(getLanguageColor('UnknownLang'), GitHubColors.fgMuted);
    });
  });

  group('parseColor', () {
    test('parses hex color with hash', () {
      expect(parseColor('#FF5733'), const Color(0xFFFF5733));
    });

    test('parses hex color without hash', () {
      expect(parseColor('FF5733'), const Color(0xFFFF5733));
    });

    test('returns fallback for null', () {
      expect(parseColor(null), GitHubColors.fgMuted);
    });

    test('returns fallback for empty string', () {
      expect(parseColor(''), GitHubColors.fgMuted);
    });

    test('returns fallback for invalid length', () {
      expect(parseColor('FFF'), GitHubColors.fgMuted);
      expect(parseColor('FF5733FF'), GitHubColors.fgMuted);
    });
  });

  group('getIcon', () {
    test('returns star icon', () {
      expect(getIcon('star'), Icons.star_outline);
    });

    test('returns fork icon', () {
      expect(getIcon('fork'), Icons.call_split);
    });

    test('returns eye icon', () {
      expect(getIcon('eye'), Icons.visibility_outlined);
    });

    test('returns issue icon', () {
      expect(getIcon('issue'), Icons.circle_outlined);
    });

    test('returns pr icon', () {
      expect(getIcon('pr'), Icons.call_merge);
    });

    test('returns commit icon', () {
      expect(getIcon('commit'), Icons.commit);
    });

    test('returns repo icon', () {
      expect(getIcon('repo'), Icons.book_outlined);
    });

    test('returns user icon', () {
      expect(getIcon('user'), Icons.person_outline);
    });

    test('returns code icon', () {
      expect(getIcon('code'), Icons.code);
    });

    test('returns branch icon', () {
      expect(getIcon('branch'), Icons.account_tree_outlined);
    });

    test('returns fallback for unknown name', () {
      expect(getIcon('unknown'), Icons.help_outline);
    });
  });

  group('onTapUrl', () {
    test('returns callback for valid URL', () {
      final callback = onTapUrl('https://github.com');
      expect(callback, isNotNull);
    });

    test('returns null for null URL', () {
      final callback = onTapUrl(null);
      expect(callback, isNull);
    });
  });
}

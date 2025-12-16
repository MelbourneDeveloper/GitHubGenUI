import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:github_genui/catalog/catalog_helpers.dart';
import 'package:github_genui/theme/github_theme.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// Schema for stats row data.
final statsRowSchema = S.object(
  properties: {
    'stats': S.list(
      items: S.object(
        properties: {
          'label': S.string(),
          'value': S.string(),
          'icon': S.string(),
        },
      ),
      description: 'List of stat items',
    ),
  },
  required: ['stats'],
);

/// Stats row catalog item.
final CatalogItem statsRow = CatalogItem(
  name: 'StatsRow',
  dataSchema: statsRowSchema,
  widgetBuilder: (itemContext) {
    if (itemContext.data case final Map<String, dynamic> data) {
      return _buildStatsRow(data);
    }
    return const SizedBox.shrink();
  },
);

Widget _buildStatsRow(Map<String, dynamic> data) {
  final statsRaw = listValue(data, 'stats');

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      for (final s in statsRaw)
        if (s case final Map<String, dynamic> stat) _buildStatItem(stat),
    ],
  );
}

Widget _buildStatItem(Map<String, dynamic> stat) {
  final label = str(stat, 'label');
  final value = str(stat, 'value');
  final iconName = strOpt(stat, 'icon');

  return Column(
    children: [
      if (iconName != null)
        Icon(getIcon(iconName), color: GitHubColors.fgMuted, size: 20),
      Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      Text(
        label,
        style: const TextStyle(color: GitHubColors.fgMuted, fontSize: 12),
      ),
    ],
  );
}

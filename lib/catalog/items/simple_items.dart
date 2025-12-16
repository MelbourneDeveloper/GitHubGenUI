/// Simple catalog items: LabelBadge, StatsRow.
library;

import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:github_genui/catalog/helpers.dart';
import 'package:github_genui/theme/github_theme.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

// ============ LABEL BADGE ============

final _labelBadgeSchema = S.object(
  properties: {
    'name': S.string(description: 'Label name'),
    'color': S.string(description: 'Hex color'),
  },
  required: ['name'],
);

/// Label badge catalog item.
final CatalogItem labelBadge = CatalogItem(
  name: 'LabelBadge',
  dataSchema: _labelBadgeSchema,
  widgetBuilder: _buildLabelBadge,
);

Widget _buildLabelBadge(CatalogItemContext itemContext) {
  if (itemContext.data case final Map<String, dynamic> data) {
    final name = str(data, 'name');
    final color = parseColor(strOpt(data, 'color'));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        name,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  return const SizedBox.shrink();
}

// ============ STATS ROW ============

final _statsRowSchema = S.object(
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
  dataSchema: _statsRowSchema,
  widgetBuilder: _buildStatsRow,
);

Widget _buildStatsRow(CatalogItemContext itemContext) {
  if (itemContext.data case final Map<String, dynamic> data) {
    final statsRaw = listVal(data, 'stats');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        for (final s in statsRaw)
          if (s case final Map<String, dynamic> stat) _buildStatColumn(stat),
      ],
    );
  }
  return const SizedBox.shrink();
}

Widget _buildStatColumn(Map<String, dynamic> stat) {
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

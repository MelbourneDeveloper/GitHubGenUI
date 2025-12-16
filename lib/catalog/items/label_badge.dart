import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:github_genui/catalog/catalog_helpers.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// Schema for label badge data.
final labelBadgeSchema = S.object(
  properties: {
    'name': S.string(description: 'Label name'),
    'color': S.string(description: 'Hex color'),
  },
  required: ['name'],
);

/// Label badge catalog item.
final CatalogItem labelBadge = CatalogItem(
  name: 'LabelBadge',
  dataSchema: labelBadgeSchema,
  widgetBuilder: (itemContext) {
    if (itemContext.data case final Map<String, dynamic> data) {
      return _buildLabelBadge(data);
    }
    return const SizedBox.shrink();
  },
);

Widget _buildLabelBadge(Map<String, dynamic> data) {
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
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
    ),
  );
}

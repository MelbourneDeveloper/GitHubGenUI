import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:github_genui/catalog/catalog_helpers.dart';
import 'package:github_genui/theme/github_theme.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// Schema for issue item data.
final issueItemSchema = S.object(
  properties: {
    'number': S.integer(description: 'Issue number'),
    'title': S.string(description: 'Issue title'),
    'state': S.string(description: 'open or closed'),
    'author': S.string(description: 'Author username'),
    'comments': S.integer(description: 'Comment count'),
    'labels': S.list(
      items: S.object(properties: {'name': S.string(), 'color': S.string()}),
      description: 'Issue labels',
    ),
    'isPullRequest': S.boolean(description: 'Is this a PR'),
    'url': S.string(description: 'Issue URL'),
  },
  required: ['number', 'title', 'state'],
);

/// Issue item catalog item.
final CatalogItem issueItem = CatalogItem(
  name: 'IssueItem',
  dataSchema: issueItemSchema,
  widgetBuilder: (itemContext) {
    if (itemContext.data case final Map<String, dynamic> data) {
      return _buildIssueItem(data);
    }
    return const SizedBox.shrink();
  },
);

Widget _buildIssueItem(Map<String, dynamic> data) {
  final number = integer(data, 'number');
  final title = str(data, 'title');
  final state = str(data, 'state');
  final author = strOpt(data, 'author');
  final comments = integer(data, 'comments');
  final labelsRaw = listValue(data, 'labels');
  final isPR = boolean(data, 'isPullRequest');
  final url = strOpt(data, 'url');

  final isOpen = state == 'open';
  final stateColor = isOpen ? GitHubColors.successFg : GitHubColors.doneFg;
  final stateIcon = isPR
      ? (isOpen ? Icons.call_merge : Icons.check)
      : (isOpen ? Icons.circle_outlined : Icons.check_circle);

  return Card(
    margin: EdgeInsets.zero,
    child: InkWell(
      onTap: onTapUrl(url),
      borderRadius: BorderRadius.circular(GitHubRadius.medium),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: stateColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(stateIcon, color: stateColor, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleWithLabels(title, labelsRaw),
                  const SizedBox(height: 6),
                  Text(
                    '#$number ${author != null ? 'by $author' : ''}',
                    style: const TextStyle(
                      color: GitHubColors.fgMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (comments > 0) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 14,
                color: GitHubColors.fgMuted,
              ),
              const SizedBox(width: 4),
              Text(
                '$comments',
                style: const TextStyle(
                  color: GitHubColors.fgMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

Widget _buildTitleWithLabels(String title, List<dynamic> labelsRaw) =>
    Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          for (final l in labelsRaw)
            if (l case final Map<String, dynamic> label)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: _buildLabelChip(label),
              ),
        ],
      ),
    );

Widget _buildLabelChip(Map<String, dynamic> label) {
  final name = str(label, 'name');
  final color = parseColor(strOpt(label, 'color'));
  return Container(
    margin: const EdgeInsets.only(left: 4),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color),
    ),
    child: Text(
      name,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:github_genui/catalog/catalog_helpers.dart';
import 'package:github_genui/theme/github_theme.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// Schema for repository card data.
final repoCardSchema = S.object(
  properties: {
    'name': S.string(description: 'Repository name'),
    'fullName': S.string(description: 'Full name (owner/repo)'),
    'description': S.string(description: 'Repository description'),
    'language': S.string(description: 'Primary language'),
    'stars': S.integer(description: 'Star count'),
    'forks': S.integer(description: 'Fork count'),
    'ownerAvatar': S.string(description: 'Owner avatar URL'),
    'url': S.string(description: 'Repository HTML URL'),
    'topics': S.list(items: S.string(), description: 'Repository topics'),
  },
  required: ['name', 'fullName'],
);

/// Repository card widget for GenUI catalog.
final CatalogItem repositoryCard = CatalogItem(
  name: 'RepositoryCard',
  dataSchema: repoCardSchema,
  widgetBuilder: (itemContext) {
    if (itemContext.data case final Map<String, dynamic> map) {
      return _buildCard(map);
    }
    return const SizedBox.shrink();
  },
);

Widget _buildCard(Map<String, dynamic> data) {
  final fullNameStr = str(data, 'fullName');
  final descStr = strOpt(data, 'description');
  final langStr = strOpt(data, 'language');
  final starsInt = integer(data, 'stars');
  final forksInt = integer(data, 'forks');
  final avatarStr = strOpt(data, 'ownerAvatar');
  final urlStr = strOpt(data, 'url');
  final topics = topicsList(data, 'topics');

  return Card(
    margin: EdgeInsets.zero,
    child: InkWell(
      onTap: onTapUrl(urlStr),
      borderRadius: BorderRadius.circular(GitHubRadius.medium),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(fullNameStr, avatarStr),
            if (descStr != null) _buildDescription(descStr),
            if (topics.isNotEmpty) _buildTopics(topics),
            const SizedBox(height: 12),
            _buildStats(langStr, starsInt, forksInt),
          ],
        ),
      ),
    ),
  );
}

Widget _buildHeader(String fullName, String? avatar) => Row(
  children: [
    Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: GitHubColors.accentEmphasis.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.folder_outlined,
        size: 16,
        color: GitHubColors.accentFg,
      ),
    ),
    const SizedBox(width: 10),
    Expanded(
      child: Text(
        fullName,
        style: const TextStyle(
          color: GitHubColors.accentFg,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
    if (avatar != null && avatar.isNotEmpty)
      CircleAvatar(
        radius: 14,
        backgroundColor: GitHubColors.borderDefault,
        backgroundImage: NetworkImage(avatar),
      ),
  ],
);

Widget _buildDescription(String desc) => Padding(
  padding: const EdgeInsets.only(top: 8),
  child: Text(
    desc,
    style: const TextStyle(color: GitHubColors.fgMuted, fontSize: 14),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  ),
);

Widget _buildTopics(List<String> topics) => Padding(
  padding: const EdgeInsets.only(top: 8),
  child: Wrap(
    spacing: 4,
    runSpacing: 4,
    children: topics.take(5).map(_buildTopicChip).toList(),
  ),
);

Widget _buildTopicChip(String topic) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  decoration: BoxDecoration(
    color: GitHubColors.accentEmphasis.withValues(alpha: 0.2),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    topic,
    style: const TextStyle(color: GitHubColors.accentFg, fontSize: 12),
  ),
);

Widget _buildStats(String? lang, int stars, int forks) => Row(
  children: [
    if (lang != null) ...[
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: getLanguageColor(lang),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: getLanguageColor(lang).withValues(alpha: 0.4),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      const SizedBox(width: 6),
      Text(
        lang,
        style: const TextStyle(color: GitHubColors.fgMuted, fontSize: 12),
      ),
      const SizedBox(width: 14),
    ],
    Icon(
      Icons.star_rounded,
      size: 16,
      color: GitHubColors.warningFg.withValues(alpha: 0.8),
    ),
    const SizedBox(width: 4),
    Text(
      formatCount(stars),
      style: const TextStyle(color: GitHubColors.fgMuted, fontSize: 12),
    ),
    const SizedBox(width: 14),
    const Icon(Icons.call_split_rounded, size: 16, color: GitHubColors.fgMuted),
    const SizedBox(width: 4),
    Text(
      formatCount(forks),
      style: const TextStyle(color: GitHubColors.fgMuted, fontSize: 12),
    ),
  ],
);

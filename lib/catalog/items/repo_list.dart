import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:github_genui/catalog/catalog_helpers.dart';
import 'package:github_genui/catalog/items/repository_card.dart';
import 'package:github_genui/theme/github_theme.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// Schema for repository list data.
final repoListSchema = S.object(
  properties: {
    'title': S.string(description: 'List title'),
    'repos': S.list(items: repoCardSchema, description: 'List of repositories'),
  },
  required: ['repos'],
);

/// Repository list catalog item.
final CatalogItem repoList = CatalogItem(
  name: 'RepoList',
  dataSchema: repoListSchema,
  widgetBuilder: (itemContext) {
    if (itemContext.data case final Map<String, dynamic> data) {
      return _buildRepoList(data);
    }
    return const SizedBox.shrink();
  },
);

Widget _buildRepoList(Map<String, dynamic> data) {
  final title = strOpt(data, 'title');
  final reposRaw = listValue(data, 'repos');

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (title != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
      for (final r in reposRaw)
        if (r case final Map<String, dynamic> repo) _buildRepoCardCompact(repo),
    ],
  );
}

Widget _buildRepoCardCompact(Map<String, dynamic> data) {
  final fullName = str(data, 'fullName');
  final description = strOpt(data, 'description');
  final language = strOpt(data, 'language');
  final stars = integer(data, 'stars');
  final forks = integer(data, 'forks');
  final ownerAvatar = strOpt(data, 'ownerAvatar');
  final url = strOpt(data, 'url');

  return Card(
    child: InkWell(
      onTap: onTapUrl(url),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(fullName, ownerAvatar),
            if (description != null) _buildDescription(description),
            const SizedBox(height: 12),
            _buildStats(language, stars, forks),
          ],
        ),
      ),
    ),
  );
}

Widget _buildHeader(String fullName, String? ownerAvatar) => Row(
  children: [
    if (ownerAvatar != null)
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: CircleAvatar(
          radius: 12,
          backgroundImage: NetworkImage(ownerAvatar),
        ),
      ),
    Expanded(
      child: Text(
        fullName,
        style: const TextStyle(
          color: GitHubColors.accentFg,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
  ],
);

Widget _buildDescription(String description) => Padding(
  padding: const EdgeInsets.only(top: 8),
  child: Text(
    description,
    style: const TextStyle(color: GitHubColors.fgMuted, fontSize: 14),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  ),
);

Widget _buildStats(String? language, int stars, int forks) => Row(
  children: [
    if (language != null) ...[
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: getLanguageColor(language),
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 4),
      Text(
        language,
        style: const TextStyle(color: GitHubColors.fgMuted, fontSize: 12),
      ),
      const SizedBox(width: 16),
    ],
    const Icon(Icons.star_outline, size: 16),
    const SizedBox(width: 4),
    Text(
      formatCount(stars),
      style: const TextStyle(color: GitHubColors.fgMuted, fontSize: 12),
    ),
    const SizedBox(width: 16),
    const Icon(Icons.call_split, size: 16),
    const SizedBox(width: 4),
    Text(
      formatCount(forks),
      style: const TextStyle(color: GitHubColors.fgMuted, fontSize: 12),
    ),
  ],
);

/// List catalog items: RepoList, UserList.
library;

import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:github_genui/catalog/helpers.dart';
import 'package:github_genui/catalog/items/repository_card.dart';
import 'package:github_genui/catalog/items/user_card.dart';
import 'package:github_genui/theme/github_theme.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:url_launcher/url_launcher.dart';

// ============ REPO LIST ============

final _repoListSchema = S.object(
  properties: {
    'title': S.string(description: 'List title'),
    'repos': S.list(items: repoCardSchema, description: 'List of repositories'),
  },
  required: ['repos'],
);

/// Repository list catalog item.
final CatalogItem repoList = CatalogItem(
  name: 'RepoList',
  dataSchema: _repoListSchema,
  widgetBuilder: _buildRepoList,
);

Widget _buildRepoList(CatalogItemContext itemContext) {
  if (itemContext.data case final Map<String, dynamic> data) {
    final title = strOpt(data, 'title');
    final reposRaw = listVal(data, 'repos');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) _buildListTitle(title),
        for (final r in reposRaw)
          if (r case final Map<String, dynamic> repo) _buildRepoCard(repo),
      ],
    );
  }
  return const SizedBox.shrink();
}

// ============ USER LIST ============

final _userListSchema = S.object(
  properties: {
    'title': S.string(description: 'List title'),
    'users': S.list(items: userCardSchema, description: 'List of users'),
  },
  required: ['users'],
);

/// User list catalog item.
final CatalogItem userList = CatalogItem(
  name: 'UserList',
  dataSchema: _userListSchema,
  widgetBuilder: _buildUserList,
);

Widget _buildUserList(CatalogItemContext itemContext) {
  if (itemContext.data case final Map<String, dynamic> data) {
    final title = strOpt(data, 'title');
    final usersRaw = listVal(data, 'users');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) _buildListTitle(title),
        for (final u in usersRaw)
          if (u case final Map<String, dynamic> user) _buildUserCard(user),
      ],
    );
  }
  return const SizedBox.shrink();
}

// ============ SHARED HELPERS ============

Widget _buildListTitle(String title) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Text(
    title,
    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
  ),
);

Widget _buildRepoCard(Map<String, dynamic> data) {
  final fullName = str(data, 'fullName');
  final description = strOpt(data, 'description');
  final language = strOpt(data, 'language');
  final stars = intVal(data, 'stars');
  final forks = intVal(data, 'forks');
  final ownerAvatar = strOpt(data, 'ownerAvatar');
  final url = strOpt(data, 'url');

  return Card(
    child: InkWell(
      onTap: url != null ? () => launchUrl(Uri.parse(url)) : null,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRepoHeader(fullName, ownerAvatar),
            if (description != null) _buildDescription(description),
            const SizedBox(height: 12),
            _buildRepoStats(language, stars, forks),
          ],
        ),
      ),
    ),
  );
}

Widget _buildRepoHeader(String fullName, String? avatar) => Row(
  children: [
    if (avatar != null)
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: CircleAvatar(radius: 12, backgroundImage: NetworkImage(avatar)),
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

Widget _buildDescription(String desc) => Padding(
  padding: const EdgeInsets.only(top: 8),
  child: Text(
    desc,
    style: const TextStyle(color: GitHubColors.fgMuted, fontSize: 14),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  ),
);

Widget _buildRepoStats(String? lang, int stars, int forks) => Row(
  children: [
    if (lang != null) ...[
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: getLanguageColor(lang),
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 4),
      Text(
        lang,
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

Widget _buildUserCard(Map<String, dynamic> data) {
  final login = str(data, 'login');
  final avatarUrl = str(data, 'avatarUrl');
  final name = strOpt(data, 'name');
  final bio = strOpt(data, 'bio');
  final url = strOpt(data, 'url');

  return Card(
    child: InkWell(
      onTap: url != null ? () => launchUrl(Uri.parse(url)) : null,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(radius: 24, backgroundImage: NetworkImage(avatarUrl)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (name != null)
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  Text(
                    login,
                    style: const TextStyle(
                      color: GitHubColors.fgMuted,
                      fontSize: 12,
                    ),
                  ),
                  if (bio != null)
                    Text(
                      bio,
                      style: const TextStyle(
                        color: GitHubColors.fgMuted,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:github_genui/catalog/catalog_helpers.dart';
import 'package:github_genui/theme/github_theme.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// Schema for user card data.
final userCardSchema = S.object(
  properties: {
    'login': S.string(description: 'Username'),
    'avatarUrl': S.string(description: 'Avatar URL'),
    'name': S.string(description: 'Display name'),
    'bio': S.string(description: 'User bio'),
    'followers': S.integer(description: 'Follower count'),
    'following': S.integer(description: 'Following count'),
    'publicRepos': S.integer(description: 'Public repo count'),
    'url': S.string(description: 'Profile URL'),
  },
  required: ['login'],
);

/// User card catalog item.
final CatalogItem userCard = CatalogItem(
  name: 'UserCard',
  dataSchema: userCardSchema,
  widgetBuilder: (itemContext) {
    if (itemContext.data case final Map<String, dynamic> data) {
      return _buildUserCard(data);
    }
    return const SizedBox.shrink();
  },
);

Widget _buildUserCard(Map<String, dynamic> data) {
  final login = str(data, 'login');
  final avatarUrl = strOpt(data, 'avatarUrl');
  final name = strOpt(data, 'name');
  final bio = strOpt(data, 'bio');
  final followers = integer(data, 'followers');
  final following = integer(data, 'following');
  final publicRepos = integer(data, 'publicRepos');
  final url = strOpt(data, 'url');

  return Card(
    child: InkWell(
      onTap: onTapUrl(url),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: _avatarImage(avatarUrl),
              child: avatarUrl == null || avatarUrl.isEmpty
                  ? const Icon(Icons.person, size: 32)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (name != null)
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  Text(
                    login,
                    style: const TextStyle(
                      color: GitHubColors.fgMuted,
                      fontSize: 14,
                    ),
                  ),
                  if (bio != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      bio,
                      style: const TextStyle(
                        color: GitHubColors.fgMuted,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  _buildUserStats(followers, following, publicRepos),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

ImageProvider<Object>? _avatarImage(String? url) =>
    url != null && url.isNotEmpty ? NetworkImage(url) : null;

Widget _buildUserStats(int followers, int following, int publicRepos) => Wrap(
  spacing: 8,
  runSpacing: 4,
  children: [
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.people_outline, size: 16),
        const SizedBox(width: 4),
        Text(
          '$followers followers',
          style: const TextStyle(color: GitHubColors.fgMuted, fontSize: 12),
        ),
      ],
    ),
    Text(
      '$following following',
      style: const TextStyle(color: GitHubColors.fgMuted, fontSize: 12),
    ),
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.book_outlined, size: 16),
        const SizedBox(width: 4),
        Text(
          '$publicRepos repos',
          style: const TextStyle(color: GitHubColors.fgMuted, fontSize: 12),
        ),
      ],
    ),
  ],
);

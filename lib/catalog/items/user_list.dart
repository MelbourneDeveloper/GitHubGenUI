import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:github_genui/catalog/catalog_helpers.dart';
import 'package:github_genui/catalog/items/user_card.dart';
import 'package:github_genui/theme/github_theme.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// Schema for user list data.
final userListSchema = S.object(
  properties: {
    'title': S.string(description: 'List title'),
    'users': S.list(items: userCardSchema, description: 'List of users'),
  },
  required: ['users'],
);

/// User list catalog item.
final CatalogItem userList = CatalogItem(
  name: 'UserList',
  dataSchema: userListSchema,
  widgetBuilder: (itemContext) {
    if (itemContext.data case final Map<String, dynamic> data) {
      return _buildUserList(data);
    }
    return const SizedBox.shrink();
  },
);

Widget _buildUserList(Map<String, dynamic> data) {
  final title = strOpt(data, 'title');
  final usersRaw = listValue(data, 'users');

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
      for (final u in usersRaw)
        if (u case final Map<String, dynamic> user) _buildUserCardCompact(user),
    ],
  );
}

Widget _buildUserCardCompact(Map<String, dynamic> data) {
  final login = str(data, 'login');
  final avatarUrl = str(data, 'avatarUrl');
  final name = strOpt(data, 'name');
  final bio = strOpt(data, 'bio');
  final url = strOpt(data, 'url');

  return Card(
    child: InkWell(
      onTap: onTapUrl(url),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl.isEmpty
                  ? const Icon(Icons.person, size: 24)
                  : null,
            ),
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

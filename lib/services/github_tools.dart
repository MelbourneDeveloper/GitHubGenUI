import 'package:genui/genui.dart';
import 'package:github_genui/services/github_api.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:nadz/nadz.dart';

/// Creates GitHub API tools for GenUI.
List<DynamicAiTool<Map<String, Object?>>> createGitHubTools(
  GitHubApi api,
) => [
  _createGetUserTool(api),
  _createSearchUsersTool(api),
  _createGetRepositoryTool(api),
  _createSearchRepositoriesTool(api),
  _createGetUserRepositoriesTool(api),
  _createGetRepositoryIssuesTool(api),
  _createSearchIssuesTool(api),
];

DynamicAiTool<Map<String, Object?>> _createGetUserTool(GitHubApi api) =>
  DynamicAiTool(
    name: 'getUser',
    description: 'Get a GitHub user profile by username. '
      'Returns user information including name, bio, followers, '
      'following, public repos count, avatar URL, and more.',
    parameters: Schema.object(
      properties: {
        'username': Schema.string(description: 'GitHub username to look up'),
      },
      required: ['username'],
    ),
    invokeFunction: (args) async {
      final username = args['username'] as String? ?? '';
      final result = await api.getUser(username);

      return switch (result) {
        Success(value: final user) => {
          'success': true,
          'user': _userToJson(user),
        },
        Error(error: final e) => {
          'success': false,
          'error': e.toString(),
        },
      };
    },
  );

DynamicAiTool<Map<String, Object?>> _createSearchUsersTool(GitHubApi api) =>
  DynamicAiTool(
    name: 'searchUsers',
    description: 'Search for GitHub users by query string. '
      'Can search by username, location, language, etc.',
    parameters: Schema.object(
      properties: {
        'query': Schema.string(description: 'Search query for users'),
        'sort': Schema.string(
          description: 'Sort field: followers, repositories, or joined',
        ),
        'order': Schema.string(
          description: 'Sort order: asc or desc',
        ),
        'perPage': Schema.integer(
          description: 'Results per page (max 100)',
        ),
      },
      required: ['query'],
    ),
    invokeFunction: (args) async {
      final query = args['query'] as String? ?? '';
      final sort = args['sort'] as String? ?? 'followers';
      final order = args['order'] as String? ?? 'desc';
      final perPage = args['perPage'] as int? ?? 30;

      final result = await api.searchUsers(
        query,
        sort: sort,
        order: order,
        perPage: perPage,
      );

      return switch (result) {
        Success(value: final results) => {
          'success': true,
          'totalCount': results.totalCount,
          'users': [
            for (final user in results.items) _userToJson(user),
          ],
        },
        Error(error: final e) => {
          'success': false,
          'error': e.toString(),
        },
      };
    },
  );

DynamicAiTool<Map<String, Object?>> _createGetRepositoryTool(GitHubApi api) =>
  DynamicAiTool(
    name: 'getRepository',
    description: 'Get a GitHub repository by owner and name. '
      'Returns repository details including description, stars, '
      'forks, language, topics, and more.',
    parameters: Schema.object(
      properties: {
        'owner': Schema.string(description: 'Repository owner username'),
        'repo': Schema.string(description: 'Repository name'),
      },
      required: ['owner', 'repo'],
    ),
    invokeFunction: (args) async {
      final owner = args['owner'] as String? ?? '';
      final repo = args['repo'] as String? ?? '';
      final result = await api.getRepository(owner, repo);

      return switch (result) {
        Success(value: final repository) => {
          'success': true,
          'repository': _repositoryToJson(repository),
        },
        Error(error: final e) => {
          'success': false,
          'error': e.toString(),
        },
      };
    },
  );

DynamicAiTool<Map<String, Object?>> _createSearchRepositoriesTool(
  GitHubApi api,
) => DynamicAiTool(
  name: 'searchRepositories',
  description: 'Search for GitHub repositories by query string. '
    'Can search by name, description, topic, language, etc.',
  parameters: Schema.object(
    properties: {
      'query': Schema.string(description: 'Search query for repositories'),
      'sort': Schema.string(
        description: 'Sort field: stars, forks, help-wanted-issues, or updated',
      ),
      'order': Schema.string(
        description: 'Sort order: asc or desc',
      ),
      'perPage': Schema.integer(
        description: 'Results per page (max 100)',
      ),
    },
    required: ['query'],
  ),
  invokeFunction: (args) async {
    final query = args['query'] as String? ?? '';
    final sort = args['sort'] as String? ?? 'stars';
    final order = args['order'] as String? ?? 'desc';
    final perPage = args['perPage'] as int? ?? 30;

    final result = await api.searchRepositories(
      query,
      sort: sort,
      order: order,
      perPage: perPage,
    );

    return switch (result) {
      Success(value: final results) => {
        'success': true,
        'totalCount': results.totalCount,
        'repositories': [
          for (final repo in results.items) _repositoryToJson(repo),
        ],
      },
      Error(error: final e) => {
        'success': false,
        'error': e.toString(),
      },
    };
  },
);

DynamicAiTool<Map<String, Object?>> _createGetUserRepositoriesTool(
  GitHubApi api,
) => DynamicAiTool(
  name: 'getUserRepositories',
  description: "Get a user's public repositories. "
    'Returns a list of repositories owned by the specified user.',
  parameters: Schema.object(
    properties: {
      'username': Schema.string(description: 'GitHub username'),
      'sort': Schema.string(
        description: 'Sort field: created, updated, pushed, or full_name',
      ),
      'perPage': Schema.integer(
        description: 'Results per page (max 100)',
      ),
    },
    required: ['username'],
  ),
  invokeFunction: (args) async {
    final username = args['username'] as String? ?? '';
    final sort = args['sort'] as String? ?? 'updated';
    final perPage = args['perPage'] as int? ?? 30;

    final result = await api.getUserRepositories(
      username,
      sort: sort,
      perPage: perPage,
    );

    return switch (result) {
      Success(value: final repositories) => {
        'success': true,
        'repositories': [
          for (final repo in repositories) _repositoryToJson(repo),
        ],
      },
      Error(error: final e) => {
        'success': false,
        'error': e.toString(),
      },
    };
  },
);

DynamicAiTool<Map<String, Object?>> _createGetRepositoryIssuesTool(
  GitHubApi api,
) => DynamicAiTool(
  name: 'getRepositoryIssues',
  description: 'Get issues and pull requests for a repository. '
    'Returns a list of issues with details like title, state, labels, etc.',
  parameters: Schema.object(
    properties: {
      'owner': Schema.string(description: 'Repository owner username'),
      'repo': Schema.string(description: 'Repository name'),
      'state': Schema.string(
        description: 'Issue state: open, closed, or all',
      ),
      'perPage': Schema.integer(
        description: 'Results per page (max 100)',
      ),
    },
    required: ['owner', 'repo'],
  ),
  invokeFunction: (args) async {
    final owner = args['owner'] as String? ?? '';
    final repo = args['repo'] as String? ?? '';
    final state = args['state'] as String? ?? 'open';
    final perPage = args['perPage'] as int? ?? 30;

    final result = await api.getRepositoryIssues(
      owner,
      repo,
      state: state,
      perPage: perPage,
    );

    return switch (result) {
      Success(value: final issues) => {
        'success': true,
        'issues': [
          for (final issue in issues) _issueToJson(issue),
        ],
      },
      Error(error: final e) => {
        'success': false,
        'error': e.toString(),
      },
    };
  },
);

DynamicAiTool<Map<String, Object?>> _createSearchIssuesTool(GitHubApi api) =>
  DynamicAiTool(
    name: 'searchIssues',
    description: 'Search for GitHub issues and pull requests by query string. '
      'Can search across all of GitHub or within specific repositories.',
    parameters: Schema.object(
      properties: {
        'query': Schema.string(description: 'Search query for issues'),
        'sort': Schema.string(
          description: 'Sort field: created, updated, or comments',
        ),
        'order': Schema.string(
          description: 'Sort order: asc or desc',
        ),
        'perPage': Schema.integer(
          description: 'Results per page (max 100)',
        ),
      },
      required: ['query'],
    ),
    invokeFunction: (args) async {
      final query = args['query'] as String? ?? '';
      final sort = args['sort'] as String? ?? 'created';
      final order = args['order'] as String? ?? 'desc';
      final perPage = args['perPage'] as int? ?? 30;

      final result = await api.searchIssues(
        query,
        sort: sort,
        order: order,
        perPage: perPage,
      );

      return switch (result) {
        Success(value: final results) => {
          'success': true,
          'totalCount': results.totalCount,
          'issues': [
            for (final issue in results.items) _issueToJson(issue),
          ],
        },
        Error(error: final e) => {
          'success': false,
          'error': e.toString(),
        },
      };
    },
  );

// JSON serialization helpers

Map<String, Object?> _userToJson(User user) => {
  'login': user.login,
  'id': user.id,
  'avatarUrl': user.avatarUrl,
  'htmlUrl': user.htmlUrl,
  'name': user.name,
  'company': user.company,
  'blog': user.blog,
  'location': user.location,
  'email': user.email,
  'bio': user.bio,
  'publicRepos': user.publicRepos,
  'publicGists': user.publicGists,
  'followers': user.followers,
  'following': user.following,
  'createdAt': user.createdAt.toIso8601String(),
};

Map<String, Object?> _repositoryToJson(Repository repo) => {
  'id': repo.id,
  'name': repo.name,
  'fullName': repo.fullName,
  'owner': {
    'login': repo.owner.login,
    'id': repo.owner.id,
    'avatarUrl': repo.owner.avatarUrl,
    'type': repo.owner.type,
  },
  'description': repo.description,
  'private': repo.private,
  'htmlUrl': repo.htmlUrl,
  'language': repo.language,
  'stargazersCount': repo.stargazersCount,
  'forksCount': repo.forksCount,
  'watchersCount': repo.watchersCount,
  'openIssuesCount': repo.openIssuesCount,
  'defaultBranch': repo.defaultBranch,
  'createdAt': repo.createdAt.toIso8601String(),
  'updatedAt': repo.updatedAt.toIso8601String(),
  'topics': repo.topics,
};

Map<String, Object?> _issueToJson(Issue issue) => {
  'id': issue.id,
  'number': issue.number,
  'title': issue.title,
  'state': issue.state,
  'user': _userToJson(issue.user),
  'labels': [
    for (final label in issue.labels)
      {
        'id': label.id,
        'name': label.name,
        'color': label.color,
        'description': label.description,
      },
  ],
  'body': issue.body,
  'comments': issue.comments,
  'createdAt': issue.createdAt.toIso8601String(),
  'closedAt': issue.closedAt?.toIso8601String(),
  'htmlUrl': issue.htmlUrl,
  'isPullRequest': issue.isPullRequest,
};

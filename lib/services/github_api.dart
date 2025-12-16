import 'dart:convert';

import 'package:github_genui/models/github_models.dart';
import 'package:http/http.dart' as http;
import 'package:nadz/nadz.dart';

export 'package:github_genui/models/github_models.dart';

/// Error types for GitHub API.
sealed class GitHubError {
  const GitHubError();
}

/// Resource not found error.
final class NotFoundError extends GitHubError {
  /// Creates a not found error.
  const NotFoundError(this.endpoint);

  /// The endpoint that was not found.
  final String endpoint;

  @override
  String toString() => 'Not found: $endpoint';
}

/// Rate limit exceeded error.
final class RateLimitError extends GitHubError {
  /// Creates a rate limit error.
  const RateLimitError(this.resetTime);

  /// When the rate limit resets.
  final DateTime? resetTime;

  @override
  String toString() => resetTime != null
      ? 'Rate limit exceeded. Resets at $resetTime'
      : 'Rate limit exceeded';
}

/// General API error.
final class ApiError extends GitHubError {
  /// Creates an API error.
  const ApiError(this.message, this.statusCode);

  /// Error message.
  final String message;

  /// HTTP status code.
  final int statusCode;

  @override
  String toString() => '$message (status: $statusCode)';
}

/// Parse error.
final class ParseError extends GitHubError {
  /// Creates a parse error.
  const ParseError(this.message);

  /// Error message.
  final String message;

  @override
  String toString() => 'Parse error: $message';
}

/// GitHub REST API client (public endpoints only, no auth required).
class GitHubApi {
  /// Creates a GitHub API client.
  GitHubApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _baseUrl = 'https://api.github.com';

  /// Remaining API calls before rate limit.
  int? rateLimitRemaining;

  /// When the rate limit resets.
  DateTime? rateLimitReset;

  Future<Result<dynamic, GitHubError>> _get(String endpoint) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Accept': 'application/vnd.github.v3+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    );

    _updateRateLimits(response.headers);

    return switch (response.statusCode) {
      200 => Success(json.decode(response.body)),
      404 => Error(NotFoundError(endpoint)),
      403 => Error(RateLimitError(rateLimitReset)),
      _ => Error(
        ApiError('API error: ${response.statusCode}', response.statusCode),
      ),
    };
  }

  void _updateRateLimits(Map<String, String> headers) {
    final remaining = headers['x-ratelimit-remaining'];
    final reset = headers['x-ratelimit-reset'];
    if (remaining != null) {
      rateLimitRemaining = int.tryParse(remaining);
    }
    if (reset != null) {
      final timestamp = int.tryParse(reset);
      if (timestamp != null) {
        rateLimitReset = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      }
    }
  }

  /// Get a repository by owner and name.
  Future<Result<Repository, GitHubError>> getRepository(
    String owner,
    String repo,
  ) async {
    final result = await _get('/repos/$owner/$repo');
    return switch (result) {
      Success(value: final data) => _parseMap(data, (m) => m.toRepository()),
      Error(error: final e) => Error(e),
    };
  }

  /// List repositories for a user.
  Future<Result<List<Repository>, GitHubError>> getUserRepositories(
    String username, {
    String sort = 'updated',
    int perPage = 30,
    int page = 1,
  }) async {
    final result = await _get(
      '/users/$username/repos?sort=$sort&per_page=$perPage&page=$page',
    );
    return switch (result) {
      Success(value: final data) => _parseList(data, _parseRepoList),
      Error(error: final e) => Error(e),
    };
  }

  /// Search repositories.
  Future<Result<SearchResults<Repository>, GitHubError>> searchRepositories(
    String query, {
    String sort = 'stars',
    String order = 'desc',
    int perPage = 30,
    int page = 1,
  }) async {
    final encodedQuery = Uri.encodeQueryComponent(query);
    final result = await _get(
      '/search/repositories?q=$encodedQuery&sort=$sort'
      '&order=$order&per_page=$perPage&page=$page',
    );
    return switch (result) {
      Success(value: final data) => _parseSearchResults(data, _parseRepoList),
      Error(error: final e) => Error(e),
    };
  }

  /// Get repository contents (files/directories).
  Future<Result<List<RepoContent>, GitHubError>> getRepositoryContents(
    String owner,
    String repo, {
    String path = '',
  }) async {
    final endpoint = path.isEmpty
        ? '/repos/$owner/$repo/contents'
        : '/repos/$owner/$repo/contents/$path';
    final result = await _get(endpoint);
    return switch (result) {
      Success(value: final List<dynamic> list) => Success(
        _parseContentList(list),
      ),
      Success(value: final Map<String, dynamic> map) => Success([
        map.toRepoContent(),
      ]),
      Success() => const Error(ParseError('Unexpected response type')),
      Error(error: final e) => Error(e),
    };
  }

  /// Get file content (decoded).
  Future<Result<String, GitHubError>> getFileContent(
    String owner,
    String repo,
    String path,
  ) async {
    final result = await _get('/repos/$owner/$repo/contents/$path');
    return switch (result) {
      Success(value: final Map<String, dynamic> map) => _extractContent(
        map,
        'No content in file',
      ),
      Success() => const Error(ParseError('Expected object')),
      Error(error: final e) => Error(e),
    };
  }

  /// Get README content.
  Future<Result<String, GitHubError>> getReadme(
    String owner,
    String repo,
  ) async {
    final result = await _get('/repos/$owner/$repo/readme');
    return switch (result) {
      Success(value: final Map<String, dynamic> map) => _extractContent(
        map,
        'No README content',
      ),
      Success() => const Error(ParseError('Expected object')),
      Error(error: final e) => Error(e),
    };
  }

  /// Get a user by username.
  Future<Result<User, GitHubError>> getUser(String username) async {
    final result = await _get('/users/$username');
    return switch (result) {
      Success(value: final data) => _parseMap(data, (m) => m.toUser()),
      Error(error: final e) => Error(e),
    };
  }

  /// Search users.
  Future<Result<SearchResults<User>, GitHubError>> searchUsers(
    String query, {
    String sort = 'followers',
    String order = 'desc',
    int perPage = 30,
    int page = 1,
  }) async {
    final encodedQuery = Uri.encodeQueryComponent(query);
    final result = await _get(
      '/search/users?q=$encodedQuery&sort=$sort'
      '&order=$order&per_page=$perPage&page=$page',
    );
    return switch (result) {
      Success(value: final data) => _parseSearchResults(data, _parseUserList),
      Error(error: final e) => Error(e),
    };
  }

  /// List issues for a repository.
  Future<Result<List<Issue>, GitHubError>> getRepositoryIssues(
    String owner,
    String repo, {
    String state = 'open',
    int perPage = 30,
    int page = 1,
  }) async {
    final result = await _get(
      '/repos/$owner/$repo/issues?state=$state&per_page=$perPage&page=$page',
    );
    return switch (result) {
      Success(value: final data) => _parseList(data, _parseIssueList),
      Error(error: final e) => Error(e),
    };
  }

  /// Get a single issue.
  Future<Result<Issue, GitHubError>> getIssue(
    String owner,
    String repo,
    int issueNumber,
  ) async {
    final result = await _get('/repos/$owner/$repo/issues/$issueNumber');
    return switch (result) {
      Success(value: final data) => _parseMap(data, (m) => m.toIssue()),
      Error(error: final e) => Error(e),
    };
  }

  /// Search issues.
  Future<Result<SearchResults<Issue>, GitHubError>> searchIssues(
    String query, {
    String sort = 'created',
    String order = 'desc',
    int perPage = 30,
    int page = 1,
  }) async {
    final encodedQuery = Uri.encodeQueryComponent(query);
    final result = await _get(
      '/search/issues?q=$encodedQuery&sort=$sort'
      '&order=$order&per_page=$perPage&page=$page',
    );
    return switch (result) {
      Success(value: final data) => _parseSearchResults(data, _parseIssueList),
      Error(error: final e) => Error(e),
    };
  }

  /// List commits for a repository.
  Future<Result<List<Commit>, GitHubError>> getRepositoryCommits(
    String owner,
    String repo, {
    int perPage = 30,
    int page = 1,
  }) async {
    final result = await _get(
      '/repos/$owner/$repo/commits?per_page=$perPage&page=$page',
    );
    return switch (result) {
      Success(value: final data) => _parseList(data, _parseCommitList),
      Error(error: final e) => Error(e),
    };
  }

  // Parsing helpers

  Result<T, GitHubError> _parseMap<T>(
    Object? data,
    T Function(Map<String, dynamic>) parse,
  ) => switch (data) {
    final Map<String, dynamic> map => Success(parse(map)),
    _ => const Error(ParseError('Expected object')),
  };

  Result<List<T>, GitHubError> _parseList<T>(
    Object? data,
    List<T> Function(List<dynamic>) parse,
  ) => switch (data) {
    final List<dynamic> list => Success(parse(list)),
    _ => const Error(ParseError('Expected array')),
  };

  Result<String, GitHubError> _extractContent(
    Map<String, dynamic> map,
    String errorMsg,
  ) {
    if (map['content'] case final String content) {
      final cleaned = content.replaceAll('\n', '');
      return Success(utf8.decode(base64.decode(cleaned)));
    }
    return Error(ParseError(errorMsg));
  }

  List<Repository> _parseRepoList(List<dynamic> list) => [
    for (final item in list)
      if (item case final Map<String, dynamic> map) map.toRepository(),
  ];

  List<User> _parseUserList(List<dynamic> list) => [
    for (final item in list)
      if (item case final Map<String, dynamic> map) map.toUser(),
  ];

  List<Issue> _parseIssueList(List<dynamic> list) => [
    for (final item in list)
      if (item case final Map<String, dynamic> map) map.toIssue(),
  ];

  List<Commit> _parseCommitList(List<dynamic> list) => [
    for (final item in list)
      if (item case final Map<String, dynamic> map) map.toCommit(),
  ];

  List<RepoContent> _parseContentList(List<dynamic> list) => [
    for (final item in list)
      if (item case final Map<String, dynamic> map) map.toRepoContent(),
  ];

  Result<SearchResults<T>, GitHubError> _parseSearchResults<T>(
    Object? data,
    List<T> Function(List<dynamic>) parseItems,
  ) {
    if (data case final Map<String, dynamic> map) {
      final items = map['items'];
      final totalCount = map['total_count'];
      final incompleteResults = map['incomplete_results'];

      if (items case final List<dynamic> list) {
        if (totalCount case final int count) {
          if (incompleteResults case final bool incomplete) {
            return Success((
              totalCount: count,
              incompleteResults: incomplete,
              items: parseItems(list),
            ));
          }
        }
      }
    }
    return const Error(ParseError('Invalid search results structure'));
  }
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:github_genui/services/github_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nadz/nadz.dart';

void main() {
  group('GitHubApi.getRepository', () {
    test('parses repository response', () async {
      final client = MockClient(
        (r) async => http.Response(jsonEncode(_repoJson), 200),
      );
      final api = GitHubApi(client: client);
      final result = await api.getRepository('flutter', 'flutter');

      expect(result, isA<Success<Repository, GitHubError>>());
      final repo = (result as Success<Repository, GitHubError>).value;
      expect(repo.name, 'flutter');
      expect(repo.fullName, 'flutter/flutter');
      expect(repo.stargazersCount, 150000);
    });

    test('handles 404 error', () async {
      final client = MockClient((r) async => http.Response('', 404));
      final api = GitHubApi(client: client);
      final result = await api.getRepository('x', 'y');

      expect(result, isA<Error<Repository, GitHubError>>());
      expect((result as Error).error, isA<NotFoundError>());
    });

    test('handles 403 rate limit', () async {
      final client = MockClient((r) async => http.Response('', 403));
      final api = GitHubApi(client: client);
      final result = await api.getRepository('x', 'y');

      expect(result, isA<Error<Repository, GitHubError>>());
      expect((result as Error).error, isA<RateLimitError>());
    });

    test('handles 500 error', () async {
      final client = MockClient((r) async => http.Response('', 500));
      final api = GitHubApi(client: client);
      final result = await api.getRepository('x', 'y');

      expect(result, isA<Error<Repository, GitHubError>>());
      expect((result as Error).error, isA<ApiError>());
      final err = (result as Error).error as ApiError;
      expect(err.statusCode, 500);
    });
  });

  group('GitHubApi.getUserRepositories', () {
    test('returns list of repositories', () async {
      final client = MockClient(
        (r) async => http.Response(jsonEncode([_repoJson, _repoJson]), 200),
      );
      final api = GitHubApi(client: client);
      final result = await api.getUserRepositories('flutter');

      expect(result, isA<Success<List<Repository>, GitHubError>>());
      final repos = (result as Success<List<Repository>, GitHubError>).value;
      expect(repos.length, 2);
    });

    test('handles empty list', () async {
      final client = MockClient(
        (r) async => http.Response(jsonEncode(<Map<String, dynamic>>[]), 200),
      );
      final api = GitHubApi(client: client);
      final result = await api.getUserRepositories('empty');

      expect(result, isA<Success<List<Repository>, GitHubError>>());
      final repos = (result as Success<List<Repository>, GitHubError>).value;
      expect(repos, isEmpty);
    });

    test('includes query parameters', () async {
      String? capturedUrl;
      final client = MockClient((r) async {
        capturedUrl = r.url.toString();
        return http.Response(jsonEncode(<Map<String, dynamic>>[]), 200);
      });
      final api = GitHubApi(client: client);
      await api.getUserRepositories(
        'user',
        sort: 'stars',
        perPage: 10,
        page: 2,
      );

      expect(capturedUrl, contains('sort=stars'));
      expect(capturedUrl, contains('per_page=10'));
      expect(capturedUrl, contains('page=2'));
    });
  });

  group('GitHubApi.searchRepositories', () {
    test('parses search results', () async {
      final client = MockClient(
        (r) async => http.Response(
          jsonEncode({
            'total_count': 100,
            'incomplete_results': false,
            'items': [_repoJson],
          }),
          200,
        ),
      );
      final api = GitHubApi(client: client);
      final result = await api.searchRepositories('flutter');

      expect(result, isA<Success<SearchResults<Repository>, GitHubError>>());
      final sr =
          (result as Success<SearchResults<Repository>, GitHubError>).value;
      expect(sr.totalCount, 100);
      expect(sr.incompleteResults, false);
      expect(sr.items.length, 1);
    });

    test('encodes query parameter', () async {
      String? capturedUrl;
      final client = MockClient((r) async {
        capturedUrl = r.url.toString();
        return http.Response(
          jsonEncode({
            'total_count': 0,
            'incomplete_results': false,
            'items': <Map<String, dynamic>>[],
          }),
          200,
        );
      });
      final api = GitHubApi(client: client);
      await api.searchRepositories('flutter mobile');

      expect(capturedUrl, contains('flutter+mobile'));
    });
  });

  group('GitHubApi.getUser', () {
    test('parses user response', () async {
      final client = MockClient(
        (r) async => http.Response(jsonEncode(_userJson), 200),
      );
      final api = GitHubApi(client: client);
      final result = await api.getUser('octocat');

      expect(result, isA<Success<User, GitHubError>>());
      final user = (result as Success<User, GitHubError>).value;
      expect(user.login, 'octocat');
      expect(user.followers, 5000);
    });
  });

  group('GitHubApi.searchUsers', () {
    test('parses search results', () async {
      final client = MockClient(
        (r) async => http.Response(
          jsonEncode({
            'total_count': 50,
            'incomplete_results': false,
            'items': [_userJson],
          }),
          200,
        ),
      );
      final api = GitHubApi(client: client);
      final result = await api.searchUsers('octocat');

      expect(result, isA<Success<SearchResults<User>, GitHubError>>());
      final sr = (result as Success<SearchResults<User>, GitHubError>).value;
      expect(sr.totalCount, 50);
      expect(sr.items.length, 1);
    });
  });

  group('GitHubApi.getRepositoryIssues', () {
    test('returns list of issues', () async {
      final client = MockClient(
        (r) async => http.Response(jsonEncode([_issueJson]), 200),
      );
      final api = GitHubApi(client: client);
      final result = await api.getRepositoryIssues('owner', 'repo');

      expect(result, isA<Success<List<Issue>, GitHubError>>());
      final issues = (result as Success<List<Issue>, GitHubError>).value;
      expect(issues.length, 1);
      expect(issues.first.title, 'Bug report');
    });

    test('includes state parameter', () async {
      String? capturedUrl;
      final client = MockClient((r) async {
        capturedUrl = r.url.toString();
        return http.Response(jsonEncode(<Map<String, dynamic>>[]), 200);
      });
      final api = GitHubApi(client: client);
      await api.getRepositoryIssues('o', 'r', state: 'closed');

      expect(capturedUrl, contains('state=closed'));
    });
  });

  group('GitHubApi.getIssue', () {
    test('parses single issue', () async {
      final client = MockClient(
        (r) async => http.Response(jsonEncode(_issueJson), 200),
      );
      final api = GitHubApi(client: client);
      final result = await api.getIssue('owner', 'repo', 42);

      expect(result, isA<Success<Issue, GitHubError>>());
      final issue = (result as Success<Issue, GitHubError>).value;
      expect(issue.number, 42);
    });
  });

  group('GitHubApi.searchIssues', () {
    test('parses search results', () async {
      final client = MockClient(
        (r) async => http.Response(
          jsonEncode({
            'total_count': 10,
            'incomplete_results': false,
            'items': [_issueJson],
          }),
          200,
        ),
      );
      final api = GitHubApi(client: client);
      final result = await api.searchIssues('bug');

      expect(result, isA<Success<SearchResults<Issue>, GitHubError>>());
    });
  });

  group('GitHubApi.getRepositoryCommits', () {
    test('returns list of commits', () async {
      final client = MockClient(
        (r) async => http.Response(jsonEncode([_commitJson]), 200),
      );
      final api = GitHubApi(client: client);
      final result = await api.getRepositoryCommits('owner', 'repo');

      expect(result, isA<Success<List<Commit>, GitHubError>>());
      final commits = (result as Success<List<Commit>, GitHubError>).value;
      expect(commits.length, 1);
      expect(commits.first.sha, 'abc123');
    });
  });

  group('GitHubApi.getRepositoryContents', () {
    test('returns list of contents', () async {
      final client = MockClient(
        (r) async => http.Response(jsonEncode([_contentJson]), 200),
      );
      final api = GitHubApi(client: client);
      final result = await api.getRepositoryContents('owner', 'repo');

      expect(result, isA<Success<List<RepoContent>, GitHubError>>());
      final contents =
          (result as Success<List<RepoContent>, GitHubError>).value;
      expect(contents.length, 1);
      expect(contents.first.name, 'README.md');
    });

    test('returns single file as list', () async {
      final client = MockClient(
        (r) async => http.Response(jsonEncode(_contentJson), 200),
      );
      final api = GitHubApi(client: client);
      final result = await api.getRepositoryContents(
        'o',
        'r',
        path: 'README.md',
      );

      expect(result, isA<Success<List<RepoContent>, GitHubError>>());
      final contents =
          (result as Success<List<RepoContent>, GitHubError>).value;
      expect(contents.length, 1);
    });

    test('includes path in endpoint', () async {
      String? capturedUrl;
      final client = MockClient((r) async {
        capturedUrl = r.url.toString();
        return http.Response(jsonEncode(<Map<String, dynamic>>[]), 200);
      });
      final api = GitHubApi(client: client);
      await api.getRepositoryContents('o', 'r', path: 'lib/src');

      expect(capturedUrl, contains('/contents/lib/src'));
    });
  });

  group('GitHubApi.getFileContent', () {
    test('decodes base64 content', () async {
      final encoded = base64.encode(utf8.encode('Hello World'));
      final client = MockClient(
        (r) async => http.Response(
          jsonEncode({..._contentJson, 'content': encoded}),
          200,
        ),
      );
      final api = GitHubApi(client: client);
      final result = await api.getFileContent('o', 'r', 'file.txt');

      expect(result, isA<Success<String, GitHubError>>());
      final content = (result as Success<String, GitHubError>).value;
      expect(content, 'Hello World');
    });

    test('handles missing content', () async {
      final client = MockClient(
        (r) async =>
            http.Response(jsonEncode({..._contentJson, 'content': null}), 200),
      );
      final api = GitHubApi(client: client);
      final result = await api.getFileContent('o', 'r', 'file.txt');

      expect(result, isA<Error<String, GitHubError>>());
      expect((result as Error).error, isA<ParseError>());
    });
  });

  group('GitHubApi.getReadme', () {
    test('decodes readme content', () async {
      final encoded = base64.encode(utf8.encode('# README'));
      final client = MockClient(
        (r) async => http.Response(
          jsonEncode({..._contentJson, 'content': encoded}),
          200,
        ),
      );
      final api = GitHubApi(client: client);
      final result = await api.getReadme('owner', 'repo');

      expect(result, isA<Success<String, GitHubError>>());
      final content = (result as Success<String, GitHubError>).value;
      expect(content, '# README');
    });
  });

  group('Rate limit handling', () {
    test('updates rate limit from headers', () async {
      final resetTime = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600;
      final client = MockClient(
        (r) async => http.Response(
          jsonEncode(_repoJson),
          200,
          headers: {
            'x-ratelimit-remaining': '42',
            'x-ratelimit-reset': resetTime.toString(),
          },
        ),
      );
      final api = GitHubApi(client: client);
      await api.getRepository('o', 'r');

      expect(api.rateLimitRemaining, 42);
      expect(api.rateLimitReset, isNotNull);
    });
  });

  group('Error types', () {
    test('NotFoundError toString', () {
      const error = NotFoundError('/repos/x/y');
      expect(error.toString(), 'Not found: /repos/x/y');
    });

    test('RateLimitError toString without reset time', () {
      const error = RateLimitError(null);
      expect(error.toString(), 'Rate limit exceeded');
    });

    test('RateLimitError toString with reset time', () {
      final time = DateTime(2024, 1, 15, 12, 30);
      final error = RateLimitError(time);
      expect(error.toString(), contains('Rate limit exceeded'));
      expect(error.toString(), contains('2024'));
    });

    test('ApiError toString', () {
      const error = ApiError('Server error', 500);
      expect(error.toString(), 'Server error (status: 500)');
    });

    test('ParseError toString', () {
      const error = ParseError('Invalid JSON');
      expect(error.toString(), 'Parse error: Invalid JSON');
    });
  });
}

const _repoJson = {
  'id': 1,
  'name': 'flutter',
  'full_name': 'flutter/flutter',
  'owner': {
    'login': 'flutter',
    'id': 1,
    'avatar_url': 'https://example.com/avatar.png',
    'type': 'Organization',
  },
  'description': 'Flutter SDK',
  'private': false,
  'html_url': 'https://github.com/flutter/flutter',
  'language': 'Dart',
  'stargazers_count': 150000,
  'forks_count': 25000,
  'watchers_count': 150000,
  'open_issues_count': 10000,
  'default_branch': 'master',
  'created_at': '2015-03-06T22:54:58Z',
  'updated_at': '2024-01-01T00:00:00Z',
  'topics': <String>['dart', 'flutter'],
};

const _userJson = {
  'login': 'octocat',
  'id': 1,
  'avatar_url': 'https://example.com/octocat.png',
  'html_url': 'https://github.com/octocat',
  'name': 'The Octocat',
  'company': 'GitHub',
  'blog': 'https://blog.example.com',
  'location': 'San Francisco',
  'email': 'octocat@github.com',
  'bio': 'GitHub mascot',
  'public_repos': 50,
  'public_gists': 10,
  'followers': 5000,
  'following': 100,
  'created_at': '2008-01-01T00:00:00Z',
};

const _issueJson = {
  'id': 100,
  'number': 42,
  'title': 'Bug report',
  'state': 'open',
  'user': {
    'login': 'reporter',
    'id': 999,
    'avatar_url': '',
    'html_url': '',
    'created_at': '2020-01-01T00:00:00Z',
  },
  'labels': <Map<String, dynamic>>[],
  'body': 'Issue body',
  'comments': 5,
  'created_at': '2024-01-01T00:00:00Z',
  'html_url': 'https://github.com/owner/repo/issues/42',
};

const _commitJson = {
  'sha': 'abc123',
  'commit': {
    'message': 'Fix bug',
    'author': {
      'name': 'John',
      'email': 'john@example.com',
      'date': '2024-01-15T10:30:00Z',
    },
    'committer': {
      'name': 'Jane',
      'email': 'jane@example.com',
      'date': '2024-01-15T11:00:00Z',
    },
  },
  'html_url': 'https://github.com/owner/repo/commit/abc123',
};

const _contentJson = {
  'name': 'README.md',
  'path': 'README.md',
  'sha': 'xyz789',
  'size': 1024,
  'type': 'file',
  'download_url': 'https://raw.githubusercontent.com/o/r/main/README.md',
  'html_url': 'https://github.com/o/r/blob/main/README.md',
};

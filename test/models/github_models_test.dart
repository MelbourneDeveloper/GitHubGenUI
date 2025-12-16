import 'package:flutter_test/flutter_test.dart';
import 'package:github_genui/models/github_models.dart';

void main() {
  group('Repository parsing', () {
    test('parses complete repository JSON', () {
      final json = <String, dynamic>{
        'id': 123,
        'name': 'flutter',
        'full_name': 'flutter/flutter',
        'owner': {
          'login': 'flutter',
          'id': 456,
          'avatar_url': 'https://example.com/avatar.png',
          'type': 'Organization',
        },
        'description': 'Flutter SDK',
        'private': false,
        'html_url': 'https://github.com/flutter/flutter',
        'language': 'Dart',
        'stargazers_count': 150000,
        'forks_count': 25000,
        'watchers_count': 3000,
        'open_issues_count': 1000,
        'default_branch': 'main',
        'created_at': '2020-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
        'topics': ['dart', 'flutter', 'mobile'],
      };

      final repo = json.toRepository();

      expect(repo.id, 123);
      expect(repo.name, 'flutter');
      expect(repo.fullName, 'flutter/flutter');
      expect(repo.owner.login, 'flutter');
      expect(repo.owner.id, 456);
      expect(repo.owner.avatarUrl, 'https://example.com/avatar.png');
      expect(repo.owner.type, 'Organization');
      expect(repo.description, 'Flutter SDK');
      expect(repo.private, false);
      expect(repo.htmlUrl, 'https://github.com/flutter/flutter');
      expect(repo.language, 'Dart');
      expect(repo.stargazersCount, 150000);
      expect(repo.forksCount, 25000);
      expect(repo.watchersCount, 3000);
      expect(repo.openIssuesCount, 1000);
      expect(repo.defaultBranch, 'main');
      expect(repo.topics, ['dart', 'flutter', 'mobile']);
    });

    test('handles missing optional fields', () {
      final json = <String, dynamic>{
        'id': 1,
        'name': 'test',
        'full_name': 'user/test',
        'owner': <String, dynamic>{},
        'private': false,
        'html_url': '',
        'stargazers_count': 0,
        'forks_count': 0,
        'watchers_count': 0,
        'open_issues_count': 0,
        'created_at': '2020-01-01T00:00:00Z',
        'updated_at': '2020-01-01T00:00:00Z',
      };

      final repo = json.toRepository();

      expect(repo.description, isNull);
      expect(repo.language, isNull);
      expect(repo.defaultBranch, isNull);
      expect(repo.topics, isEmpty);
    });

    test('handles empty JSON gracefully', () {
      final json = <String, dynamic>{};
      final repo = json.toRepository();

      expect(repo.id, 0);
      expect(repo.name, '');
      expect(repo.fullName, '');
      expect(repo.owner.login, '');
    });
  });

  group('User parsing', () {
    test('parses complete user JSON', () {
      final json = <String, dynamic>{
        'login': 'octocat',
        'id': 789,
        'avatar_url': 'https://example.com/octocat.png',
        'html_url': 'https://github.com/octocat',
        'name': 'The Octocat',
        'company': 'GitHub',
        'blog': 'https://blog.example.com',
        'location': 'San Francisco',
        'email': 'octocat@github.com',
        'bio': 'I am the GitHub mascot',
        'public_repos': 50,
        'public_gists': 10,
        'followers': 5000,
        'following': 100,
        'created_at': '2008-01-01T00:00:00Z',
      };

      final user = json.toUser();

      expect(user.login, 'octocat');
      expect(user.id, 789);
      expect(user.avatarUrl, 'https://example.com/octocat.png');
      expect(user.htmlUrl, 'https://github.com/octocat');
      expect(user.name, 'The Octocat');
      expect(user.company, 'GitHub');
      expect(user.blog, 'https://blog.example.com');
      expect(user.location, 'San Francisco');
      expect(user.email, 'octocat@github.com');
      expect(user.bio, 'I am the GitHub mascot');
      expect(user.publicRepos, 50);
      expect(user.publicGists, 10);
      expect(user.followers, 5000);
      expect(user.following, 100);
    });

    test('handles missing optional fields', () {
      final json = <String, dynamic>{
        'login': 'user',
        'id': 1,
        'avatar_url': '',
        'html_url': '',
        'created_at': '2020-01-01T00:00:00Z',
      };

      final user = json.toUser();

      expect(user.name, isNull);
      expect(user.company, isNull);
      expect(user.blog, isNull);
      expect(user.location, isNull);
      expect(user.email, isNull);
      expect(user.bio, isNull);
      expect(user.publicRepos, 0);
      expect(user.publicGists, 0);
      expect(user.followers, 0);
      expect(user.following, 0);
    });
  });

  group('Issue parsing', () {
    test('parses complete issue JSON', () {
      final json = <String, dynamic>{
        'id': 100,
        'number': 42,
        'title': 'Bug: Something is broken',
        'state': 'open',
        'user': {
          'login': 'reporter',
          'id': 999,
          'avatar_url': '',
          'html_url': '',
          'created_at': '2020-01-01T00:00:00Z',
        },
        'labels': [
          {
            'id': 1,
            'name': 'bug',
            'color': 'd73a4a',
            'description': 'Bug label',
          },
          {'id': 2, 'name': 'priority', 'color': 'ff0000'},
        ],
        'body': 'This is the issue body',
        'comments': 5,
        'created_at': '2024-01-01T00:00:00Z',
        'closed_at': '2024-01-02T00:00:00Z',
        'html_url': 'https://github.com/owner/repo/issues/42',
      };

      final issue = json.toIssue();

      expect(issue.id, 100);
      expect(issue.number, 42);
      expect(issue.title, 'Bug: Something is broken');
      expect(issue.state, 'open');
      expect(issue.user.login, 'reporter');
      expect(issue.labels.length, 2);
      expect(issue.labels[0].name, 'bug');
      expect(issue.labels[0].color, 'd73a4a');
      expect(issue.labels[0].description, 'Bug label');
      expect(issue.labels[1].name, 'priority');
      expect(issue.labels[1].description, isNull);
      expect(issue.body, 'This is the issue body');
      expect(issue.comments, 5);
      expect(issue.htmlUrl, 'https://github.com/owner/repo/issues/42');
      expect(issue.isPullRequest, false);
    });

    test('detects pull request', () {
      final json = <String, dynamic>{
        'id': 1,
        'number': 1,
        'title': 'PR',
        'state': 'open',
        'user': {
          'login': 'user',
          'id': 1,
          'avatar_url': '',
          'html_url': '',
          'created_at': '2020-01-01T00:00:00Z',
        },
        'labels': <Map<String, dynamic>>[],
        'comments': 0,
        'created_at': '2020-01-01T00:00:00Z',
        'html_url': '',
        'pull_request': {'url': 'https://api.github.com/...'},
      };

      final issue = json.toIssue();
      expect(issue.isPullRequest, true);
    });

    test('handles empty labels list', () {
      final json = <String, dynamic>{
        'id': 1,
        'number': 1,
        'title': 'Test',
        'state': 'open',
        'user': {
          'login': 'user',
          'id': 1,
          'avatar_url': '',
          'html_url': '',
          'created_at': '2020-01-01T00:00:00Z',
        },
        'labels': <Map<String, dynamic>>[],
        'comments': 0,
        'created_at': '2020-01-01T00:00:00Z',
        'html_url': '',
      };

      final issue = json.toIssue();
      expect(issue.labels, isEmpty);
      expect(issue.closedAt, isNull);
      expect(issue.body, isNull);
    });
  });

  group('Commit parsing', () {
    test('parses complete commit JSON', () {
      final json = <String, dynamic>{
        'sha': 'abc123def456',
        'commit': {
          'message': 'Fix bug in widget',
          'author': {
            'name': 'John Doe',
            'email': 'john@example.com',
            'date': '2024-01-15T10:30:00Z',
          },
          'committer': {
            'name': 'Jane Doe',
            'email': 'jane@example.com',
            'date': '2024-01-15T11:00:00Z',
          },
        },
        'html_url': 'https://github.com/owner/repo/commit/abc123',
      };

      final commit = json.toCommit();

      expect(commit.sha, 'abc123def456');
      expect(commit.message, 'Fix bug in widget');
      expect(commit.author.name, 'John Doe');
      expect(commit.author.email, 'john@example.com');
      expect(commit.committer.name, 'Jane Doe');
      expect(commit.committer.email, 'jane@example.com');
      expect(commit.htmlUrl, 'https://github.com/owner/repo/commit/abc123');
    });

    test('handles empty commit data', () {
      final json = <String, dynamic>{};
      final commit = json.toCommit();

      expect(commit.sha, '');
      expect(commit.message, '');
      expect(commit.author.name, '');
      expect(commit.committer.name, '');
    });
  });

  group('RepoContent parsing', () {
    test('parses file content JSON', () {
      final json = <String, dynamic>{
        'name': 'README.md',
        'path': 'README.md',
        'sha': 'xyz789',
        'size': 1024,
        'type': 'file',
        'download_url': 'https://raw.githubusercontent.com/.../README.md',
        'html_url': 'https://github.com/owner/repo/blob/main/README.md',
      };

      final content = json.toRepoContent();

      expect(content.name, 'README.md');
      expect(content.path, 'README.md');
      expect(content.sha, 'xyz789');
      expect(content.size, 1024);
      expect(content.type, 'file');
      expect(content.downloadUrl, isNotNull);
      expect(content.htmlUrl, contains('github.com'));
    });

    test('parses directory content JSON', () {
      final json = <String, dynamic>{
        'name': 'src',
        'path': 'lib/src',
        'sha': 'dir123',
        'size': 0,
        'type': 'dir',
        'html_url': 'https://github.com/owner/repo/tree/main/lib/src',
      };

      final content = json.toRepoContent();

      expect(content.name, 'src');
      expect(content.path, 'lib/src');
      expect(content.type, 'dir');
      expect(content.downloadUrl, isNull);
    });
  });
}

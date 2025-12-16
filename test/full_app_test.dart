// Full-app widget tests that also run as integration tests.
// Run with: flutter test (widget tests)
// Run with: flutter test integration_test/ (integration tests on device)
//
// See: https://www.nimblesite.co/blog/flutter_full_app_widget_testing/
// See: https://www.christianfindlay.com/blog/flutter-integration-tests

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';
import 'package:genui/test/fake_content_generator.dart';
import 'package:github_genui/catalog/catalog_helpers.dart';
import 'package:github_genui/screens/chat_screen.dart';
import 'package:github_genui/services/github_api.dart';
import 'package:github_genui/theme/github_theme.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nadz/nadz.dart';

/// Main test function - can be called from integration_test/app_test.dart
void runFullAppTests() {
  testWidgets(
    'Full app renders with welcome message and all UI elements',
    fullAppRendersTest,
  );

  testWidgets(
    'User can type message and send it, sees loading indicator',
    userCanSendMessageTest,
  );

  testWidgets('Empty messages are not sent', emptyMessageNotSentTest);

  testWidgets(
    'GitHub API returns repository data correctly',
    githubApiGetRepositoryTest,
  );

  testWidgets('GitHub API handles 404 errors', githubApiNotFoundTest);

  testWidgets('GitHub API handles rate limits', githubApiRateLimitTest);

  testWidgets('GitHub API search returns results', githubApiSearchTest);

  testWidgets(
    'Multiple user messages appear in chat list',
    userMessageAppearsInChatTest,
  );

  testWidgets(
    'Send button is disabled while loading',
    sendButtonDisabledWhileLoadingTest,
  );

  // Catalog widget tests - render widgets through GenUI surfaces
  testWidgets(
    'RepositoryCard widget renders via GenUI surface',
    repositoryCardSurfaceTest,
  );

  testWidgets('UserCard widget renders via GenUI surface', userCardSurfaceTest);

  testWidgets(
    'IssueItem widget renders via GenUI surface',
    issueItemSurfaceTest,
  );

  testWidgets(
    'LabelBadge widget renders via GenUI surface',
    labelBadgeSurfaceTest,
  );

  testWidgets('StatsRow widget renders via GenUI surface', statsRowSurfaceTest);

  testWidgets('RepoList widget renders via GenUI surface', repoListSurfaceTest);

  testWidgets('UserList widget renders via GenUI surface', userListSurfaceTest);

  // GitHub API coverage tests
  testWidgets('GitHub API getUser returns user data', githubApiGetUserTest);
  testWidgets(
    'GitHub API getUserRepositories returns repos',
    githubApiGetUserReposTest,
  );
  testWidgets('GitHub API getIssue returns issue', githubApiGetIssueTest);
  testWidgets(
    'GitHub API getRepositoryIssues returns issues',
    githubApiGetRepoIssuesTest,
  );
  testWidgets('GitHub API searchUsers returns users', githubApiSearchUsersTest);
  testWidgets(
    'GitHub API searchIssues returns issues',
    githubApiSearchIssuesTest,
  );
  testWidgets(
    'GitHub API getRepositoryCommits returns commits',
    githubApiGetCommitsTest,
  );
  testWidgets(
    'GitHub API getRepositoryContents returns contents',
    githubApiGetContentsTest,
  );
  testWidgets(
    'GitHub API getFileContent returns file',
    githubApiGetFileContentTest,
  );
  testWidgets('GitHub API getReadme returns readme', githubApiGetReadmeTest);
  testWidgets('GitHub API handles generic error', githubApiServerErrorTest);
  testWidgets('GitHub API contents with path', githubApiContentsPathTest);
  testWidgets(
    'GitHub API contents single file',
    githubApiContentsSingleFileTest,
  );
  testWidgets(
    'GitHub API updates rate limit headers',
    githubApiRateLimitHeadersTest,
  );

  // Catalog helpers tests
  testWidgets('formatCount formats numbers correctly', formatCountTest);
  testWidgets('getLanguageColor returns correct colors', getLanguageColorTest);
  testWidgets('parseColor parses hex colors', parseColorTest);
  testWidgets('getIcon returns correct icons', getIconTest);
  testWidgets('catalog helper extractors work', catalogExtractorsTest);

  // Theme tests
  testWidgets('githubDarkTheme creates valid theme', themeTest);
  testWidgets('bubble decorations are valid', bubbleDecorationsTest);
}

// ============ TEST IMPLEMENTATIONS ============

Future<void> fullAppRendersTest(WidgetTester tester) async {
  await tester.pumpWidget(_buildTestApp(FakeContentGenerator()));
  await tester.pump(const Duration(milliseconds: 500));

  // App title in AppBar
  expect(find.text('GitHub'), findsOneWidget);

  // Welcome message
  expect(find.textContaining('Welcome to GitHub'), findsOneWidget);

  // Input field
  expect(find.byType(TextField), findsOneWidget);

  // Send button
  expect(find.byIcon(Icons.send), findsOneWidget);

  // Code icon in AppBar
  expect(find.byIcon(Icons.code), findsWidgets);
}

Future<void> userCanSendMessageTest(WidgetTester tester) async {
  final completer = Completer<void>();
  final generator = FakeContentGenerator()..sendRequestCompleter = completer;

  await tester.pumpWidget(_buildTestApp(generator));
  await tester.pump(const Duration(milliseconds: 500));

  // Enter text
  await tester.enterText(find.byType(TextField), 'Show me Flutter repository');
  await tester.pump();

  // Tap send
  await tester.tap(find.byIcon(Icons.send));
  await tester.pump();

  // User message appears
  expect(find.text('Show me Flutter repository'), findsOneWidget);

  // Loading indicator appears (CircularProgressIndicator in pulsing avatar)
  expect(find.byType(CircularProgressIndicator), findsOneWidget);

  // Complete the request and emit a text response to trigger callback
  generator.addTextResponse('Here is the Flutter repository info.');
  completer.complete();
  await tester.pump(const Duration(milliseconds: 100));

  // Loading indicator gone
  expect(find.byType(CircularProgressIndicator), findsNothing);
  // Response visible
  expect(find.text('Here is the Flutter repository info.'), findsOneWidget);
}

Future<void> emptyMessageNotSentTest(WidgetTester tester) async {
  final generator = FakeContentGenerator();

  await tester.pumpWidget(_buildTestApp(generator));
  await tester.pump(const Duration(milliseconds: 500));

  // Try to send empty message
  await tester.tap(find.byIcon(Icons.send));
  await tester.pump();

  // sendRequest was never called
  expect(generator.sendRequestCallCount, 0);

  // No loading indicator
  expect(find.byType(CircularProgressIndicator), findsNothing);
}

Future<void> githubApiGetRepositoryTest(WidgetTester tester) async {
  final mockClient = MockClient((request) async {
    expect(
      request.url.toString(),
      'https://api.github.com/repos/flutter/flutter',
    );
    return http.Response(
      jsonEncode(_flutterRepoJson),
      200,
      headers: {'x-ratelimit-remaining': '59'},
    );
  });

  final api = GitHubApi(client: mockClient);
  final result = await api.getRepository('flutter', 'flutter');

  expect(result, isA<Success<Repository, GitHubError>>());
  final success = result as Success<Repository, GitHubError>;
  expect(success.value.name, 'flutter');
  expect(success.value.fullName, 'flutter/flutter');
  expect(success.value.stargazersCount, 150000);
  expect(success.value.language, 'Dart');
}

Future<void> githubApiNotFoundTest(WidgetTester tester) async {
  final mockClient = MockClient(
    (request) async => http.Response('Not found', 404),
  );

  final api = GitHubApi(client: mockClient);
  final result = await api.getRepository('nonexistent', 'repo');

  expect(result, isA<Error<Repository, GitHubError>>());
  final error = result as Error<Repository, GitHubError>;
  expect(error.error, isA<NotFoundError>());
}

Future<void> githubApiRateLimitTest(WidgetTester tester) async {
  final mockClient = MockClient(
    (request) async => http.Response('Rate limit exceeded', 403),
  );

  final api = GitHubApi(client: mockClient);
  final result = await api.getRepository('flutter', 'flutter');

  expect(result, isA<Error<Repository, GitHubError>>());
  final error = result as Error<Repository, GitHubError>;
  expect(error.error, isA<RateLimitError>());
}

Future<void> githubApiSearchTest(WidgetTester tester) async {
  final mockClient = MockClient((request) async {
    expect(request.url.path, '/search/repositories');
    return http.Response(
      jsonEncode({
        'total_count': 1,
        'incomplete_results': false,
        'items': [_flutterRepoJson],
      }),
      200,
    );
  });

  final api = GitHubApi(client: mockClient);
  final result = await api.searchRepositories('flutter');

  expect(result, isA<Success<SearchResults<Repository>, GitHubError>>());
  final success = result as Success<SearchResults<Repository>, GitHubError>;
  expect(success.value.totalCount, 1);
  expect(success.value.items.length, 1);
  expect(success.value.items.first.name, 'flutter');
}

Future<void> userMessageAppearsInChatTest(WidgetTester tester) async {
  final generator = FakeContentGenerator();

  await tester.pumpWidget(_buildTestApp(generator));
  // Timed pump - pumpAndSettle hangs with animations in integration tests
  await tester.pump(const Duration(milliseconds: 500));

  // First message
  await tester.enterText(find.byType(TextField), 'Hello');
  await tester.tap(find.byIcon(Icons.send));
  await tester.pump();
  expect(find.text('Hello'), findsOneWidget);

  // Emit response to clear loading
  generator.addTextResponse('Response 1');
  await tester.pump(const Duration(milliseconds: 500));

  // Second message
  await tester.enterText(find.byType(TextField), 'Search for Dart');
  await tester.tap(find.byIcon(Icons.send));
  await tester.pump();

  // Both user messages visible
  expect(find.text('Hello'), findsOneWidget);
  expect(find.text('Search for Dart'), findsOneWidget);
}

Future<void> sendButtonDisabledWhileLoadingTest(WidgetTester tester) async {
  final completer = Completer<void>();
  final generator = FakeContentGenerator()..sendRequestCompleter = completer;

  await tester.pumpWidget(_buildTestApp(generator));
  // Timed pump - pumpAndSettle hangs with animations in integration tests
  await tester.pump(const Duration(milliseconds: 500));

  // Send first message
  await tester.enterText(find.byType(TextField), 'First message');
  await tester.tap(find.byIcon(Icons.send));
  await tester.pump();

  // First message should appear in chat
  expect(find.text('First message'), findsOneWidget);

  // Only one request made despite multiple taps
  await tester.tap(find.byIcon(Icons.send));
  await tester.pump();
  expect(generator.sendRequestCallCount, 1);

  // Complete and emit response
  generator.addTextResponse('Response');
  completer.complete();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> repositoryCardSurfaceTest(WidgetTester tester) async {
  final generator = FakeContentGenerator();

  await tester.pumpWidget(_buildTestApp(generator));
  await tester.pump(const Duration(milliseconds: 500));

  // Send a message to trigger the chat flow
  await tester.enterText(find.byType(TextField), 'Show me Flutter');
  await tester.tap(find.byIcon(Icons.send));
  await tester.pump();

  // Emit a surface with RepositoryCard
  generator
    ..addA2uiMessage(
      const SurfaceUpdate(
        surfaceId: 'test-surface-1',
        components: [
          Component(
            id: 'root',
            componentProperties: {
              'RepositoryCard': {
                'name': 'flutter',
                'fullName': 'flutter/flutter',
                'description': 'Flutter SDK for building apps',
                'language': 'Dart',
                'stars': 150000,
                'forks': 25000,
                'url': 'https://github.com/flutter/flutter',
                'topics': ['dart', 'flutter', 'mobile'],
              },
            },
          ),
        ],
      ),
    )
    ..addA2uiMessage(
      const BeginRendering(surfaceId: 'test-surface-1', root: 'root'),
    );
  await tester.pump(const Duration(milliseconds: 100));

  // Verify the card content is visible
  expect(find.text('flutter/flutter'), findsOneWidget);
  expect(find.text('Flutter SDK for building apps'), findsOneWidget);
  expect(find.text('Dart'), findsOneWidget);
}

Future<void> userCardSurfaceTest(WidgetTester tester) async {
  final generator = FakeContentGenerator();

  await tester.pumpWidget(_buildTestApp(generator));
  await tester.pump(const Duration(milliseconds: 500));

  await tester.enterText(find.byType(TextField), 'Show user');
  await tester.tap(find.byIcon(Icons.send));
  await tester.pump();

  generator
    ..addA2uiMessage(
      const SurfaceUpdate(
        surfaceId: 'test-surface-2',
        components: [
          Component(
            id: 'root',
            componentProperties: {
              'UserCard': {
                'login': 'octocat',
                'name': 'The Octocat',
                'bio': 'GitHub mascot',
                'followers': 5000,
                'following': 100,
                'publicRepos': 50,
                'url': 'https://github.com/octocat',
              },
            },
          ),
        ],
      ),
    )
    ..addA2uiMessage(
      const BeginRendering(surfaceId: 'test-surface-2', root: 'root'),
    );
  await tester.pump(const Duration(milliseconds: 100));

  expect(find.text('The Octocat'), findsOneWidget);
  expect(find.text('octocat'), findsOneWidget);
  expect(find.text('GitHub mascot'), findsOneWidget);
}

Future<void> issueItemSurfaceTest(WidgetTester tester) async {
  final generator = FakeContentGenerator();

  await tester.pumpWidget(_buildTestApp(generator));
  await tester.pump(const Duration(milliseconds: 500));

  await tester.enterText(find.byType(TextField), 'Show issue');
  await tester.tap(find.byIcon(Icons.send));
  await tester.pump();

  generator
    ..addA2uiMessage(
      const SurfaceUpdate(
        surfaceId: 'test-surface-3',
        components: [
          Component(
            id: 'root',
            componentProperties: {
              'IssueItem': {
                'number': 42,
                'title': 'Bug: Something is broken',
                'state': 'open',
                'author': 'testuser',
                'comments': 5,
                'labels': [
                  {'name': 'bug', 'color': 'd73a4a'},
                ],
                'isPullRequest': false,
                'url': 'https://github.com/owner/repo/issues/42',
              },
            },
          ),
        ],
      ),
    )
    ..addA2uiMessage(
      const BeginRendering(surfaceId: 'test-surface-3', root: 'root'),
    );
  await tester.pump(const Duration(milliseconds: 100));

  expect(find.textContaining('Bug: Something is broken'), findsOneWidget);
  expect(find.textContaining('#42'), findsOneWidget);
}

Future<void> labelBadgeSurfaceTest(WidgetTester tester) async {
  final generator = FakeContentGenerator();

  await tester.pumpWidget(_buildTestApp(generator));
  await tester.pump(const Duration(milliseconds: 500));

  await tester.enterText(find.byType(TextField), 'Show label');
  await tester.tap(find.byIcon(Icons.send));
  await tester.pump();

  generator
    ..addA2uiMessage(
      const SurfaceUpdate(
        surfaceId: 'test-surface-4',
        components: [
          Component(
            id: 'root',
            componentProperties: {
              'LabelBadge': {'name': 'enhancement', 'color': 'a2eeef'},
            },
          ),
        ],
      ),
    )
    ..addA2uiMessage(
      const BeginRendering(surfaceId: 'test-surface-4', root: 'root'),
    );
  await tester.pump(const Duration(milliseconds: 100));

  expect(find.text('enhancement'), findsOneWidget);
}

Future<void> statsRowSurfaceTest(WidgetTester tester) async {
  final generator = FakeContentGenerator();

  await tester.pumpWidget(_buildTestApp(generator));
  await tester.pump(const Duration(milliseconds: 500));

  await tester.enterText(find.byType(TextField), 'Show stats');
  await tester.tap(find.byIcon(Icons.send));
  await tester.pump();

  generator
    ..addA2uiMessage(
      const SurfaceUpdate(
        surfaceId: 'test-surface-5',
        components: [
          Component(
            id: 'root',
            componentProperties: {
              'StatsRow': {
                'stats': [
                  {'label': 'Stars', 'value': '150k', 'icon': 'star'},
                  {'label': 'Forks', 'value': '25k', 'icon': 'fork'},
                ],
              },
            },
          ),
        ],
      ),
    )
    ..addA2uiMessage(
      const BeginRendering(surfaceId: 'test-surface-5', root: 'root'),
    );
  await tester.pump(const Duration(milliseconds: 100));

  expect(find.text('Stars'), findsOneWidget);
  expect(find.text('150k'), findsOneWidget);
  expect(find.text('Forks'), findsOneWidget);
}

Future<void> repoListSurfaceTest(WidgetTester tester) async {
  final generator = FakeContentGenerator();

  await tester.pumpWidget(_buildTestApp(generator));
  await tester.pump(const Duration(milliseconds: 500));

  await tester.enterText(find.byType(TextField), 'Show repos');
  await tester.tap(find.byIcon(Icons.send));
  await tester.pump();

  generator
    ..addA2uiMessage(
      const SurfaceUpdate(
        surfaceId: 'test-surface-6',
        components: [
          Component(
            id: 'root',
            componentProperties: {
              'RepoList': {
                'title': 'Trending Repositories',
                'repos': [
                  {
                    'name': 'flutter',
                    'fullName': 'flutter/flutter',
                    'description': 'Flutter SDK',
                    'language': 'Dart',
                    'stars': 150000,
                    'forks': 25000,
                  },
                  {
                    'name': 'react',
                    'fullName': 'facebook/react',
                    'description': 'React JS library',
                    'language': 'JavaScript',
                    'stars': 200000,
                    'forks': 40000,
                  },
                ],
              },
            },
          ),
        ],
      ),
    )
    ..addA2uiMessage(
      const BeginRendering(surfaceId: 'test-surface-6', root: 'root'),
    );
  await tester.pump(const Duration(milliseconds: 100));

  expect(find.text('Trending Repositories'), findsOneWidget);
  expect(find.text('flutter/flutter'), findsOneWidget);
  expect(find.text('facebook/react'), findsOneWidget);
}

Future<void> userListSurfaceTest(WidgetTester tester) async {
  final generator = FakeContentGenerator();

  await tester.pumpWidget(_buildTestApp(generator));
  await tester.pump(const Duration(milliseconds: 500));

  await tester.enterText(find.byType(TextField), 'Show users');
  await tester.tap(find.byIcon(Icons.send));
  await tester.pump();

  generator
    ..addA2uiMessage(
      const SurfaceUpdate(
        surfaceId: 'test-surface-7',
        components: [
          Component(
            id: 'root',
            componentProperties: {
              'UserList': {
                'title': 'Top Contributors',
                'users': [
                  {'login': 'user1', 'name': 'User One', 'bio': 'Developer'},
                  {'login': 'user2', 'name': 'User Two', 'bio': 'Engineer'},
                ],
              },
            },
          ),
        ],
      ),
    )
    ..addA2uiMessage(
      const BeginRendering(surfaceId: 'test-surface-7', root: 'root'),
    );
  await tester.pump(const Duration(milliseconds: 100));

  expect(find.text('Top Contributors'), findsOneWidget);
  expect(find.text('User One'), findsOneWidget);
  expect(find.text('User Two'), findsOneWidget);
}

// ============ MORE API TESTS ============

Future<void> githubApiGetUserTest(WidgetTester tester) async {
  final mockClient = MockClient((request) async {
    expect(request.url.path, '/users/octocat');
    return http.Response(jsonEncode(_userJson), 200);
  });
  final api = GitHubApi(client: mockClient);
  final result = await api.getUser('octocat');
  expect(result, isA<Success<User, GitHubError>>());
  final success = result as Success<User, GitHubError>;
  expect(success.value.login, 'octocat');
}

Future<void> githubApiSearchUsersTest(WidgetTester tester) async {
  final mockClient = MockClient(
    (request) async => http.Response(
      jsonEncode({
        'total_count': 1,
        'incomplete_results': false,
        'items': [_userJson],
      }),
      200,
    ),
  );
  final api = GitHubApi(client: mockClient);
  final result = await api.searchUsers('octocat');
  expect(result, isA<Success<SearchResults<User>, GitHubError>>());
}

Future<void> githubApiGetUserReposTest(WidgetTester tester) async {
  final mockClient = MockClient(
    (request) async => http.Response(jsonEncode([_flutterRepoJson]), 200),
  );
  final api = GitHubApi(client: mockClient);
  final result = await api.getUserRepositories('octocat');
  expect(result, isA<Success<List<Repository>, GitHubError>>());
  final success = result as Success<List<Repository>, GitHubError>;
  expect(success.value.length, 1);
}

Future<void> githubApiGetIssueTest(WidgetTester tester) async {
  final mockClient = MockClient(
    (request) async => http.Response(jsonEncode(_issueJson), 200),
  );
  final api = GitHubApi(client: mockClient);
  final result = await api.getIssue('flutter', 'flutter', 1);
  expect(result, isA<Success<Issue, GitHubError>>());
  final success = result as Success<Issue, GitHubError>;
  expect(success.value.number, 1);
}

Future<void> githubApiGetRepoIssuesTest(WidgetTester tester) async {
  final mockClient = MockClient(
    (request) async => http.Response(jsonEncode([_issueJson]), 200),
  );
  final api = GitHubApi(client: mockClient);
  final result = await api.getRepositoryIssues('flutter', 'flutter');
  expect(result, isA<Success<List<Issue>, GitHubError>>());
}

Future<void> githubApiSearchIssuesTest(WidgetTester tester) async {
  final mockClient = MockClient(
    (request) async => http.Response(
      jsonEncode({
        'total_count': 1,
        'incomplete_results': false,
        'items': [_issueJson],
      }),
      200,
    ),
  );
  final api = GitHubApi(client: mockClient);
  final result = await api.searchIssues('bug');
  expect(result, isA<Success<SearchResults<Issue>, GitHubError>>());
}

Future<void> githubApiGetCommitsTest(WidgetTester tester) async {
  final mockClient = MockClient(
    (request) async => http.Response(jsonEncode([_commitJson]), 200),
  );
  final api = GitHubApi(client: mockClient);
  final result = await api.getRepositoryCommits('flutter', 'flutter');
  expect(result, isA<Success<List<Commit>, GitHubError>>());
}

Future<void> githubApiGetContentsTest(WidgetTester tester) async {
  final mockClient = MockClient(
    (request) async => http.Response(jsonEncode([_contentJson]), 200),
  );
  final api = GitHubApi(client: mockClient);
  final result = await api.getRepositoryContents('flutter', 'flutter');
  expect(result, isA<Success<List<RepoContent>, GitHubError>>());
}

Future<void> githubApiGetReadmeTest(WidgetTester tester) async {
  final mockClient = MockClient(
    (request) async => http.Response(
      jsonEncode({
        'content': base64.encode(utf8.encode('# Hello')),
        'encoding': 'base64',
      }),
      200,
    ),
  );
  final api = GitHubApi(client: mockClient);
  final result = await api.getReadme('flutter', 'flutter');
  expect(result, isA<Success<String, GitHubError>>());
  expect((result as Success).value, '# Hello');
}

Future<void> githubApiGetFileContentTest(WidgetTester tester) async {
  final mockClient = MockClient(
    (request) async => http.Response(
      jsonEncode({
        'content': base64.encode(utf8.encode('file content')),
        'encoding': 'base64',
      }),
      200,
    ),
  );
  final api = GitHubApi(client: mockClient);
  final result = await api.getFileContent('flutter', 'flutter', 'README.md');
  expect(result, isA<Success<String, GitHubError>>());
}

Future<void> githubApiServerErrorTest(WidgetTester tester) async {
  final mockClient = MockClient(
    (request) async => http.Response('Error', 500),
  );
  final api = GitHubApi(client: mockClient);
  final result = await api.getRepository('a', 'b');
  expect(result, isA<Error<Repository, GitHubError>>());
  expect((result as Error).error, isA<ApiError>());
}

Future<void> githubApiContentsPathTest(WidgetTester tester) async {
  final mockClient = MockClient((request) async {
    expect(request.url.path, '/repos/a/b/contents/src');
    return http.Response(jsonEncode([_contentJson]), 200);
  });
  final api = GitHubApi(client: mockClient);
  await api.getRepositoryContents('a', 'b', path: 'src');
}

Future<void> githubApiContentsSingleFileTest(WidgetTester tester) async {
  final mockClient = MockClient(
    (request) async => http.Response(jsonEncode(_contentJson), 200),
  );
  final api = GitHubApi(client: mockClient);
  final result = await api.getRepositoryContents('a', 'b', path: 'file.txt');
  expect(result, isA<Success<List<RepoContent>, GitHubError>>());
  final success = result as Success<List<RepoContent>, GitHubError>;
  expect(success.value.length, 1);
}

Future<void> githubApiRateLimitHeadersTest(WidgetTester tester) async {
  final mockClient = MockClient(
    (request) async => http.Response(
      jsonEncode(_flutterRepoJson),
      200,
      headers: {
        'x-ratelimit-remaining': '42',
        'x-ratelimit-limit': '60',
        'x-ratelimit-reset': '1234567890',
      },
    ),
  );
  final api = GitHubApi(client: mockClient);
  await api.getRepository('flutter', 'flutter');
  expect(api.rateLimitRemaining, 42);
}

// ============ CATALOG HELPER TESTS ============

Future<void> formatCountTest(WidgetTester tester) async {
  expect(formatCount(0), '0');
  expect(formatCount(999), '999');
  expect(formatCount(1000), '1.0k');
  expect(formatCount(1500), '1.5k');
  expect(formatCount(10000), '10.0k');
  expect(formatCount(150000), '150.0k');
}

Future<void> getLanguageColorTest(WidgetTester tester) async {
  expect(getLanguageColor('Dart'), const Color(0xFF00B4AB));
  expect(getLanguageColor('JavaScript'), const Color(0xFFF1E05A));
  expect(getLanguageColor('TypeScript'), const Color(0xFF3178C6));
  expect(getLanguageColor('Python'), const Color(0xFF3572A5));
  expect(getLanguageColor('Java'), const Color(0xFFB07219));
  expect(getLanguageColor('Kotlin'), const Color(0xFFA97BFF));
  expect(getLanguageColor('Swift'), const Color(0xFFFFAC45));
  expect(getLanguageColor('Go'), const Color(0xFF00ADD8));
  expect(getLanguageColor('Rust'), const Color(0xFFDEA584));
  expect(getLanguageColor('C++'), const Color(0xFFF34B7D));
  expect(getLanguageColor('C'), const Color(0xFF555555));
  expect(getLanguageColor('C#'), const Color(0xFF178600));
  expect(getLanguageColor('Ruby'), const Color(0xFF701516));
  expect(getLanguageColor('PHP'), const Color(0xFF4F5D95));
  expect(getLanguageColor('HTML'), const Color(0xFFE34C26));
  expect(getLanguageColor('CSS'), const Color(0xFF563D7C));
  expect(getLanguageColor('Shell'), const Color(0xFF89E051));
  expect(getLanguageColor('Vue'), const Color(0xFF41B883));
  expect(getLanguageColor('Unknown'), GitHubColors.fgMuted);
}

Future<void> parseColorTest(WidgetTester tester) async {
  expect(parseColor('ff0000'), const Color(0xFFFF0000));
  expect(parseColor('00ff00'), const Color(0xFF00FF00));
  expect(parseColor('0000ff'), const Color(0xFF0000FF));
  expect(parseColor('d73a4a'), const Color(0xFFD73A4A));
  expect(parseColor('a2eeef'), const Color(0xFFA2EEEF));
  expect(parseColor(null), GitHubColors.fgMuted);
  expect(parseColor(''), GitHubColors.fgMuted);
  expect(parseColor('invalid'), GitHubColors.fgMuted);
}

Future<void> getIconTest(WidgetTester tester) async {
  expect(getIcon('star'), Icons.star_outline);
  expect(getIcon('fork'), Icons.call_split);
  expect(getIcon('eye'), Icons.visibility_outlined);
  expect(getIcon('issue'), Icons.circle_outlined);
  expect(getIcon('pr'), Icons.call_merge);
  expect(getIcon('commit'), Icons.commit);
  expect(getIcon('repo'), Icons.book_outlined);
  expect(getIcon('user'), Icons.person_outline);
  expect(getIcon('code'), Icons.code);
  expect(getIcon('branch'), Icons.account_tree_outlined);
  expect(getIcon('unknown'), Icons.help_outline);
}

Future<void> catalogExtractorsTest(WidgetTester tester) async {
  final data = <String, dynamic>{
    'name': 'test',
    'count': 42,
    'active': true,
    'items': ['a', 'b'],
    'nested': {'key': 'value'},
    'topics': ['dart', 'flutter'],
  };
  expect(str(data, 'name'), 'test');
  expect(str(data, 'missing'), '');
  expect(strOpt(data, 'name'), 'test');
  expect(strOpt(data, 'missing'), null);
  expect(integer(data, 'count'), 42);
  expect(integer(data, 'missing'), 0);
  expect(intOpt(data, 'count'), 42);
  expect(intOpt(data, 'missing'), null);
  expect(boolean(data, 'active'), true);
  expect(boolean(data, 'missing'), false);
  expect(listValue(data, 'items'), ['a', 'b']);
  expect(listValue(data, 'missing'), <dynamic>[]);
  expect(mapValue(data, 'nested'), {'key': 'value'});
  expect(mapValue(data, 'missing'), <String, dynamic>{});
  expect(topicsList(data, 'topics'), ['dart', 'flutter']);
}

// ============ THEME TESTS ============

Future<void> themeTest(WidgetTester tester) async {
  final theme = githubDarkTheme();
  expect(theme.brightness, Brightness.dark);
  expect(theme.scaffoldBackgroundColor, GitHubColors.canvasDefault);
  expect(theme.primaryColor, GitHubColors.accentEmphasis);
  expect(theme.colorScheme.surface, GitHubColors.canvasDefault);
  expect(theme.colorScheme.primary, GitHubColors.accentEmphasis);
  expect(theme.appBarTheme.backgroundColor, GitHubColors.canvasSubtle);
}

Future<void> bubbleDecorationsTest(WidgetTester tester) async {
  final userDecoration = userBubbleDecoration();
  expect(userDecoration.gradient, isNotNull);
  expect(userDecoration.borderRadius, isNotNull);
  expect(userDecoration.boxShadow, isNotNull);

  final assistantDecoration = assistantBubbleDecoration();
  expect(assistantDecoration.gradient, isNotNull);
  expect(assistantDecoration.borderRadius, isNotNull);
  expect(assistantDecoration.border, isNotNull);
}

// ============ HELPERS ============

Widget _buildTestApp(FakeContentGenerator generator) => MaterialApp(
  theme: githubDarkTheme(),
  home: ChatScreen(contentGeneratorFactory: (_) => generator),
);

const _flutterRepoJson = {
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
  'topics': ['dart', 'flutter', 'mobile'],
};

const _userJson = {
  'login': 'octocat',
  'id': 1,
  'avatar_url': 'https://example.com/avatar.png',
  'type': 'User',
  'name': 'The Octocat',
  'company': 'GitHub',
  'blog': 'https://github.blog',
  'location': 'San Francisco',
  'bio': 'GitHub mascot',
  'public_repos': 50,
  'public_gists': 10,
  'followers': 5000,
  'following': 100,
  'created_at': '2011-01-25T18:44:36Z',
  'updated_at': '2024-01-01T00:00:00Z',
};

const _issueJson = {
  'id': 1,
  'number': 1,
  'title': 'Test issue',
  'state': 'open',
  'user': {
    'login': 'octocat',
    'id': 1,
    'avatar_url': 'https://example.com/avatar.png',
    'type': 'User',
  },
  'labels': <Map<String, dynamic>>[],
  'body': 'Issue body',
  'comments': 0,
  'html_url': 'https://github.com/flutter/flutter/issues/1',
  'created_at': '2024-01-01T00:00:00Z',
  'updated_at': '2024-01-01T00:00:00Z',
};

const _commitJson = {
  'sha': 'abc123',
  'commit': {
    'message': 'Initial commit',
    'author': {
      'name': 'octocat',
      'email': 'octocat@github.com',
      'date': '2024-01-01T00:00:00Z',
    },
    'committer': {
      'name': 'octocat',
      'email': 'octocat@github.com',
      'date': '2024-01-01T00:00:00Z',
    },
  },
  'author': {
    'login': 'octocat',
    'id': 1,
    'avatar_url': 'https://example.com/avatar.png',
    'type': 'User',
  },
  'committer': {
    'login': 'octocat',
    'id': 1,
    'avatar_url': 'https://example.com/avatar.png',
    'type': 'User',
  },
  'html_url': 'https://github.com/flutter/flutter/commit/abc123',
};

const _contentJson = {
  'name': 'README.md',
  'path': 'README.md',
  'sha': 'abc123',
  'size': 100,
  'type': 'file',
  'html_url': 'https://github.com/flutter/flutter/blob/main/README.md',
  'download_url': 'https://raw.githubusercontent.com/flutter/flutter/main/README.md',
};

// ============ MAIN ============

void main() {
  runFullAppTests();
}

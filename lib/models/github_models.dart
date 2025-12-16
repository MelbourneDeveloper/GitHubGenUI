// GitHub API data models using typedef records

/// Repository owner (user or org).
typedef Owner = ({String login, int id, String avatarUrl, String type});

/// Repository model.
typedef Repository = ({
  int id,
  String name,
  String fullName,
  Owner owner,
  String? description,
  bool private,
  String htmlUrl,
  String? language,
  int stargazersCount,
  int forksCount,
  int watchersCount,
  int openIssuesCount,
  String? defaultBranch,
  DateTime createdAt,
  DateTime updatedAt,
  List<String> topics,
});

/// User model.
typedef User = ({
  String login,
  int id,
  String avatarUrl,
  String htmlUrl,
  String? name,
  String? company,
  String? blog,
  String? location,
  String? email,
  String? bio,
  int publicRepos,
  int publicGists,
  int followers,
  int following,
  DateTime createdAt,
});

/// Issue/PR label.
typedef Label = ({int id, String name, String? color, String? description});

/// Issue model.
typedef Issue = ({
  int id,
  int number,
  String title,
  String state,
  User user,
  List<Label> labels,
  String? body,
  int comments,
  DateTime createdAt,
  DateTime? closedAt,
  String htmlUrl,
  bool isPullRequest,
});

/// Commit author info.
typedef CommitAuthor = ({String name, String email, DateTime date});

/// Commit model.
typedef Commit = ({
  String sha,
  String message,
  CommitAuthor author,
  CommitAuthor committer,
  String htmlUrl,
});

/// Search results wrapper.
typedef SearchResults<T> = ({
  int totalCount,
  bool incompleteResults,
  List<T> items,
});

/// File/directory content.
typedef RepoContent = ({
  String name,
  String path,
  String sha,
  int size,
  String type,
  String? downloadUrl,
  String htmlUrl,
});

// Type-safe JSON extraction helpers using pattern matching

String _str(Map<String, dynamic> m, String k) => switch (m[k]) {
  final String s => s,
  _ => '',
};

String? _strOpt(Map<String, dynamic> m, String k) => switch (m[k]) {
  final String s => s,
  _ => null,
};

int _int(Map<String, dynamic> m, String k) => switch (m[k]) {
  final int i => i,
  _ => 0,
};

int? _intOpt(Map<String, dynamic> m, String k) => switch (m[k]) {
  final int i => i,
  _ => null,
};

bool _bool(Map<String, dynamic> m, String k) => switch (m[k]) {
  final bool b => b,
  _ => false,
};

Map<String, dynamic> _map(Map<String, dynamic> m, String k) => switch (m[k]) {
  final Map<String, dynamic> map => map,
  _ => {},
};

List<dynamic> _list(Map<String, dynamic> m, String k) => switch (m[k]) {
  final List<dynamic> list => list,
  _ => [],
};

DateTime _dateTime(Map<String, dynamic> m, String k) => switch (m[k]) {
  final String s => DateTime.parse(s),
  _ => DateTime(0),
};

DateTime? _dateTimeOpt(Map<String, dynamic> m, String k) => switch (m[k]) {
  final String s => DateTime.parse(s),
  _ => null,
};

/// Parsing helpers for GitHub API responses.
extension RepositoryParsing on Map<String, dynamic> {
  /// Parses a repository from JSON.
  Repository toRepository() {
    final ownerMap = _map(this, 'owner');
    final topicsRaw = _list(this, 'topics');
    return (
      id: _int(this, 'id'),
      name: _str(this, 'name'),
      fullName: _str(this, 'full_name'),
      owner: (
        login: _str(ownerMap, 'login'),
        id: _int(ownerMap, 'id'),
        avatarUrl: _str(ownerMap, 'avatar_url'),
        type: _str(ownerMap, 'type'),
      ),
      description: _strOpt(this, 'description'),
      private: _bool(this, 'private'),
      htmlUrl: _str(this, 'html_url'),
      language: _strOpt(this, 'language'),
      stargazersCount: _int(this, 'stargazers_count'),
      forksCount: _int(this, 'forks_count'),
      watchersCount: _int(this, 'watchers_count'),
      openIssuesCount: _int(this, 'open_issues_count'),
      defaultBranch: _strOpt(this, 'default_branch'),
      createdAt: _dateTime(this, 'created_at'),
      updatedAt: _dateTime(this, 'updated_at'),
      topics: [
        for (final t in topicsRaw)
          if (t case final String s) s,
      ],
    );
  }

  /// Parses a user from JSON.
  User toUser() => (
    login: _str(this, 'login'),
    id: _int(this, 'id'),
    avatarUrl: _str(this, 'avatar_url'),
    htmlUrl: _str(this, 'html_url'),
    name: _strOpt(this, 'name'),
    company: _strOpt(this, 'company'),
    blog: _strOpt(this, 'blog'),
    location: _strOpt(this, 'location'),
    email: _strOpt(this, 'email'),
    bio: _strOpt(this, 'bio'),
    publicRepos: _intOpt(this, 'public_repos') ?? 0,
    publicGists: _intOpt(this, 'public_gists') ?? 0,
    followers: _intOpt(this, 'followers') ?? 0,
    following: _intOpt(this, 'following') ?? 0,
    createdAt: _dateTime(this, 'created_at'),
  );

  /// Parses an issue from JSON.
  Issue toIssue() {
    final userMap = _map(this, 'user');
    final labelsRaw = _list(this, 'labels');

    return (
      id: _int(this, 'id'),
      number: _int(this, 'number'),
      title: _str(this, 'title'),
      state: _str(this, 'state'),
      user: userMap.toUser(),
      labels: [
        for (final l in labelsRaw)
          if (l case final Map<String, dynamic> m)
            (
              id: _int(m, 'id'),
              name: _str(m, 'name'),
              color: _strOpt(m, 'color'),
              description: _strOpt(m, 'description'),
            ),
      ],
      body: _strOpt(this, 'body'),
      comments: _int(this, 'comments'),
      createdAt: _dateTime(this, 'created_at'),
      closedAt: _dateTimeOpt(this, 'closed_at'),
      htmlUrl: _str(this, 'html_url'),
      isPullRequest: this['pull_request'] != null,
    );
  }

  /// Parses a commit from JSON.
  Commit toCommit() {
    final commitData = _map(this, 'commit');
    final authorData = _map(commitData, 'author');
    final committerData = _map(commitData, 'committer');

    return (
      sha: _str(this, 'sha'),
      message: _str(commitData, 'message'),
      author: (
        name: _str(authorData, 'name'),
        email: _str(authorData, 'email'),
        date: _dateTime(authorData, 'date'),
      ),
      committer: (
        name: _str(committerData, 'name'),
        email: _str(committerData, 'email'),
        date: _dateTime(committerData, 'date'),
      ),
      htmlUrl: _str(this, 'html_url'),
    );
  }

  /// Parses repository content from JSON.
  RepoContent toRepoContent() => (
    name: _str(this, 'name'),
    path: _str(this, 'path'),
    sha: _str(this, 'sha'),
    size: _int(this, 'size'),
    type: _str(this, 'type'),
    downloadUrl: _strOpt(this, 'download_url'),
    htmlUrl: _str(this, 'html_url'),
  );
}

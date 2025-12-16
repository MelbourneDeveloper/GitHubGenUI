import 'package:genui/genui.dart';
import 'package:github_genui/catalog/items/issue_item.dart';
import 'package:github_genui/catalog/items/label_badge.dart';
import 'package:github_genui/catalog/items/repo_list.dart';
import 'package:github_genui/catalog/items/repository_card.dart';
import 'package:github_genui/catalog/items/stats_row.dart';
import 'package:github_genui/catalog/items/user_card.dart';
import 'package:github_genui/catalog/items/user_list.dart';

/// Creates the GitHub-specific GenUI catalog with custom widgets.
Catalog createGitHubCatalog() {
  final coreItems = CoreCatalogItems.asCatalog().items.toList();
  return Catalog([
    ...coreItems,
    repositoryCard,
    userCard,
    issueItem,
    labelBadge,
    statsRow,
    repoList,
    userList,
  ]);
}

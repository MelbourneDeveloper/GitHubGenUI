# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Multi-Agent Coordination (Too Many Cooks)
- Keep your key! It's critical. Do not lose it!
- Check messages regularly, lock files before editing, unlock after
- Don't edit locked files; signal intent via plans and messages
- Coordinator: keep delegating via messages. Worker: keep asking for tasks via messages
- Clean up expired locks routinely
- Do not use Git unless asked by user

## Code Rules

**UI Material Design**
- Don't fight the design system
- Use Flutter's theming properly
- Don't hard code colours etc.

**Language & Types**
- You must install the austerity package and apply all rules
- Prefer typedef records over classes for data (structural typing)
- ILLEGAL: `as`, `late`, `!`, `.then()`, global state
- No literals. Only constants. Always reuse these. Don't duplicate

**Architecture**
- NO DUPLICATION—search before adding, move don't copy
- Return `Result<T,E>` (nadz package) instead of throwing exceptions
- Functions < 20 lines, files < 500 LOC
- Switch expressions/ternaries over if/else (except in declarative contexts)

**Testing**
- 100% coverage with high-level integration tests, not unit tests/mocks
- Widget tests MUST double as integration tests (https://www.christianfindlay.com/blog/flutter-integration-tests)
- Only FULL APP widget tests. No testing individual components(https://www.nimblesite.co/blog/flutter_full_app_widget_testing/)
- Tests in separate files, not groups. Dart only (JS only for interop testing)
- Never skip tests. Never remove assertions. Failing tests OK, silent failures ILLEGAL
- NO PLACEHOLDERS—throw if incomplete

## Project Overview

Flutter app that uses GenUI to dynamically generate GitHub-browsing interfaces via AI. Users chat with the AI to explore public GitHub repositories, users, and issues. The AI responds with either text or dynamically-generated Flutter widgets.

## Build & Run Commands

```bash
# Get dependencies
flutter pub get

# Analyze
flutter analyze

# Test
flutter test
```
## Doco

[GenUI](https://github.com/flutter/genui)
[A2UI](https://developers.googleblog.com/introducing-a2ui-an-open-project-for-agent-driven-interfaces)

## Architecture

**GenUI Flow**: User message -> `GenUiConversation` -> `GoogleGenerativeAiContentGenerator` (Gemini) -> AI generates widget JSON -> `GenUiManager` renders widgets from `Catalog`

**Key Components**:
- [chat_screen.dart](lib/screens/chat_screen.dart) - Main UI, orchestrates GenUI conversation
- [github_catalog.dart](lib/catalog/github_catalog.dart) - Custom GenUI widgets (RepositoryCard, UserCard, IssueItem, etc.) with JSON schemas
- [github_api.dart](lib/services/github_api.dart) - REST client for public GitHub API (no auth)
- [github_models.dart](lib/models/github_models.dart) - Data models as typedef records with parsing extensions
- [configuration.dart](lib/configuration.dart) - Gemini API key, model name, system prompt

**Widget Catalog Items**: RepositoryCard, UserCard, IssueItem, LabelBadge, StatsRow, RepoList, UserList - each has a JSON schema that Gemini uses to generate widget data.

- Public GitHub API: 60 requests/hour (unauthenticated)
- Search API: 10 requests/minute, max 1000 results, 256 char query limit
- GenUI requires Flutter >=3.35.7

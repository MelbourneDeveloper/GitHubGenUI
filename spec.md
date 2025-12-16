# GitHubGenUI - Specification

A Flutter app that provides a GitHub-like UI experience using GenUI for dynamic, AI-generated interfaces. No sign-in required - uses only public GitHub APIs.

## Technology Stack

### Core Framework
- **Flutter** (>=3.35.7 required for GenUI)
- **GenUI SDK** - Dynamic AI-generated UI framework

### GenUI Packages
- `genui` - Core framework
- `genui_google_generative_ai` - Google Gemini integration (prototyping)
- `genui_firebase_ai` - Firebase/Gemini integration (production)
- `json_schema_builder` - Widget schema validation

### LLM Backend
GenUI requires an LLM backend. Options:
1. **Google Generative AI** (prototyping) - Requires free Gemini API key from Google AI Studio
2. **Firebase AI** (production) - Requires Firebase project with Gemini API enabled

**Note:** You supply the LLM connection via a `ContentGenerator`. GenUI does not include its own agent - you configure it with Gemini.

## Reference Documentation

### GenUI
- Repository: https://github.com/flutter/genui
- Core package: https://github.com/flutter/genui/tree/main/packages/genui
- Firebase AI package: https://github.com/flutter/genui/tree/main/packages/genui_firebase_ai
- Google Generative AI package: https://github.com/flutter/genui/tree/main/packages/genui_google_generative_ai
- Examples: https://github.com/flutter/genui/tree/main/examples
  - `simple_chat` - Basic chat app
  - `travel_app` - Custom widget catalogs
  - `catalog_gallery` - Widget catalog demo
  - `custom_backend` - Custom backend integration
  - `verdure` - Additional example

### GitHub REST API (OpenAPI)
- OpenAPI Spec Repository: https://github.com/github/rest-api-description
- Spec files location: `descriptions/api.github.com/` (OpenAPI 3.0)
- Next spec files: `descriptions-next/` (OpenAPI 3.1)

### GitHub Public API Endpoints (No Auth Required)

#### Users
- `GET /users/{username}` - Get user by username
- `GET /user/{account_id}` - Get user by ID
- `GET /users` - List all users (paginated)

#### Repositories
- `GET /repos/{owner}/{repo}` - Get repository details
- `GET /users/{username}/repos` - List user's public repos
- `GET /orgs/{org}/repos` - List org's public repos
- `GET /repos/{owner}/{repo}/contents/{path}` - Get repo contents
- `GET /repos/{owner}/{repo}/commits` - List commits
- `GET /repos/{owner}/{repo}/contributors` - List contributors

#### Search (Rate limited: 10 req/min unauthenticated)
- `GET /search/repositories` - Search repos (sort: stars, forks, updated)
- `GET /search/users` - Search users (sort: followers, repos, joined)
- `GET /search/issues` - Search issues/PRs
- `GET /search/commits` - Search commits
- `GET /search/code` - Search code (requires auth)
- `GET /search/topics` - Search topics
- `GET /search/labels` - Search labels (requires repo_id)

#### Issues & Pull Requests
- `GET /repos/{owner}/{repo}/issues` - List issues
- `GET /repos/{owner}/{repo}/issues/{issue_number}` - Get issue
- `GET /repos/{owner}/{repo}/pulls` - List pull requests
- `GET /repos/{owner}/{repo}/pulls/{pull_number}` - Get pull request

#### Other
- `GET /repos/{owner}/{repo}/releases` - List releases
- `GET /repos/{owner}/{repo}/tags` - List tags
- `GET /repos/{owner}/{repo}/branches` - List branches

**API Limits:**
- Unauthenticated: 60 requests/hour
- Search: Max 1,000 results per search, 256 char query limit

## App Features

### Core Views (GitHub-like UI)
1. **Home/Explore** - Trending repos, search
2. **Repository View** - Repo details, files, README, issues, PRs
3. **User Profile** - User info, repos, activity
4. **Search** - Repos, users, issues
5. **Issue/PR Detail** - Comments, status, labels

### GenUI Integration
The app uses GenUI to dynamically generate UI based on:
- User queries about repositories
- Code exploration requests
- Issue/PR summaries
- User profile lookups

### Widget Catalog
Custom GenUI catalog items for GitHub-specific UI:
- Repository card
- User avatar/card
- Issue/PR list item
- Commit list item
- File tree
- README renderer
- Code block
- Label/tag badges

## Architecture

```
lib/
├── main.dart                 # App entry point
├── configuration.dart        # API keys, backend selection
├── app.dart                  # MaterialApp setup
├── theme/
│   └── github_theme.dart     # GitHub-like theming
├── services/
│   ├── github_api.dart       # GitHub REST API client
│   └── genui_service.dart    # GenUI conversation manager
├── catalog/
│   ├── catalog.dart          # Widget catalog definition
│   └── items/                # Individual catalog items
│       ├── repo_card.dart
│       ├── user_card.dart
│       ├── issue_item.dart
│       └── ...
├── screens/
│   ├── home_screen.dart
│   ├── repo_screen.dart
│   ├── user_screen.dart
│   ├── search_screen.dart
│   └── chat_screen.dart      # GenUI chat interface
├── widgets/
│   └── ...                   # Reusable UI components
└── models/
    ├── repository.dart
    ├── user.dart
    ├── issue.dart
    └── ...
```

## GenUI Setup

### Content Generator Configuration
```dart
final contentGenerator = GoogleGenerativeAiContentGenerator(
  catalog: githubCatalog,
  systemInstruction: '''
    You are a GitHub assistant. Help users explore repositories,
    users, issues, and code. Use the provided widgets to display
    GitHub data in a visual, interactive way.
  ''',
  modelName: 'models/gemini-2.5-flash',
  apiKey: geminiApiKey,
);
```

## UI Design

### GitHub Color Palette
- Background: #0d1117 (dark) / #ffffff (light)
- Surface: #161b22 (dark) / #f6f8fa (light)
- Primary: #238636 (green)
- Accent: #58a6ff (blue links)
- Text: #c9d1d9 (dark) / #24292f (light)
- Border: #30363d (dark) / #d0d7de (light)

### Typography
- Font: -apple-system, BlinkMacSystemFont, "Segoe UI", or system default
- Monospace: "SFMono-Regular", Consolas, "Liberation Mono", Menlo

## Implementation Phases

### Phase 1: Project Setup
- Initialize Flutter project
- Add GenUI dependencies
- Configure Gemini API
- Set up GitHub theme

### Phase 2: GitHub API Client
- Implement REST API service
- Add models for repos, users, issues
- Handle rate limiting
- Cache responses

### Phase 3: Widget Catalog
- Create GitHub-specific GenUI widgets
- Define JSON schemas for each widget
- Build catalog with all items

### Phase 4: Core Screens
- Home/Explore screen
- Repository detail screen
- User profile screen
- Search screen

### Phase 5: GenUI Chat Integration
- Chat interface for AI interactions
- Connect GenUI conversation to GitHub data
- Dynamic UI generation based on queries

### Phase 6: Polish
- Error handling
- Loading states
- Offline support
- Performance optimization

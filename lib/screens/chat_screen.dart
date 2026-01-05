import 'dart:async';

import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:genui_google_generative_ai/genui_google_generative_ai.dart';
import 'package:github_genui/api_key.dart';
import 'package:github_genui/catalog/github_catalog.dart';
import 'package:github_genui/configuration.dart';
import 'package:github_genui/screens/widgets/chat_bubbles.dart';
import 'package:github_genui/screens/widgets/chat_input.dart';
import 'package:github_genui/services/github_api.dart';
import 'package:github_genui/services/github_tools.dart';
import 'package:github_genui/theme/github_theme.dart';

/// Factory for creating a content generator.
typedef ContentGeneratorFactory = ContentGenerator Function(Catalog catalog);

/// Main chat screen with GenUI integration.
class ChatScreen extends StatefulWidget {
  /// Creates the chat screen.
  const ChatScreen({super.key, this.contentGeneratorFactory});

  /// Optional factory for creating the content generator (for testing).
  final ContentGeneratorFactory? contentGeneratorFactory;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <ChatBubbleMessage>[];
  final _surfaces = <String, Widget>{};

  GenUiManager? _genUiManager;
  GenUiConversation? _conversation;

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initGenUI();
  }

  void _initGenUI() {
    final catalog = createGitHubCatalog();

    ContentGenerator contentGenerator;

    // Use injected factory or default to Gemini
    final factory = widget.contentGeneratorFactory;
    if (factory != null) {
      contentGenerator = factory(catalog);
    } else {
      // Check for API key only when using default Gemini generator
      if (geminiApiKey.isEmpty) {
        setState(() {
          _error =
              'No GEMINI_API_KEY provided. '
              'Run with: flutter run --dart-define=GEMINI_API_KEY=your_key';
        });
        return;
      }

      // Create GitHub API client and tools
      final gitHubApi = GitHubApi();
      final gitHubTools = createGitHubTools(gitHubApi);

      contentGenerator = GoogleGenerativeAiContentGenerator(
        catalog: catalog,
        systemInstruction: systemInstruction,
        apiKey: geminiApiKey,
        additionalTools: gitHubTools,
      );
    }

    final genUiManager = GenUiManager(catalog: catalog);
    _genUiManager = genUiManager;

    _conversation = GenUiConversation(
      genUiManager: genUiManager,
      contentGenerator: contentGenerator,
      onSurfaceAdded: _handleSurfaceAdded,
      onTextResponse: _handleTextResponse,
      onError: _handleError,
    );

    _messages.add((
      type: ChatBubbleType.assistant,
      text:
          'Welcome to GitHubGenUI! I can help '
          'you explore GitHub repositories, '
          'users, and issues. Try asking me to:\n\n'
          '- "Show me the Flutter repository"\n'
          '- "Search for Dart packages"\n'
          '- "Find users working on AI projects"\n'
          '- "Show trending repositories this week"',
      surfaceId: null,
    ));
  }

  void _handleSurfaceAdded(SurfaceAdded update) {
    final genUiManager = _genUiManager;
    if (genUiManager == null) return;

    setState(() {
      final surface = GenUiSurface(
        host: genUiManager,
        surfaceId: update.surfaceId,
      );
      _surfaces[update.surfaceId] = surface;
      _messages.add((
        type: ChatBubbleType.surface,
        text: null,
        surfaceId: update.surfaceId,
      ));
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _handleTextResponse(String text) {
    setState(() {
      _messages.add((
        type: ChatBubbleType.assistant,
        text: text,
        surfaceId: null,
      ));
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _handleError(ContentGeneratorError error) {
    setState(() {
      _messages.add((
        type: ChatBubbleType.error,
        text: 'Error: ${error.error}',
        surfaceId: null,
      ));
      _isLoading = false;
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    final conversation = _conversation;
    if (text.isEmpty || _isLoading || conversation == null) return;

    _controller.clear();

    setState(() {
      _messages.add((type: ChatBubbleType.user, text: text, surfaceId: null));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      await conversation.sendRequest(UserMessage.text(text));
    } on Object catch (e, st) {
      _handleError(ContentGeneratorError(e, st));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        unawaited(
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const _AppBarTitle()),
    body: Column(
      children: [
        if (_error case final errorText?) _ErrorBanner(text: errorText),
        Expanded(child: _buildMessageList()),
        ChatInput(
          controller: _controller,
          onSend: _sendMessage,
          enabled: _error == null && !_isLoading,
        ),
      ],
    ),
  );

  Widget _buildMessageList() => ListView.builder(
    controller: _scrollController,
    padding: const EdgeInsets.all(16),
    itemCount: _messages.length + (_isLoading ? 1 : 0),
    itemBuilder: (context, index) {
      if (index == _messages.length) return const LoadingBubble();
      return _buildMessage(_messages[index]);
    },
  );

  Widget _buildMessage(ChatBubbleMessage message) {
    final content = switch (message.type) {
      ChatBubbleType.user => UserBubble(text: message.text ?? ''),
      ChatBubbleType.assistant => AssistantBubble(text: message.text ?? ''),
      ChatBubbleType.surface => _buildSurfaceBubble(message),
      ChatBubbleType.error => ErrorBubble(
        text: message.text ?? 'Unknown error',
      ),
    };

    return AnimatedMessageBubble(child: content);
  }

  Widget _buildSurfaceBubble(ChatBubbleMessage message) {
    final surface = _surfaces[message.surfaceId];
    if (surface == null) return const SizedBox.shrink();
    return SurfaceBubble(surface: surface);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _conversation?.dispose();
    super.dispose();
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [GitHubColors.successEmphasis, GitHubColors.accentEmphasis],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: GitHubColors.successEmphasis.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.code, size: 18, color: Colors.white),
      ),
      const SizedBox(width: 12),
      const Text('GitHub'),
    ],
  );
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    color: GitHubColors.dangerEmphasis,
    child: Text(text, style: const TextStyle(color: Colors.white)),
  );
}

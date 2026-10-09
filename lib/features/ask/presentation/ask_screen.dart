import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../services/ai/local/ai_providers.dart';
import '../../../services/ai/local/local_ai_engine.dart';
import '../data/ask_providers.dart';

/// Ask the Record screen: scoped, tool-grounded queries.
/// Not a chatbot — max 3 tool rounds, 20s timeout, same verifier.
class AskScreen extends ConsumerStatefulWidget {
  const AskScreen({super.key});

  @override
  ConsumerState<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends ConsumerState<AskScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isThinking = false;

  static const _suggestions = [
    'Kumusta ang BP ni Lola this week?',
    'Naka-inom ba ng gamot kahapon?',
    'Ano ang last temperature reading?',
    'Ilang missed medications this month?',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tierAsync = ref.watch(aiTierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tanong'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              onPressed: () => context.push('/emergency'),
              icon: const Icon(Icons.sos, size: 18),
              label: const Text('SOS'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // AI availability banner
          tierAsync.when(
            data: (tier) {
              if (tier == AiTier.basic) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.amber.withValues(alpha: 0.1),
                  child: const Text(
                    'Phone helper is off. Simple answers only.',
                    style: TextStyle(fontSize: 13),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Messages
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildMessageBubble(msg, theme);
                    },
                  ),
          ),

          // Suggestion chips (when empty)
          if (_messages.isEmpty)
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ActionChip(
                    label: Text(_suggestions[index], style: const TextStyle(fontSize: 12)),
                    onPressed: () {
                      _controller.text = _suggestions[index];
                      _sendQuery();
                    },
                  );
                },
              ),
            ),

          // Input bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Magtanong tungkol sa records...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendQuery(),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isThinking ? null : _sendQuery,
                    icon: _isThinking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.question_answer_outlined,
              size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'Magtanong tungkol sa records ni Lola',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Hindi ito chatbot — nagbabasa lang sa records.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg, ThemeData theme) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: isUser
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
            if (msg.sources != null && msg.sources!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: msg.sources!.map((s) {
                  return Chip(
                    label: Text(s, style: const TextStyle(fontSize: 10)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _sendQuery() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: query, isUser: true));
      _controller.clear();
      _isThinking = true;
    });

    _scrollToBottom();

    try {
      final agent = await ref.read(askAgentProvider.future);
      final result = await agent.ask(query);
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(
          text: result.text,
          isUser: false,
          sources: result.sourceIds.isEmpty ? null : result.sourceIds,
        ));
      });
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          text: 'May error: $e',
          isUser: false,
        ));
      });
    } finally {
      setState(() => _isThinking = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final List<String>? sources;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.sources,
  });
}

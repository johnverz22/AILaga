import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_bar_actions.dart';
import '../../../services/ai/local/ai_providers.dart';
import '../../../services/ai/local/local_ai_engine.dart';
import '../../care_recipient/data/care_recipient_providers.dart';
import '../data/ask_providers.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

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

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Suggestions use the real care recipient's name — never a
  /// hardcoded one.
  List<String> _suggestions(String name) => [
        'Did $name take pills today?',
        'What was the last BP?',
        'Any missed meds this week?',
        'Any new notes?',
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tierAsync = ref.watch(aiTierProvider);
    final name =
        ref.watch(primaryCareRecipientProvider).valueOrNull?.displayName ??
            'your patient';

    return Scaffold(
      appBar: AppBar(
        // Auto back button (pushed page — no bottom nav here).
        title: const Text('Ask'),
        actions: const [SosAppBarButton()],
      ),
      body: Column(
        children: [
          // Helper availability banner
          tierAsync.when(
            data: (tier) {
              if (tier == AiTier.basic) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: const Color(0xFF9A5B00).withValues(alpha: 0.12),
                  child: const Text(
                    'Phone helper is off. Simple answers only.',
                    style: TextStyle(fontSize: 16),
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
                ? _buildEmptyState(theme, name)
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
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _suggestions(name).length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final suggestion = _suggestions(name)[index];
                  return ActionChip(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    label: Text(suggestion,
                        style: const TextStyle(fontSize: 15)),
                    onPressed: () {
                      _controller.text = suggestion;
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
                      style: const TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        hintText: 'Ask about the records…',
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
                        : const Icon(Symbols.send_rounded),
                    tooltip: 'Send',
                    style: IconButton.styleFrom(
                      minimumSize: const Size(52, 52),
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

  Widget _buildEmptyState(ThemeData theme, String name) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.question_answer_rounded,
                size: 64,
                color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'Ask about $name\'s records',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'It only reads the records on this phone.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5E5748),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg, ThemeData theme) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
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
                fontSize: 18,
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
                    label:
                        Text(s, style: const TextStyle(fontSize: 13)),
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
        _messages.add(const _ChatMessage(
          text: 'Something went wrong. Try again.',
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

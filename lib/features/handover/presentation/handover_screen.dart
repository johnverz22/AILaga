import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/date_formatter.dart';
import '../../care_recipient/data/care_recipient_providers.dart';
import '../data/handover_providers.dart';
import '../domain/handover_entity.dart';

final handoverDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final handoverProvider = FutureProvider.autoDispose<HandoverEntity?>((ref) async {
  final recipient = ref.watch(primaryCareRecipientProvider).value;
  if (recipient == null) return null;
  
  final date = ref.watch(handoverDateProvider);
  final start = DateTime(date.year, date.month, date.day);
  final end = DateTime(date.year, date.month, date.day, 23, 59, 59);
  
  final service = ref.watch(handoverServiceProvider);
  return service.generateHandover(
    recipientId: recipient.id,
    periodStart: start,
    periodEnd: end,
  );
});

class HandoverScreen extends ConsumerStatefulWidget {
  const HandoverScreen({super.key});

  @override
  ConsumerState<HandoverScreen> createState() => _HandoverScreenState();
}

class _HandoverScreenState extends ConsumerState<HandoverScreen> {
  final _textController = TextEditingController();
  HandoverEntity? _currentHandover;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _shareHandover() {
    if (_textController.text.isNotEmpty) {
      Share.share(_textController.text, subject: 'Caregiver Handover');
    }
  }

  void _copyToClipboard() {
    if (_textController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _textController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = ref.watch(handoverDateProvider);
    
    // Listen to changes in the generated handover to update text field
    ref.listen<AsyncValue<HandoverEntity?>>(handoverProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        if (_currentHandover?.periodStart != next.value!.periodStart) {
          _textController.text = next.value!.formattedText;
          _currentHandover = next.value;
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Handover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy to Clipboard',
            onPressed: _copyToClipboard,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: _shareHandover,
          ),
        ],
      ),
      body: Column(
        children: [
          _DateSelectorRow(date: date),
          Expanded(
            child: ref.watch(handoverProvider).when(
              data: (handover) {
                if (handover == null) {
                  return const Center(child: Text('No care recipient found.'));
                }
                
                // Initialize if not done
                if (_textController.text.isEmpty && _currentHandover == null) {
                  _textController.text = handover.formattedText;
                  _currentHandover = handover;
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Review and edit draft before sharing:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                          ),
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _copyToClipboard,
                              icon: const Icon(Icons.copy),
                              label: const Text('Copy'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _shareHandover,
                              icon: const Icon(Icons.share),
                              label: const Text('Share'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSelectorRow extends ConsumerWidget {
  final DateTime date;
  
  const _DateSelectorRow({required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              ref.read(handoverDateProvider.notifier).state = date.subtract(const Duration(days: 1));
            },
          ),
          Text(
            DateFormatter.formatDate(date),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              ref.read(handoverDateProvider.notifier).state = date.add(const Duration(days: 1));
            },
          ),
        ],
      ),
    );
  }
}

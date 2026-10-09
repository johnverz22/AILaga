import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/care_note_providers.dart';
import '../domain/care_note_entity.dart';
import 'widgets/care_note_card.dart';
import '../../care_recipient/data/care_recipient_providers.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class CareNotesScreen extends ConsumerWidget {
  const CareNotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipientAsync = ref.watch(primaryCareRecipientProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Care Notes')),
      body: recipientAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Something went wrong. Try again.')),
        data: (recipient) {
          if (recipient == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Symbols.note_alt_rounded,
                        size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                    const SizedBox(height: 20),
                    Text('No care recipient found', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: () => context.push('/care-recipient/edit'),
                      child: const Text('Add Care Recipient'),
                    ),
                  ],
                ),
              ),
            );
          }

          final notesAsync = ref.watch(recentCareNotesProvider(recipient.id));
          return notesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Something went wrong. Try again.')),
            data: (notes) {
              if (notes.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Symbols.notes_rounded,
                            size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                        const SizedBox(height: 20),
                        Text('No care notes yet', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        const Text('Tap + to log an observation, symptom, or general note.', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => ref.refresh(recentCareNotesProvider(recipient.id)),
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 96),
                  itemCount: notes.length,
                  itemBuilder: (ctx, i) {
                    final note = notes[i];
                    return CareNoteCard(
                      note: note,
                      onToggleReview: () => _toggleReview(ref, note),
                      onDelete: () => _confirmDelete(context, ref, note),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: recipientAsync.whenOrNull(
        data: (r) => r != null
            ? FloatingActionButton.extended(
                onPressed: () => context.push('/care-notes/add', extra: r.id),
                icon: const Icon(Symbols.add_rounded),
                label: const Text('Add Note'),
              )
            : null,
      ),
    );
  }

  Future<void> _toggleReview(WidgetRef ref, CareNoteEntity note) async {
    final newStatus = note.reviewStatus == 'unreviewed' ? 'confirmed' : 'unreviewed';
    await ref.read(careNoteRepositoryProvider).updateReviewStatus(note.id, newStatus);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, CareNoteEntity note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note?'),
        content: const Text('Are you sure you want to delete this care note? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete', style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(careNoteRepositoryProvider).delete(note.id);
    }
  }
}

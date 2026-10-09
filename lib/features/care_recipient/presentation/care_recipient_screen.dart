import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/care_recipient_providers.dart';
import 'widgets/care_recipient_card.dart';

/// Shows the primary care recipient profile. If none exists, prompts to create.
class CareRecipientScreen extends ConsumerWidget {
  const CareRecipientScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipientAsync = ref.watch(primaryCareRecipientProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Care Recipient Profile'),
        actions: [
          recipientAsync.whenOrNull(
                data: (r) => r != null
                    ? IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit',
                        onPressed: () => context.push('/care-recipient/edit'),
                      )
                    : null,
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: recipientAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text('Something went wrong', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(err.toString(),
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        data: (recipient) {
          if (recipient == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_add_alt_1_outlined,
                      size: 72,
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No care recipient yet',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add the person you are caring for to get started.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/care-recipient/edit'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Care Recipient'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              CareRecipientCard(
                recipient: recipient,
                onEdit: () => context.push('/care-recipient/edit'),
              ),
              const SizedBox(height: 12),
              // Family contacts shortcut
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/family-contacts'),
                  icon: const Icon(Icons.people_outline),
                  label: const Text('Manage Family Contacts'),
                ),
              ),
              const SizedBox(height: 8),
              // Delete option
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextButton.icon(
                  onPressed: () => _confirmDelete(context, ref, recipient.id),
                  icon: Icon(Icons.delete_outline,
                      color: theme.colorScheme.error),
                  label: Text(
                    'Delete Profile',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Profile?'),
        content: const Text(
          'This will permanently delete the care recipient and all associated data. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final repo = ref.read(careRecipientRepositoryProvider);
      await repo.delete(id);
    }
  }
}

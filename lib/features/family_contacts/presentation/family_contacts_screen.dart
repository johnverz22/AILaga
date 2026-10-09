import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/family_contact_providers.dart';
import '../domain/family_contact_entity.dart';
import 'widgets/family_contact_card.dart';
import '../../care_recipient/data/care_recipient_providers.dart';

/// Lists all family contacts for the primary care recipient.
/// Supports reordering and shows emergency contacts at the top.
class FamilyContactsScreen extends ConsumerWidget {
  const FamilyContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipientAsync = ref.watch(primaryCareRecipientProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Contacts'),
      ),
      body: recipientAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (recipient) {
          if (recipient == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_search_outlined,
                      size: 64,
                      color: theme.colorScheme.primary.withOpacity(0.4),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No care recipient found',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please add a care recipient profile first.',
                      textAlign: TextAlign.center,
                    ),
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

          final contactsAsync =
              ref.watch(familyContactsProvider(recipient.id));

          return contactsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (contacts) => _buildList(context, ref, recipient.id, contacts),
          );
        },
      ),
      floatingActionButton: recipientAsync.whenOrNull(
        data: (r) => r != null
            ? FloatingActionButton.extended(
                onPressed: () => context.push(
                  '/family-contacts/add',
                  extra: r.id,
                ),
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Add Contact'),
              )
            : null,
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    String recipientId,
    List<FamilyContactEntity> contacts,
  ) {
    final theme = Theme.of(context);

    if (contacts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: theme.colorScheme.primary.withOpacity(0.4),
              ),
              const SizedBox(height: 20),
              Text(
                'No contacts yet',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Add family members or trusted contacts to quickly reach them in an emergency.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 96, top: 8),
      itemCount: contacts.length,
      onReorder: (oldIndex, newIndex) =>
          _reorder(ref, contacts, oldIndex, newIndex),
      itemBuilder: (ctx, i) {
        final contact = contacts[i];
        return FamilyContactCard(
          key: ValueKey(contact.id),
          contact: contact,
          onEdit: () => context.push(
            '/family-contacts/add',
            extra: {'recipientId': recipientId, 'contactId': contact.id},
          ),
          onDelete: () => _confirmDelete(context, ref, contact),
        );
      },
    );
  }

  Future<void> _reorder(
    WidgetRef ref,
    List<FamilyContactEntity> contacts,
    int oldIndex,
    int newIndex,
  ) async {
    if (newIndex > oldIndex) newIndex--;
    final ids = List<String>.from(contacts.map((c) => c.id));
    final moved = ids.removeAt(oldIndex);
    ids.insert(newIndex, moved);
    final repo = ref.read(familyContactRepositoryProvider);
    await repo.reorder(ids);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    FamilyContactEntity contact,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Contact?'),
        content: Text(
            'Remove ${contact.displayName} from family contacts? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Remove',
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final repo = ref.read(familyContactRepositoryProvider);
      await repo.delete(contact.id);
    }
  }
}

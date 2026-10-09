import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/family_contact_providers.dart';
import '../domain/family_contact_entity.dart';
import '../../../../core/utilities/validators.dart';
import '../../../../core/utilities/uuid_generator.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Add or edit a family contact.
///
/// Expects route extra to be a [Map] with keys:
///  - `recipientId` (String) — always required
///  - `contactId`   (String?) — present when editing an existing contact
///
/// When launched from FamilyContactsScreen with just a String extra (add flow
/// from FAB without existing contact), only `recipientId` is present.
class AddFamilyContactScreen extends ConsumerStatefulWidget {
  final String recipientId;
  final String? contactId;

  const AddFamilyContactScreen({
    super.key,
    required this.recipientId,
    this.contactId,
  });

  @override
  ConsumerState<AddFamilyContactScreen> createState() =>
      _AddFamilyContactScreenState();
}

class _AddFamilyContactScreenState
    extends ConsumerState<AddFamilyContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _relationCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isEmergencyContact = false;
  bool _saving = false;
  FamilyContactEntity? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.contactId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    }
  }

  Future<void> _loadExisting() async {
    final repo = ref.read(familyContactRepositoryProvider);
    final entity = await repo.getById(widget.contactId!);
    if (entity != null && mounted) {
      _existing = entity;
      _nameCtrl.text = entity.displayName;
      _relationCtrl.text = entity.relationship ?? '';
      _phoneCtrl.text = entity.phoneNumber;
      _isEmergencyContact = entity.isEmergencyContact;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _relationCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(familyContactRepositoryProvider);
      final now = DateTime.now().toUtc();

      if (_existing != null) {
        // Get current sort count to preserve sort order if no change.
        await repo.update(_existing!.copyWith(
          displayName: _nameCtrl.text.trim(),
          relationship: _relationCtrl.text.trim().isEmpty
              ? null
              : _relationCtrl.text.trim(),
          phoneNumber: _phoneCtrl.text.trim(),
          isEmergencyContact: _isEmergencyContact,
          updatedAt: now,
        ));
      } else {
        // Get next sort order.
        final existing =
            await repo.getByCareRecipient(widget.recipientId);
        final sortOrder = existing.length;

        await repo.create(FamilyContactEntity(
          id: UuidGenerator.generate(),
          careRecipientId: widget.recipientId,
          displayName: _nameCtrl.text.trim(),
          relationship: _relationCtrl.text.trim().isEmpty
              ? null
              : _relationCtrl.text.trim(),
          phoneNumber: _phoneCtrl.text.trim(),
          isEmergencyContact: _isEmergencyContact,
          sortOrder: sortOrder,
          createdAt: now,
          updatedAt: now,
        ));
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Contact' : 'Add Contact'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                hintText: 'e.g. Juan Santos',
                prefixIcon: Icon(Symbols.person_rounded),
              ),
              validator: (v) => Validators.required(v, fieldName: 'Name'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Relationship
            TextFormField(
              controller: _relationCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Relationship (optional)',
                hintText: 'e.g. Son, Daughter, Spouse',
                prefixIcon: Icon(Symbols.favorite_border_rounded),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Phone number
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                hintText: 'e.g. +63 917 123 4567',
                prefixIcon: Icon(Symbols.phone_rounded),
              ),
              validator: (v) =>
                  Validators.requiredPhoneNumber(v, fieldName: 'Phone number'),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),

            // Emergency contact toggle
            Card(
              margin: EdgeInsets.zero,
              child: SwitchListTile(
                value: _isEmergencyContact,
                onChanged: (v) => setState(() => _isEmergencyContact = v),
                title: const Text('Emergency Contact'),
                subtitle: const Text(
                    'Shown at top of the emergency contacts list'),
                secondary: Icon(
                  Symbols.local_hospital_rounded,
                  color: _isEmergencyContact
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(isEditing ? 'Save Changes' : 'Add Contact'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

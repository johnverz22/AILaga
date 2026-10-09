import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/care_recipient_providers.dart';
import '../domain/care_recipient_entity.dart';
import '../../../../core/utilities/validators.dart';
import '../../../../core/utilities/uuid_generator.dart';

/// Create or edit a care recipient profile.
///
/// If a [CareRecipientEntity] already exists (from [primaryCareRecipientProvider]),
/// the form pre-fills with existing data and performs an update on save.
/// Otherwise it creates a new record.
class EditCareRecipientScreen extends ConsumerStatefulWidget {
  const EditCareRecipientScreen({super.key});

  @override
  ConsumerState<EditCareRecipientScreen> createState() =>
      _EditCareRecipientScreenState();
}

class _EditCareRecipientScreenState
    extends ConsumerState<EditCareRecipientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _emergencyInfoCtrl = TextEditingController();
  DateTime? _dateOfBirth;
  bool _saving = false;
  CareRecipientEntity? _existing;

  @override
  void initState() {
    super.initState();
    // Populate form after the first frame so we can read providers.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
  }

  void _loadExisting() {
    final snapshot = ref.read(primaryCareRecipientProvider);
    snapshot.whenData((entity) {
      if (entity != null) {
        _existing = entity;
        _nameCtrl.text = entity.displayName;
        _allergiesCtrl.text = entity.allergies ?? '';
        _notesCtrl.text = entity.importantNotes ?? '';
        _emergencyInfoCtrl.text = entity.emergencyInfo ?? '';
        _dateOfBirth = entity.dateOfBirth;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _allergiesCtrl.dispose();
    _notesCtrl.dispose();
    _emergencyInfoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(1950),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select date of birth',
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    try {
      final repo = ref.read(careRecipientRepositoryProvider);
      final now = DateTime.now().toUtc();

      if (_existing != null) {
        await repo.update(_existing!.copyWith(
          displayName: _nameCtrl.text.trim(),
          dateOfBirth: _dateOfBirth,
          allergies: _allergiesCtrl.text.trim().isEmpty
              ? null
              : _allergiesCtrl.text.trim(),
          importantNotes: _notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim(),
          emergencyInfo: _emergencyInfoCtrl.text.trim().isEmpty
              ? null
              : _emergencyInfoCtrl.text.trim(),
          updatedAt: now,
        ));
      } else {
        await repo.create(CareRecipientEntity(
          id: UuidGenerator.generate(),
          displayName: _nameCtrl.text.trim(),
          dateOfBirth: _dateOfBirth,
          allergies: _allergiesCtrl.text.trim().isEmpty
              ? null
              : _allergiesCtrl.text.trim(),
          importantNotes: _notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim(),
          emergencyInfo: _emergencyInfoCtrl.text.trim().isEmpty
              ? null
              : _emergencyInfoCtrl.text.trim(),
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
    final theme = Theme.of(context);
    final isEditing = _existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Profile' : 'Add Care Recipient'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
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
            // Display name
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                hintText: 'e.g. Maria Santos',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  Validators.required(v, fieldName: 'Full name'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Date of birth
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cake_outlined),
              title: Text(
                _dateOfBirth != null
                    ? 'Born: ${_formatDate(_dateOfBirth!)}'
                    : 'Date of Birth (optional)',
                style: _dateOfBirth != null
                    ? theme.textTheme.bodyMedium
                    : theme.textTheme.bodyMedium!
                        .copyWith(color: theme.hintColor),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_dateOfBirth != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear',
                      onPressed: () => setState(() => _dateOfBirth = null),
                    ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: _pickDateOfBirth,
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Allergies
            TextFormField(
              controller: _allergiesCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Allergies',
                hintText: 'e.g. Penicillin, Shellfish',
                prefixIcon: Icon(Icons.warning_amber_outlined),
                alignLabelWithHint: true,
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Important notes
            TextFormField(
              controller: _notesCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Important Notes',
                hintText: 'Medical history, preferences, mobility notes…',
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Emergency info
            TextFormField(
              controller: _emergencyInfoCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Emergency Information',
                hintText: 'Primary physician, insurance, blood type…',
                prefixIcon: Icon(Icons.local_hospital_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(isEditing ? 'Save Changes' : 'Create Profile'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

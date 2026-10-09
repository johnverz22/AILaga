import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/care_note_providers.dart';
import '../domain/care_note_entity.dart';
import '../../../core/utilities/validators.dart';
import '../../../core/utilities/uuid_generator.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AddCareNoteScreen extends ConsumerStatefulWidget {
  final String recipientId;

  const AddCareNoteScreen({super.key, required this.recipientId});

  @override
  ConsumerState<AddCareNoteScreen> createState() => _AddCareNoteScreenState();
}

class _AddCareNoteScreenState extends ConsumerState<AddCareNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textCtrl = TextEditingController();
  DateTime _observedAt = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _observedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'When was this observed?',
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_observedAt),
    );
    if (time == null || !mounted) return;
    setState(() {
      _observedAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(careNoteRepositoryProvider);
      final now = DateTime.now().toUtc();

      await repo.create(CareNoteEntity(
        id: UuidGenerator.generate(),
        careRecipientId: widget.recipientId,
        observedAt: _observedAt.toUtc(),
        recordedAt: now,
        originalText: _textCtrl.text.trim(),
        structuredSummary: null, // To be filled by AI later if needed
        sourceType: 'manual',
        reviewStatus: 'unreviewed',
        createdAt: now,
        updatedAt: now,
      ));
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Care Note'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Symbols.access_time_rounded),
                title: Text(_formatDateTime(_observedAt)),
                subtitle: const Text('Tap to change observation time'),
                trailing: const Icon(Symbols.chevron_right_rounded),
                onTap: _pickDateTime,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _textCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 8,
              minLines: 4,
              decoration: const InputDecoration(
                labelText: 'Observation or Note *',
                hintText: 'e.g. Complained of mild headache after breakfast. Gave water and rested for 30 mins.',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (v) => Validators.required(v, fieldName: 'Note text'),
            ),
            const SizedBox(height: 8),
            Text(
              'Once saved, the original text cannot be modified. It serves as a permanent record.',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: const Text('Save Note'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $h:$m $ampm';
  }
}

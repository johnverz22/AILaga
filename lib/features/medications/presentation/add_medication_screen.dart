import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/medication_providers.dart';
import '../domain/medication_entity.dart';
import '../../../core/utilities/validators.dart';
import '../../../core/utilities/uuid_generator.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Add or edit a medication schedule.
///
/// Expects route extra to be a String `recipientId` when adding,
/// or a Map `{recipientId, scheduleId}` when editing. The map may also
/// carry `initialValues` to pre-fill the add form — used by the AI
/// review tray's Edit path (spec §5: forms are the edit path).
class AddMedicationScreen extends ConsumerStatefulWidget {
  final String recipientId;
  final String? scheduleId;
  final Map<String, dynamic>? initialValues;

  const AddMedicationScreen({
    super.key,
    required this.recipientId,
    this.scheduleId,
    this.initialValues,
  });

  @override
  ConsumerState<AddMedicationScreen> createState() =>
      _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  List<TimeOfDay> _scheduleTimes = [TimeOfDay.now()];
  bool _saving = false;
  MedicationScheduleEntity? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.scheduleId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    } else if (widget.initialValues != null) {
      final init = widget.initialValues!;
      if (init['medicationName'] != null) {
        _nameCtrl.text = init['medicationName'] as String;
      }
      if (init['instructions'] != null) {
        _instructionsCtrl.text = init['instructions'] as String;
      }
      if (init['timesHhmm'] is List) {
        final parsed = (init['timesHhmm'] as List)
            .whereType<String>()
            .map(_parseHhmm)
            .whereType<TimeOfDay>()
            .toList();
        if (parsed.isNotEmpty) {
          parsed.sort((a, b) => a.hour * 60 + a.minute - (b.hour * 60 + b.minute));
          _scheduleTimes = parsed;
        }
      }
    }
  }

  static TimeOfDay? _parseHhmm(String s) {
    final parts = s.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  Future<void> _loadExisting() async {
    final repo = ref.read(medicationRepositoryProvider);
    final entity = await repo.getScheduleById(widget.scheduleId!);
    if (entity != null && mounted) {
      _existing = entity;
      _nameCtrl.text = entity.medicationName;
      _instructionsCtrl.text = entity.prescribedInstructions ?? '';
      _notesCtrl.text = entity.notes ?? '';
      _startDate = entity.startDate;
      _endDate = entity.endDate;
      // Parse times from JSON
      try {
        final times =
            (jsonDecode(entity.scheduleTimes) as List).cast<String>();
        _scheduleTimes = times.map((t) {
          final parts = t.split(':');
          return TimeOfDay(
              hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }).toList();
      } catch (_) {}
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _instructionsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Start date',
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime(2100),
      helpText: 'End date (optional)',
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Add dose time',
    );
    if (picked != null) {
      setState(() => _scheduleTimes.add(picked));
      _scheduleTimes.sort(
          (a, b) => a.hour * 60 + a.minute - (b.hour * 60 + b.minute));
    }
  }

  String _timesToJson() {
    final list = _scheduleTimes
        .map((t) =>
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
        .toList();
    return jsonEncode(list);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_scheduleTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one dose time.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = ref.read(medicationRepositoryProvider);
      final now = DateTime.now().toUtc();
      final timesJson = _timesToJson();

      if (_existing != null) {
        await repo.updateSchedule(_existing!.copyWith(
          medicationName: _nameCtrl.text.trim(),
          prescribedInstructions: _instructionsCtrl.text.trim().isEmpty
              ? null
              : _instructionsCtrl.text.trim(),
          scheduleTimes: timesJson,
          startDate: _startDate.toUtc(),
          endDate: _endDate?.toUtc(),
          notes: _notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim(),
          updatedAt: now,
        ));
      } else {
        final scheduleId = UuidGenerator.generate();
        await repo.createSchedule(MedicationScheduleEntity(
          id: scheduleId,
          careRecipientId: widget.recipientId,
          medicationName: _nameCtrl.text.trim(),
          prescribedInstructions: _instructionsCtrl.text.trim().isEmpty
              ? null
              : _instructionsCtrl.text.trim(),
          scheduleTimes: timesJson,
          startDate: _startDate.toUtc(),
          endDate: _endDate?.toUtc(),
          notes: _notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim(),
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ));
        // Generate occurrences for the next 14 days.
        await repo.generateOccurrences(
          scheduleId,
          _startDate,
          _startDate.add(const Duration(days: 14)),
        );
      }
      // Pop with `true` so callers (e.g. the AI review tray) can tell a
      // record was actually saved, not just dismissed.
      if (mounted) context.pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error saving: $e')));
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
        title: Text(isEditing ? 'Edit Medication' : 'Add Medication'),
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
            TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Medication name
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Medication Name *',
                hintText: 'e.g. Metformin 500mg',
                prefixIcon: Icon(Symbols.medication_rounded),
              ),
              validator: (v) =>
                  Validators.required(v, fieldName: 'Medication name'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Instructions
            TextFormField(
              controller: _instructionsCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Prescribed Instructions',
                hintText: 'e.g. Take with food, twice daily',
                prefixIcon: Icon(Symbols.receipt_long_rounded),
                alignLabelWithHint: true,
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),

            // Schedule times
            Row(
              children: [
                Text('Dose Times *', style: theme.textTheme.titleSmall),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addTime,
                  icon: const Icon(Symbols.add_rounded, size: 18),
                  label: const Text('Add Time'),
                ),
              ],
            ),
            if (_scheduleTimes.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'No times added yet.',
                  style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.error),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _scheduleTimes.asMap().entries.map((e) {
                  final t = e.value;
                  final label = t.format(context);
                  return Chip(
                    label: Text(label),
                    deleteIcon: const Icon(Symbols.close_rounded, size: 16),
                    onDeleted: _scheduleTimes.length > 1
                        ? () => setState(() => _scheduleTimes.removeAt(e.key))
                        : null,
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),

            // Start date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Symbols.calendar_today_rounded),
              title: Text('Start Date: ${_formatDate(_startDate)}'),
              trailing: const Icon(Symbols.chevron_right_rounded),
              onTap: _pickStartDate,
            ),

            // End date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Symbols.event_rounded),
              title: Text(_endDate != null
                  ? 'End Date: ${_formatDate(_endDate!)}'
                  : 'End Date: Ongoing (tap to set)'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_endDate != null)
                    IconButton(
                      icon: const Icon(Symbols.clear_rounded, size: 18),
                      tooltip: 'Clear end date',
                      onPressed: () => setState(() => _endDate = null),
                    ),
                  const Icon(Symbols.chevron_right_rounded),
                ],
              ),
              onTap: _pickEndDate,
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Notes
            TextFormField(
              controller: _notesCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Additional notes about this medication…',
                prefixIcon: Icon(Symbols.notes_rounded),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(isEditing ? 'Save Changes' : 'Add Medication'),
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
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

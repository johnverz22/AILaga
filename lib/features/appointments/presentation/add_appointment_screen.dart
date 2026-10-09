import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/appointment_providers.dart';
import '../domain/appointment_entity.dart';
import '../../../core/utilities/uuid_generator.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Add or edit an appointment.
///
/// Route extra: String recipientId (add) or Map {recipientId,
/// appointmentId, initialValues} (edit / AI review-tray pre-fill).
class AddAppointmentScreen extends ConsumerStatefulWidget {
  final String recipientId;
  final String? appointmentId;
  final Map<String, dynamic>? initialValues;

  const AddAppointmentScreen({
    super.key,
    required this.recipientId,
    this.appointmentId,
    this.initialValues,
  });

  @override
  ConsumerState<AddAppointmentScreen> createState() =>
      _AddAppointmentScreenState();
}

class _AddAppointmentScreenState
    extends ConsumerState<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _purposeCtrl = TextEditingController();
  final _providerCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _scheduledAt = DateTime.now().add(const Duration(days: 1));
  bool _saving = false;
  AppointmentEntity? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.appointmentId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    } else if (widget.initialValues != null) {
      final init = widget.initialValues!;
      if (init['provider'] != null) {
        _providerCtrl.text = init['provider'] as String;
      }
      if (init['purpose'] != null) {
        _purposeCtrl.text = init['purpose'] as String;
      }
    }
  }

  Future<void> _loadExisting() async {
    final repo = ref.read(appointmentRepositoryProvider);
    final entity = await repo.getById(widget.appointmentId!);
    if (entity != null && mounted) {
      _existing = entity;
      _purposeCtrl.text = entity.purpose ?? '';
      _providerCtrl.text = entity.providerOrFacility ?? '';
      _notesCtrl.text = entity.notes ?? '';
      _scheduledAt = entity.scheduledAt;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _purposeCtrl.dispose();
    _providerCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Appointment date',
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null || !mounted) return;
    setState(() {
      _scheduledAt = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(appointmentRepositoryProvider);
      final now = DateTime.now().toUtc();

      if (_existing != null) {
        await repo.update(_existing!.copyWith(
          purpose: _purposeCtrl.text.trim().isEmpty
              ? null
              : _purposeCtrl.text.trim(),
          providerOrFacility: _providerCtrl.text.trim().isEmpty
              ? null
              : _providerCtrl.text.trim(),
          scheduledAt: _scheduledAt.toUtc(),
          notes: _notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim(),
          updatedAt: now,
        ));
      } else {
        await repo.create(AppointmentEntity(
          id: UuidGenerator.generate(),
          careRecipientId: widget.recipientId,
          purpose: _purposeCtrl.text.trim().isEmpty
              ? null
              : _purposeCtrl.text.trim(),
          providerOrFacility: _providerCtrl.text.trim().isEmpty
              ? null
              : _providerCtrl.text.trim(),
          scheduledAt: _scheduledAt.toUtc(),
          notes: _notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim(),
          status: 'scheduled',
          createdAt: now,
          updatedAt: now,
        ));
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
    final isEditing = _existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Appointment' : 'Add Appointment'),
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
            // Date/time picker (most important — first)
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Symbols.calendar_month_rounded),
                title: Text(_formatDateTime(_scheduledAt)),
                subtitle: const Text('Tap to change date and time'),
                trailing: const Icon(Symbols.chevron_right_rounded),
                onTap: _pickDateTime,
              ),
            ),
            const SizedBox(height: 16),

            // Purpose
            TextFormField(
              controller: _purposeCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Purpose / Reason',
                hintText: 'e.g. Annual check-up, Cardiology follow-up',
                prefixIcon: Icon(Symbols.assignment_rounded),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Provider / Facility
            TextFormField(
              controller: _providerCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Provider / Facility',
                hintText: 'e.g. Dr. Santos, St. Luke\'s Medical Center',
                prefixIcon: Icon(Symbols.local_hospital_rounded),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Preparation instructions, what to bring…',
                prefixIcon: Icon(Symbols.notes_rounded),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(
                  isEditing ? 'Save Changes' : 'Add Appointment'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $h:$m $ampm';
  }
}

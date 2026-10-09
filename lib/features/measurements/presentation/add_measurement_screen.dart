import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/measurement_providers.dart';
import '../domain/measurement_entity.dart';
import '../domain/measurement_type.dart';
import '../../../core/utilities/validators.dart';
import '../../../core/utilities/uuid_generator.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Form to record a new measurement. Adapts fields per type:
///   - Blood Pressure: systolic + diastolic (both required), unit = mmHg
///   - Pulse:          single value, unit = bpm
///   - Temperature:    single value, selectable unit °C / °F
///   - Weight:         single value, selectable unit kg / lbs
///   - Blood Glucose:  single value, selectable unit mg/dL / mmol/L
///
/// All values show range-validation errors inline (NOT silent correction).
class AddMeasurementScreen extends ConsumerStatefulWidget {
  final String recipientId;

  const AddMeasurementScreen({super.key, required this.recipientId});

  @override
  ConsumerState<AddMeasurementScreen> createState() =>
      _AddMeasurementScreenState();
}

class _AddMeasurementScreenState
    extends ConsumerState<AddMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _value1Ctrl = TextEditingController();
  final _value2Ctrl = TextEditingController(); // diastolic for BP
  final _notesCtrl = TextEditingController();

  MeasurementType _type = MeasurementType.bloodPressure;
  String _unit = 'mmHg';
  DateTime _measuredAt = DateTime.now();
  bool _saving = false;

  // Available units per type
  static const _unitOptions = {
    MeasurementType.bloodPressure: ['mmHg'],
    MeasurementType.pulse: ['bpm'],
    MeasurementType.temperature: ['°C', '°F'],
    MeasurementType.weight: ['kg', 'lbs'],
    MeasurementType.bloodGlucose: ['mg/dL', 'mmol/L'],
  };

  @override
  void dispose() {
    _value1Ctrl.dispose();
    _value2Ctrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onTypeChanged(MeasurementType t) {
    setState(() {
      _type = t;
      _unit = _unitOptions[t]!.first;
      _value1Ctrl.clear();
      _value2Ctrl.clear();
    });
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _measuredAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Measurement date',
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_measuredAt),
      helpText: 'Measurement time',
    );
    if (time == null || !mounted) return;
    setState(() {
      _measuredAt = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  /// Returns error string or null. Uses Validators for range checks.
  String? _validateValue1(String? v) {
    if (v == null || v.trim().isEmpty) return 'Value is required.';
    final num = double.tryParse(v.trim());
    if (num == null) return 'Enter a valid number.';
    switch (_type) {
      case MeasurementType.bloodPressure:
        return Validators.bloodPressureSystolic(num);
      case MeasurementType.pulse:
        return Validators.pulse(num);
      case MeasurementType.temperature:
        return _unit == '°C'
            ? Validators.temperatureCelsius(num)
            : Validators.temperatureFahrenheit(num);
      case MeasurementType.weight:
        return _unit == 'kg'
            ? Validators.weightKg(num)
            : Validators.weightLbs(num);
      case MeasurementType.bloodGlucose:
        return _unit == 'mg/dL'
            ? Validators.bloodGlucoseMgDl(num)
            : Validators.bloodGlucoseMmolL(num);
    }
  }

  String? _validateValue2(String? v) {
    if (_type != MeasurementType.bloodPressure) return null;
    if (v == null || v.trim().isEmpty) return 'Diastolic is required.';
    final num = double.tryParse(v.trim());
    if (num == null) return 'Enter a valid number.';
    return Validators.bloodPressureDiastolic(num);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(measurementRepositoryProvider);
      final now = DateTime.now().toUtc();
      final v1 = double.parse(_value1Ctrl.text.trim());
      final v2 = _type == MeasurementType.bloodPressure
          ? double.parse(_value2Ctrl.text.trim())
          : null;

      await repo.create(MeasurementEntity(
        id: UuidGenerator.generate(),
        careRecipientId: widget.recipientId,
        measurementType: _type,
        value1: v1,
        value2: v2,
        unit: _unit,
        measuredAt: _measuredAt.toUtc(),
        recordedAt: now,
        sourceType: 'manual',
        sourceLabel: null,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        createdAt: now,
        updatedAt: now,
      ));
      if (mounted) context.pop();
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
    final cs = theme.colorScheme;
    final units = _unitOptions[_type]!;
    final isBP = _type == MeasurementType.bloodPressure;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Measurement'),
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
            // Type selector
            Text('Measurement Type', style: theme.textTheme.titleSmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MeasurementType.values.map((t) {
                final selected = t == _type;
                return GestureDetector(
                  onTap: () => _onTypeChanged(t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? cs.primary : cs.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: selected
                              ? cs.primary
                              : cs.onSurface.withValues(alpha: 0.15)),
                    ),
                    child: Text(
                      t.displayLabel,
                      style: TextStyle(
                        color: selected ? cs.onPrimary : cs.onSurface,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Value fields
            if (isBP) ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _value1Ctrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Systolic *',
                        hintText: 'e.g. 120',
                        suffixText: 'mmHg',
                      ),
                      validator: _validateValue1,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _value2Ctrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Diastolic *',
                        hintText: 'e.g. 80',
                        suffixText: 'mmHg',
                      ),
                      validator: _validateValue2,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _value1Ctrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        labelText: '${_type.displayLabel} *',
                        hintText: _hint(_type),
                      ),
                      validator: _validateValue1,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  if (units.length > 1) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _unit,
                        decoration: const InputDecoration(labelText: 'Unit'),
                        items: units
                            .map((u) => DropdownMenuItem(
                                value: u, child: Text(u)))
                            .toList(),
                        onChanged: (u) {
                          if (u != null) {
                            setState(() {
                              _unit = u;
                              _value1Ctrl.clear(); // clear on unit change
                            });
                          }
                        },
                      ),
                    ),
                  ] else ...[
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Text(
                        _unit,
                        style: theme.textTheme.bodyLarge!
                            .copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 16),

            // Date/time picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Symbols.access_time_rounded),
              title: Text(_formatDateTime(_measuredAt)),
              subtitle: const Text('Tap to change measurement time'),
              trailing: const Icon(Symbols.chevron_right_rounded),
              onTap: _pickDateTime,
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Notes
            TextFormField(
              controller: _notesCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Any relevant context…',
                prefixIcon: Icon(Symbols.notes_rounded),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: const Text('Save Reading'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _hint(MeasurementType t) {
    switch (t) {
      case MeasurementType.pulse:
        return 'e.g. 72';
      case MeasurementType.temperature:
        return _unit == '°C' ? 'e.g. 36.6' : 'e.g. 98.6';
      case MeasurementType.weight:
        return _unit == 'kg' ? 'e.g. 65.0' : 'e.g. 143.0';
      case MeasurementType.bloodGlucose:
        return _unit == 'mg/dL' ? 'e.g. 95' : 'e.g. 5.3';
      default:
        return '';
    }
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $h:$m $ampm';
  }
}

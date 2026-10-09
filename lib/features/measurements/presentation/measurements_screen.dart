import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/measurement_providers.dart';
import '../domain/measurement_entity.dart';
import '../domain/measurement_type.dart';
import 'widgets/measurement_card.dart';
import '../../care_recipient/data/care_recipient_providers.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Measurement history screen showing all readings, grouped by type or
/// chronologically. A filter chip row lets the user switch views.
class MeasurementsScreen extends ConsumerStatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  ConsumerState<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends ConsumerState<MeasurementsScreen> {
  MeasurementType? _filterType; // null = show all

  @override
  Widget build(BuildContext context) {
    final recipientAsync = ref.watch(primaryCareRecipientProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Measurements')),
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
                    Icon(Symbols.monitor_heart_rounded,
                        size: 64, color: cs.primary.withValues(alpha: 0.4)),
                    const SizedBox(height: 20),
                    Text('No care recipient found',
                        style: theme.textTheme.titleMedium),
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

          final measurementsAsync =
              ref.watch(recentMeasurementsProvider(recipient.id));

          return Column(
            children: [
              // Filter chips
              _FilterChipRow(
                selected: _filterType,
                onChanged: (t) => setState(() => _filterType = t),
              ),
              // List
              Expanded(
                child: measurementsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Something went wrong. Try again.')),
                  data: (all) {
                    final filtered = _filterType == null
                        ? all
                        : all
                            .where((m) => m.measurementType == _filterType)
                            .toList();
                    return _buildList(
                        context, ref, recipient.id, filtered);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: recipientAsync.whenOrNull(
        data: (r) => r != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'pulse-cam',
                    tooltip: 'Measure pulse with camera',
                    backgroundColor: const Color(0xFF2F4B8A),
                    foregroundColor: Colors.white,
                    onPressed: () => context
                        .push('/measurements/pulse-cam', extra: r.id),
                    child: const Icon(Symbols.monitor_heart_rounded),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton.extended(
                    heroTag: 'record',
                    onPressed: () =>
                        context.push('/measurements/add', extra: r.id),
                    icon: const Icon(Symbols.add_rounded),
                    label: const Text('Record'),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    String recipientId,
    List<MeasurementEntity> measurements,
  ) {
    final theme = Theme.of(context);
    if (measurements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Symbols.monitor_heart_rounded,
                  size: 64,
                  color: theme.colorScheme.primary.withValues(alpha: 0.4)),
              const SizedBox(height: 20),
              Text(
                _filterType == null
                    ? 'No measurements recorded yet'
                    : 'No ${_filterType!.displayLabel} readings yet',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap the Record button below to add a new reading.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96, top: 4),
      itemCount: measurements.length,
      itemBuilder: (ctx, i) {
        final m = measurements[i];
        return MeasurementCard(
          measurement: m,
          onDelete: () => _confirmDelete(context, ref, m),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MeasurementEntity m,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reading?'),
        content: Text(
            'Delete this ${m.measurementType.displayLabel} reading? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete',
                style:
                    TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(measurementRepositoryProvider).delete(m.id);
    }
  }
}

// ---------------------------------------------------------------------------
// Filter chip row
// ---------------------------------------------------------------------------

class _FilterChipRow extends StatelessWidget {
  final MeasurementType? selected;
  final ValueChanged<MeasurementType?> onChanged;

  const _FilterChipRow({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _Chip(
            label: 'All',
            selected: selected == null,
            onTap: () => onChanged(null),
          ),
          const SizedBox(width: 8),
          ...MeasurementType.values.map((t) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _Chip(
                  label: t.displayLabel,
                  selected: selected == t,
                  onTap: () =>
                      onChanged(selected == t ? null : t),
                ),
              )),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected
                  ? cs.primary
                  : cs.onSurface.withValues(alpha: 0.15)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? cs.onPrimary : cs.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

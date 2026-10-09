import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/medication_providers.dart';
import '../domain/medication_entity.dart';
import 'widgets/occurrence_tile.dart';
import '../../../core/utilities/date_utils.dart';

/// Detail view for a medication schedule showing:
///   - Schedule info (name, instructions, times)
///   - Occurrence list for today (and recent days)
///   - Edit & deactivate actions
class MedicationDetailScreen extends ConsumerWidget {
  final String medicationId;
  const MedicationDetailScreen({super.key, required this.medicationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return FutureBuilder<MedicationScheduleEntity?>(
      future: ref
          .read(medicationRepositoryProvider)
          .getScheduleById(medicationId),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Medication')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final schedule = snap.data;
        if (schedule == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Medication')),
            body: const Center(child: Text('Medication not found.')),
          );
        }
        return _DetailBody(schedule: schedule);
      },
    );
  }
}

class _DetailBody extends ConsumerStatefulWidget {
  final MedicationScheduleEntity schedule;
  const _DetailBody({required this.schedule});

  @override
  ConsumerState<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends ConsumerState<_DetailBody> {
  late DateTime _viewDate;

  @override
  void initState() {
    super.initState();
    _viewDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final schedule = widget.schedule;

    return Scaffold(
      appBar: AppBar(
        title: Text(schedule.medicationName,
            overflow: TextOverflow.ellipsis),
        actions: [
          if (schedule.isActive) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: () => context.push(
                '/medications/add',
                extra: {
                  'recipientId': schedule.careRecipientId,
                  'scheduleId': schedule.id,
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.pause_circle_outline),
              tooltip: 'Deactivate',
              onPressed: () => _confirmDeactivate(context, ref, schedule),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Schedule summary card
          _ScheduleSummaryCard(schedule: schedule),

          // Day navigator
          _DayNavigator(
            viewDate: _viewDate,
            onPrev: () => setState(() =>
                _viewDate = _viewDate.subtract(const Duration(days: 1))),
            onNext: _viewDate.day == DateTime.now().day &&
                    _viewDate.month == DateTime.now().month &&
                    _viewDate.year == DateTime.now().year
                ? null
                : () => setState(
                    () => _viewDate = _viewDate.add(const Duration(days: 1))),
          ),

          // Occurrences list
          Expanded(
            child: _OccurrencesList(
              schedule: schedule,
              viewDate: _viewDate,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeactivate(
    BuildContext context,
    WidgetRef ref,
    MedicationScheduleEntity schedule,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate Medication?'),
        content: Text(
          'This will stop tracking new doses for "${schedule.medicationName}". '
          'History will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Deactivate',
                style: TextStyle(
                    color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref
          .read(medicationRepositoryProvider)
          .deactivateSchedule(schedule.id);
      if (context.mounted) context.pop();
    }
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _ScheduleSummaryCard extends StatelessWidget {
  final MedicationScheduleEntity schedule;
  const _ScheduleSummaryCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!schedule.isActive)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'This medication schedule is inactive.',
                  style: theme.textTheme.bodySmall!.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.5)),
                  textAlign: TextAlign.center,
                ),
              ),
            if (schedule.prescribedInstructions?.isNotEmpty == true) ...[
              Row(
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 16, color: cs.onSurface.withValues(alpha: 0.5)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      schedule.prescribedInstructions!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Icon(Icons.date_range_outlined,
                    size: 16, color: cs.onSurface.withValues(alpha: 0.5)),
                const SizedBox(width: 8),
                Text(
                  _dateRange(schedule),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            if (schedule.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes_outlined,
                      size: 16, color: cs.onSurface.withValues(alpha: 0.5)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      schedule.notes!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _dateRange(MedicationScheduleEntity s) {
    final start = AppDateUtils.formatShortDate(s.startDate);
    if (s.endDate == null) return 'From $start (ongoing)';
    return '$start – ${AppDateUtils.formatShortDate(s.endDate!)}';
  }
}

class _DayNavigator extends StatelessWidget {
  final DateTime viewDate;
  final VoidCallback onPrev;
  final VoidCallback? onNext;
  const _DayNavigator(
      {required this.viewDate, required this.onPrev, this.onNext});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = AppDateUtils.isToday(viewDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrev,
            tooltip: 'Previous day',
          ),
          Expanded(
            child: Text(
              isToday
                  ? 'Today, ${AppDateUtils.formatDate(viewDate)}'
                  : AppDateUtils.formatDate(viewDate),
              style: theme.textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right,
                color: onNext == null
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.2)
                    : null),
            onPressed: onNext,
            tooltip: 'Next day',
          ),
        ],
      ),
    );
  }
}

class _OccurrencesList extends ConsumerWidget {
  final MedicationScheduleEntity schedule;
  final DateTime viewDate;
  const _OccurrencesList(
      {required this.schedule, required this.viewDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return FutureBuilder<List<MedicationOccurrenceEntity>>(
      future: ref
          .read(medicationRepositoryProvider)
          .getOccurrencesForDate(schedule.id, viewDate),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final occurrences = snap.data ?? [];

        if (occurrences.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  Text(
                    'No doses recorded for this day.',
                    style: theme.textTheme.bodyMedium!.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(medicationRepositoryProvider),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: occurrences.length,
            itemBuilder: (ctx, i) => OccurrenceTile(
              occurrence: occurrences[i],
              medicationName: schedule.medicationName,
            ),
          ),
        );
      },
    );
  }
}

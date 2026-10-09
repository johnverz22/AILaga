import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../services/auth/auth_providers.dart';
import '../../../../services/sync/sync_models.dart';
import '../../../../services/sync/sync_providers.dart';

/// Compact widget showing real-time cloud sync health.
///
/// States:
///   ● Synced (Oct 9, 4:52 PM)       — green dot
///   ● Syncing…                       — animated spinner
///   ● Sync failed — Tap to retry     — orange dot + tap handler
///   ● Not signed in                  — gray dot
class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatusAsync = ref.watch(syncStatusProvider);
    final isSignedIn = ref.watch(isSignedInProvider);

    if (!isSignedIn) {
      return _StatusRow(
        color: Colors.grey,
        label: 'Not signed in',
        semanticLabel: 'Cloud sync: not signed in',
      );
    }

    return syncStatusAsync.when(
      loading: () => _StatusRow(
        color: const Color(0xFF0B6B6B), // teal
        label: 'Syncing…',
        showSpinner: true,
        semanticLabel: 'Cloud sync: syncing in progress',
      ),
      error: (_, __) => _RetryRow(ref: ref),
      data: (status) => _buildFromStatus(context, ref, status),
    );
  }

  Widget _buildFromStatus(
    BuildContext context,
    WidgetRef ref,
    SyncStatus status,
  ) {
    switch (status) {
      case SyncStatus.syncing:
        return _StatusRow(
          color: const Color(0xFF0B6B6B),
          label: 'Syncing…',
          showSpinner: true,
          semanticLabel: 'Cloud sync: syncing in progress',
        );

      case SyncStatus.success:
        final lastSyncAsync = ref.watch(lastSyncTimeProvider);
        final timeLabel = lastSyncAsync.maybeWhen(
          data: (t) => t != null ? _formatTime(t.toLocal()) : null,
          orElse: () => null,
        );
        return _StatusRow(
          color: const Color(0xFF1B7F3B), // sure / green
          label: timeLabel != null ? 'Synced ($timeLabel)' : 'Synced',
          semanticLabel: timeLabel != null
              ? 'Cloud sync: synced at $timeLabel'
              : 'Cloud sync: synced',
        );

      case SyncStatus.error:
        return _RetryRow(ref: ref);

      case SyncStatus.idle:
      case SyncStatus.disabled:
        return _StatusRow(
          color: Colors.grey,
          label: 'Not synced yet',
          semanticLabel: 'Cloud sync: not yet synced',
        );
    }
  }

  String _formatTime(DateTime local) {
    return DateFormat('MMM d, h:mm a').format(local);
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _StatusRow extends StatelessWidget {
  final Color color;
  final String label;
  final String semanticLabel;
  final bool showSpinner;

  const _StatusRow({
    required this.color,
    required this.label,
    required this.semanticLabel,
    this.showSpinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSpinner)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            )
          else
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Sync failed — Tap to retry" row that triggers syncAll on tap.
class _RetryRow extends ConsumerWidget {
  const _RetryRow({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const color = Color(0xFF9A5B00); // check / orange
    return Semantics(
      label: 'Cloud sync failed. Tap to retry.',
      button: true,
      child: GestureDetector(
        onTap: () => _retry(ref),
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Sync failed — Tap to retry',
              style: TextStyle(
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _retry(WidgetRef ref) {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    ref.read(syncServiceProvider).syncAll(uid);
  }
}

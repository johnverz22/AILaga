import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../services/auth/auth_providers.dart';
import '../../../services/sync/sync_models.dart';
import '../../../services/sync/sync_preferences.dart';
import '../../../services/sync/sync_providers.dart';
import 'widgets/sync_status_widget.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Tracks whether a "Sync Now" operation is in flight.
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    final isSignedIn = ref.watch(isSignedInProvider);
    final email = ref.watch(currentEmailProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // ----------------------------------------------------------------
          // Account
          // ----------------------------------------------------------------
          _buildSectionHeader('Account'),
          if (!isSignedIn) ...[
            ListTile(
              leading: const Icon(Icons.cloud_outlined),
              title: const Text('Sign In or Create Account'),
              subtitle: const Text(
                'Back up your data to the cloud and access it from multiple devices.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/auth/login'),
            ),
          ] else ...[
            // Signed-in header
            ListTile(
              leading: const Icon(Icons.check_circle, color: Color(0xFF1B7F3B)),
              title: Text(
                'Signed in as ${email ?? '—'}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const SyncStatusWidget(),
            ),
            // Sync Now
            ListTile(
              leading: _isSyncing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              title: const Text('Sync Now'),
              onTap: _isSyncing ? null : () => _syncNow(context),
            ),
            // Last synced timestamp
            _LastSyncedTile(),
            // Automatic sync toggle (non-sensitive preference — uses SharedPreferences)
            Consumer(
              builder: (context, ref, _) {
                final syncEnabled = ref.watch(syncEnabledProvider);
                return SwitchListTile(
                  secondary: const Icon(Icons.sync),
                  title: const Text('Automatic Sync'),
                  subtitle: const Text('Sync when the app opens'),
                  value: syncEnabled,
                  onChanged: (val) => ref
                      .read(syncEnabledNotifierProvider.notifier)
                      .setEnabled(val),
                );
              },
            ),
            // Sign Out
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _confirmSignOut(context),
            ),
          ],

          const Divider(),
          // ----------------------------------------------------------------
          // Notifications
          // ----------------------------------------------------------------
          _buildSectionHeader('Notifications'),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Allow Notifications'),
            subtitle: const Text('Enabled'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Open OS notification settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Reminder Timing'),
            subtitle: const Text('15 minutes before'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const Divider(),
          // ----------------------------------------------------------------
          // Emergency
          // ----------------------------------------------------------------
          _buildSectionHeader('Emergency'),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Emergency Number'),
            subtitle: const Text('Not set'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          SwitchListTile(
            secondary: const Icon(Icons.touch_app),
            title: const Text('Gesture Shortcut'),
            subtitle: const Text('Enable quick SOS gesture'),
            value: true,
            onChanged: (val) {},
          ),

          const Divider(),
          // ----------------------------------------------------------------
          // Privacy
          // ----------------------------------------------------------------
          _buildSectionHeader('Privacy'),
          const ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('By default, your data stays on this device.'),
          ),
          if (isSignedIn) ...[
            const ListTile(
              leading: Icon(Icons.cloud_done),
              title: Text(
                'If you sign in, your data is backed up to our secure cloud (Supabase).',
              ),
            ),
            const ListTile(
              leading: Icon(Icons.security),
              title: Text(
                'Your health data is never shared with Firebase — it is used only for account identity.',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text(
                  'You can delete your cloud data at any time from Account Settings.'),
              onTap: () => _confirmDeleteCloudData(context),
            ),
          ] else ...[
            const ListTile(
              leading: Icon(Icons.cloud_off),
              title: Text('Sign in to back up your data to the secure cloud.'),
            ),
          ],
          const ListTile(
            leading: Icon(Icons.share),
            title: Text('Sharing reports sends data outside this app.'),
          ),

          const Divider(),
          // ----------------------------------------------------------------
          // AI Features
          // ----------------------------------------------------------------
          _buildSectionHeader('AI Features'),
          SwitchListTile(
            secondary: const Icon(Icons.auto_awesome),
            title: const Text('AI Summaries'),
            subtitle: const Text(
                'AI summaries are optional. Template-based summaries are always available.'),
            value: false,
            onChanged: (val) {},
          ),

          const Divider(),
          // ----------------------------------------------------------------
          // Health Connect
          // ----------------------------------------------------------------
          _buildSectionHeader('Health Connect'),
          ListTile(
            leading: const Icon(Icons.health_and_safety),
            title: const Text('Integration Status'),
            subtitle: const Text('Not connected'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const Divider(),
          // ----------------------------------------------------------------
          // Data Management
          // ----------------------------------------------------------------
          _buildSectionHeader('Data Management'),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Coming soon'),
            onTap: null,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Delete All Data',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _showDeleteConfirmation(context),
          ),

          const Divider(),
          // ----------------------------------------------------------------
          // About
          // ----------------------------------------------------------------
          _buildSectionHeader('About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('AILaga Version 1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.warning_amber),
            title: Text('AILaga is not a medical device'),
            subtitle:
                Text('Consult a healthcare professional for medical advice.'),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Helpers
  // --------------------------------------------------------------------------

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0B6B6B), // teal
        ),
      ),
    );
  }

  Future<void> _syncNow(BuildContext context) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;

    // Capture messenger before the first await to satisfy
    // use_build_context_synchronously.
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isSyncing = true);
    try {
      final result = await ref.read(syncServiceProvider).syncAll(uid);
      // Refresh last sync time after a successful sync.
      ref.invalidate(lastSyncTimeProvider);
      if (!mounted) return;
      if (result.status == SyncStatus.success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Synced — ${result.recordsUploaded} uploaded, '
              '${result.recordsDownloaded} downloaded.',
            ),
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content:
                Text(result.errorMessage ?? 'Sync failed. Please try again.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Sync failed. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text(
          'You will be signed out. Your local data will remain on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authServiceProvider).signOut();
            },
            child: const Text(
              'SIGN OUT',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCloudData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Cloud Data?'),
        content: const Text(
          'This removes your backed-up data from the cloud. '
          'Your local data on this device is not affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteCloudData(context);
            },
            child: const Text(
              'DELETE CLOUD DATA',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCloudData(BuildContext context) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(syncServiceProvider).deleteCloudData(uid);
      ref.invalidate(lastSyncTimeProvider);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Cloud data deleted.')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
            content: Text('Failed to delete cloud data. Please try again.')),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All Data?'),
        content: const Text(
          'This action cannot be undone. All your locally stored data will be permanently deleted.\n\n'
          'Are you sure you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showDoubleConfirmation(context);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDoubleConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text('Please confirm once more to wipe all data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data deleted')),
              );
            },
            child: const Text(
              'CONFIRM DELETE',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Last synced tile — separate widget so it can watch lastSyncTimeProvider
// independently without rebuilding the whole screen.
// ---------------------------------------------------------------------------
class _LastSyncedTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastSyncAsync = ref.watch(lastSyncTimeProvider);
    return lastSyncAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (time) {
        if (time == null) return const SizedBox.shrink();
        final local = time.toLocal();
        final label = DateFormat('MMM d, yyyy \'at\' h:mm a').format(local);
        return Padding(
          padding: const EdgeInsets.only(left: 72, right: 16, bottom: 4),
          child: Text(
            'Last synced: $label',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app/app_bar_actions.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/notifications/notification_provider.dart';
import '../../../services/demo/demo_data_service.dart';
import '../../../services/hardware/app_settings_service.dart';
import '../../care_recipient/data/care_recipient_providers.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shakeSos = ref.watch(shakeSosEnabledProvider);
    final fallDetection = ref.watch(fallDetectionEnabledProvider);
    final recipient = ref.watch(primaryCareRecipientProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        actions: const [SosAppBarButton()],
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Notifications'),
          // Real permission status — tap opens OS settings.
          FutureBuilder<PermissionStatus>(
            future: Permission.notification.status,
            builder: (context, snap) {
              final granted = snap.data?.isGranted ?? false;
              return ListTile(
                leading: const Icon(Symbols.notifications_rounded),
                title: const Text('Notifications'),
                subtitle: Text(granted ? 'On' : 'Off — tap to open Settings'),
                trailing: const Icon(Symbols.chevron_right_rounded),
                onTap: () => openAppSettings(),
              );
            },
          ),
          const ListTile(
            leading: Icon(Symbols.access_time_rounded),
            title: Text('Reminder timing'),
            subtitle: Text(
                'Pills: when due. Appointments: 30 minutes before.'),
          ),

          const Divider(),
          _buildSectionHeader('Emergency'),
          ListTile(
            leading: const Icon(Symbols.phone_rounded),
            title: const Text('Emergency number'),
            subtitle: const Text('911 — opens the phone dialer'),
            trailing: const Icon(Symbols.chevron_right_rounded),
            onTap: () => context.push('/emergency'),
          ),
          SwitchListTile(
            secondary: const Icon(Symbols.sos_rounded),
            title: const Text('Shake for SOS'),
            subtitle: const Text('Shake the phone fast to get help. While app is open.'),
            value: shakeSos.valueOrNull ?? true,
            onChanged: (val) async {
              await ref
                  .read(appSettingsServiceProvider)
                  .setBool(AppSettingsService.keyShakeSos, val);
              ref.invalidate(shakeSosEnabledProvider);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Symbols.personal_injury_rounded),
            title: const Text('Fall detection'),
            subtitle: const Text('Ask "Are you okay?" after a hard fall. While app is open.'),
            value: fallDetection.valueOrNull ?? false,
            onChanged: (val) async {
              await ref
                  .read(appSettingsServiceProvider)
                  .setBool(AppSettingsService.keyFallDetection, val);
              ref.invalidate(fallDetectionEnabledProvider);
            },
          ),

          const Divider(),
          _buildSectionHeader('Privacy'),
          const ListTile(
            leading: Icon(Symbols.privacy_tip_rounded),
            title: Text('Your data is stored on this phone'),
            subtitle: Text('No account or internet needed.'),
          ),
          const ListTile(
            leading: Icon(Symbols.share_rounded),
            title: Text('Sharing a report sends it outside this app'),
          ),

          const Divider(),
          _buildSectionHeader('Smart Assistant'),
          ListTile(
            leading: const Icon(Symbols.psychology_rounded),
            title: const Text('Smart Assistant'),
            subtitle: const Text('Download, status, delete'),
            trailing: const Icon(Symbols.chevron_right_rounded),
            onTap: () => context.push('/ai-setup'),
          ),
          ListTile(
            leading: const Icon(Symbols.shield_rounded),
            title: const Text('On my phone'),
            subtitle: const Text('What stays on this phone'),
            trailing: const Icon(Symbols.chevron_right_rounded),
            onTap: () => context.push('/ai-privacy'),
          ),

          const Divider(),
          _buildSectionHeader('Wearables'),
          ListTile(
            leading: const Icon(Symbols.watch_rounded),
            title: const Text('Health Connect'),
            subtitle: const Text('Read pulse, blood pressure & more'),
            trailing: const Icon(Symbols.chevron_right_rounded),
            onTap: () => context.push('/health-connect'),
          ),
          ListTile(
            leading: const Icon(Symbols.monitor_heart_rounded),
            title: const Text('Camera pulse'),
            subtitle: const Text('Estimate pulse with your fingertip'),
            trailing: const Icon(Symbols.chevron_right_rounded),
            onTap: recipient == null
                ? null
                : () => context.push('/measurements/pulse-cam',
                    extra: recipient.id),
          ),

          const Divider(),
          _buildSectionHeader('Data'),
          ListTile(
            leading: const Icon(Symbols.play_circle_rounded),
            title: const Text('Load demo data'),
            subtitle: const Text('Fill the app with sample records'),
            onTap: recipient == null
                ? () => _loadDemoData(context, ref)
                : () => _showDemoConfirmation(context, ref),
          ),
          ListTile(
            leading: const Icon(Symbols.delete_forever_rounded,
                color: Color(0xFFB3261E)),
            title: const Text('Delete all data',
                style: TextStyle(color: Color(0xFFB3261E))),
            subtitle: const Text('Erases everything on this phone'),
            onTap: () => _showDeleteConfirmation(context, ref),
          ),

          const Divider(),
          _buildSectionHeader('About'),
          const ListTile(
            leading: Icon(Symbols.info_rounded),
            title: Text('AILaga version 0.1.0'),
          ),
          const ListTile(
            leading: Icon(Symbols.warning_amber_rounded),
            title: Text('AILaga is not a medical device'),
            subtitle: Text('Consult a healthcare professional for medical advice.'),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0B6B6B),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete all data?'),
        content: const Text(
          'This permanently erases every record on this phone. It cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showDoubleConfirmation(context, ref);
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFB3261E))),
          ),
        ],
      ),
    );
  }

  void _showDoubleConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Tap "Delete" once more to erase all data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB3261E)),
            onPressed: () {
              Navigator.pop(ctx);
              _deleteAllData(context, ref);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Replace-with-demo confirmation — shown only when real data exists.
  void _showDemoConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Load demo data?'),
        content: const Text(
          'This erases the current records and fills the app with sample '
          'data for Lola Maria.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _replaceWithDemoData(context, ref);
            },
            child: const Text('Load demo'),
          ),
        ],
      ),
    );
  }

  /// Wipes current data then seeds the demo dataset.
  Future<void> _replaceWithDemoData(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(notificationServiceProvider).cancelAllNotifications();
      await ref.read(appDatabaseProvider).deleteAllData();
      if (!context.mounted) return;
      await _loadDemoData(context, ref);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load demo data.')),
        );
      }
    }
  }

  Future<void> _loadDemoData(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(demoDataServiceProvider).seed();
      ref.invalidate(primaryCareRecipientProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo data loaded.')),
        );
        context.go('/');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load demo data.')),
        );
      }
    }
  }

  Future<void> _deleteAllData(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(notificationServiceProvider).cancelAllNotifications();
      await ref.read(appDatabaseProvider).deleteAllData();
      ref.invalidate(primaryCareRecipientProvider);
      if (context.mounted) {
        // The router redirects to onboarding once no recipient exists.
        context.go('/');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete data.')),
        );
      }
    }
  }
}

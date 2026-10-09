import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Notifications'),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Allow Notifications'),
            subtitle: const Text('Enabled'), // Would be dynamic in a real app
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Open OS settings if denied
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
          _buildSectionHeader('Privacy'),
          const ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Your data is stored locally on this device'),
            subtitle: Text('No account or internet required.'),
          ),
          const ListTile(
            leading: Icon(Icons.share),
            title: Text('Sharing reports sends data outside this app'),
          ),

          const Divider(),
          _buildSectionHeader('AI Features'),
          SwitchListTile(
            secondary: const Icon(Icons.auto_awesome),
            title: const Text('AI Summaries'),
            subtitle: const Text('AI summaries are optional. Template-based summaries are always available.'),
            value: false,
            onChanged: (val) {},
          ),

          const Divider(),
          _buildSectionHeader('Health Connect'),
          ListTile(
            leading: const Icon(Icons.health_and_safety),
            title: const Text('Integration Status'),
            subtitle: const Text('Not connected'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const Divider(),
          _buildSectionHeader('Data Management'),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Coming soon'),
            onTap: null, // Disabled
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete All Data', style: TextStyle(color: Colors.red)),
            onTap: () => _showDeleteConfirmation(context),
          ),

          const Divider(),
          _buildSectionHeader('About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('AILaga Version 1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.warning_amber),
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
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All Data?'),
        content: const Text(
          'This action cannot be undone. All your locally stored data will be permanently deleted.\n\nAre you sure you want to proceed?',
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
            child: const Text('CONFIRM DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

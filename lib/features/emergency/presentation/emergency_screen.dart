import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/emergency_providers.dart';
import 'widgets/sos_button.dart';
import 'widgets/countdown_overlay.dart';
import '../../care_recipient/data/care_recipient_providers.dart';
import '../../family_contacts/data/family_contact_providers.dart';
import '../../family_contacts/domain/family_contact_entity.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen> {
  // Emergency services dial 911 (also shown in Settings → Emergency).
  final String _emergencyNumber = '911';

  bool _isCountingDown = false;
  String? _activeEventId;
  String? _statusFeedback;

  Future<void> _handleSosTrigger(String recipientId) async {
    setState(() {
      _isCountingDown = true;
      _statusFeedback = null;
    });

    // We create the event immediately to record the trigger
    try {
      final service = ref.read(emergencyServiceProvider);
      _activeEventId = await service.triggerEmergency(recipientId, 'manual_button');
    } catch (e) {
      debugPrint('Failed to record event: $e');
    }
  }

  void _handleCancel() {
    setState(() {
      _isCountingDown = false;
      _statusFeedback = 'Cancelled';
    });

    if (_activeEventId != null) {
      ref.read(emergencyServiceProvider).cancelEmergency(_activeEventId!);
      _activeEventId = null;
    }
  }

  Future<void> _handleEmergencyCall() async {
    setState(() => _isCountingDown = false);

    final service = ref.read(emergencyServiceProvider);

    try {
      await service.callNumber(_emergencyNumber);
      setState(() => _statusFeedback = 'Dialer opened for $_emergencyNumber');

      if (_activeEventId != null) {
        await service.recordAction(_activeEventId!, 'call_emergency_services', 'dialer_opened');
      }
    } catch (e) {
      setState(() => _statusFeedback = 'Could not open the dialer. Dial $_emergencyNumber manually.');
      if (_activeEventId != null) {
        await service.recordAction(_activeEventId!, 'call_emergency_services', 'failed');
      }
    }
  }

  Future<void> _callContact(FamilyContactEntity contact) async {
    final service = ref.read(emergencyServiceProvider);
    try {
      await service.callNumber(contact.phoneNumber);
      setState(() => _statusFeedback = 'Dialer opened for ${contact.displayName}');
    } catch (e) {
      setState(() => _statusFeedback = 'Could not open the dialer.');
    }
  }

  Future<void> _smsContact(FamilyContactEntity contact) async {
    final service = ref.read(emergencyServiceProvider);
    try {
      await service.openSmsComposer(contact.phoneNumber, 'EMERGENCY SOS: I need help immediately. Please contact me.');
      setState(() => _statusFeedback = 'Text message opened for ${contact.displayName}');
    } catch (e) {
      setState(() => _statusFeedback = 'Could not open messages.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCountingDown) {
      return CountdownOverlay(
        onCancel: _handleCancel,
        onComplete: _handleEmergencyCall,
      );
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final recipientAsync = ref.watch(primaryCareRecipientProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency SOS',
            style: TextStyle(color: cs.error)),
        backgroundColor: cs.error.withValues(alpha: 0.08),
      ),
      body: recipientAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            const Center(child: Text('Something went wrong.')),
        data: (recipient) {
          if (recipient == null) {
            return const Center(child: Text('Please add a care recipient first.'));
          }

          final contactsAsync = ref.watch(familyContactsProvider(recipient.id));

          return Column(
            children: [
              if (_statusFeedback != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: cs.surfaceContainerHighest,
                  child: Text(
                    _statusFeedback!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: cs.onSurface, fontWeight: FontWeight.bold),
                  ),
                ),

              // Big SOS button — natural height; the contacts panel below
              // fills the rest of the screen so there's no dead space.
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SosButton(
                      onTrigger: () => _handleSosTrigger(recipient.id),
                    ),
                    const SizedBox(height: 12),
                    // Who this SOS is for — the responder sees this.
                    Text(
                      recipient.displayName,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (recipient.emergencyInfo?.isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 4),
                        child: Text(
                          recipient.emergencyInfo!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                  ],
                ),
              ),

              // Trusted Contacts Area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border(
                      top: BorderSide(color: cs.outline, width: 2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                        child: Text(
                          'Call family',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: contactsAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, _) => const Center(child: Text('Could not load contacts.')),
                          data: (contacts) {
                            if (contacts.isEmpty) {
                              return const Center(
                                child: Text('No emergency contacts added yet.'),
                              );
                            }
                            return ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: contacts.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (ctx, i) =>
                                  _contactTile(contacts[i]),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// One contact row: name + two big labeled buttons (icon + word).
  Widget _contactTile(FamilyContactEntity c) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // "Sure" green adapts: dark mode needs a lighter green on the dark panel.
    final callColor =
        isDark ? const Color(0xFF7CC98F) : const Color(0xFF1B7F3B);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: cs.primary.withValues(alpha: 0.15),
            child: Text(
              c.displayName.isNotEmpty
                  ? c.displayName.substring(0, 1).toUpperCase()
                  : '?',
              style: TextStyle(
                  color: cs.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.displayName,
                    style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                Text(c.relationship ?? 'Contact',
                    style: TextStyle(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          _contactAction(
            icon: Symbols.phone_rounded,
            label: 'Call',
            color: callColor,
            onTap: () => _callContact(c),
          ),
          const SizedBox(width: 8),
          _contactAction(
            icon: Symbols.message_rounded,
            label: 'Text',
            color: cs.secondary,
            onTap: () => _smsContact(c),
          ),
        ],
      ),
    );
  }

  Widget _contactAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

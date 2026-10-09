import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/emergency_providers.dart';
import 'widgets/sos_button.dart';
import 'widgets/countdown_overlay.dart';
import '../../care_recipient/data/care_recipient_providers.dart';
import '../../family_contacts/data/family_contact_providers.dart';
import '../../family_contacts/domain/family_contact_entity.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen> {
  // Using 911 as default, would ideally be configurable in settings
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
      _statusFeedback = 'SOS cancelled by user';
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
      setState(() => _statusFeedback = 'Failed to open dialer. Please dial $_emergencyNumber manually.');
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
      setState(() => _statusFeedback = 'Failed to open dialer.');
    }
  }

  Future<void> _smsContact(FamilyContactEntity contact) async {
    final service = ref.read(emergencyServiceProvider);
    try {
      await service.openSmsComposer(contact.phoneNumber, 'EMERGENCY SOS: I need help immediately. Please contact me.');
      setState(() => _statusFeedback = 'SMS composer opened for ${contact.displayName}');
    } catch (e) {
      setState(() => _statusFeedback = 'Failed to open SMS composer.');
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
        title: const Text('Emergency SOS', style: TextStyle(color: Colors.red)),
        backgroundColor: Colors.red.withValues(alpha: 0.1),
      ),
      body: recipientAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
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
                  color: cs.secondaryContainer,
                  child: Text(
                    _statusFeedback!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSecondaryContainer, fontWeight: FontWeight.bold),
                  ),
                ),
              
              // Big SOS Button Area
              Expanded(
                flex: 4,
                child: Center(
                  child: SosButton(
                    onTrigger: () => _handleSosTrigger(recipient.id),
                  ),
                ),
              ),

              // Trusted Contacts Area
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Text(
                          'Trusted Contacts',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: contactsAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text('Error loading contacts')),
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
                              itemBuilder: (ctx, i) {
                                final c = contacts[i];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: cs.primaryContainer,
                                    child: Text(c.displayName.isNotEmpty ? c.displayName.substring(0, 1).toUpperCase() : '?'),
                                  ),
                                  title: Text(c.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(c.relationship ?? 'Contact'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.message),
                                        color: cs.primary,
                                        onPressed: () => _smsContact(c),
                                        tooltip: 'Send SOS SMS',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.phone),
                                        color: Colors.green,
                                        onPressed: () => _callContact(c),
                                        tooltip: 'Call Contact',
                                      ),
                                    ],
                                  ),
                                );
                              },
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
}

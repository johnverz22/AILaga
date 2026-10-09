import 'package:url_launcher/url_launcher.dart';
import '../../../core/utilities/uuid_generator.dart';
import '../domain/emergency_entity.dart';
import '../domain/emergency_repository.dart';
import '../domain/emergency_service.dart';

class EmergencyServiceImpl implements EmergencyService {
  final EmergencyRepository _repository;

  EmergencyServiceImpl(this._repository);

  @override
  Future<String> triggerEmergency(String recipientId, String triggerType) async {
    final eventId = UuidGenerator.generate();
    final now = DateTime.now().toUtc();
    
    final event = EmergencyEventEntity(
      id: eventId,
      careRecipientId: recipientId,
      triggeredAt: now,
      triggerType: triggerType,
      actionStatus: 'pending',
      createdAt: now,
    );
    
    await _repository.create(event);
    return eventId;
  }

  @override
  Future<void> cancelEmergency(String eventId) async {
    await _repository.updateStatus(
      eventId,
      'cancelled',
      cancelledAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<void> recordAction(String eventId, String action, String status) async {
    await _repository.updateStatus(
      eventId,
      status,
      selectedAction: action,
    );
  }

  @override
  Future<void> callNumber(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not launch dialer for $phoneNumber');
    }
  }

  @override
  Future<void> openSmsComposer(String phoneNumber, String message) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    // Ensure properly encoded message
    final uri = Uri.parse('sms:$cleanNumber?body=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not launch SMS composer');
    }
  }
}

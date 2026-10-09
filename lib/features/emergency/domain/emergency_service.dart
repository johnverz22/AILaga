abstract class EmergencyService {
  Future<String> triggerEmergency(String recipientId, String triggerType);
  Future<void> cancelEmergency(String eventId);
  Future<void> recordAction(String eventId, String action, String status);
  Future<void> callNumber(String phoneNumber);
  Future<void> openSmsComposer(String phoneNumber, String message);
}

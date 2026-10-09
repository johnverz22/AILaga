import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';

abstract class NotificationService {
  Future<void> init();
  Future<bool> requestPermissions();
  Future<void> scheduleMedicationReminder(String occurrenceId, String medicationName, DateTime time);
  Future<void> scheduleAppointmentReminder(String appointmentId, String purpose, DateTime time);
  Future<void> cancelNotification(String id);
  Future<void> cancelAllNotifications();
  Stream<String> get onNotificationTap;
}

class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final StreamController<String> _tapStreamCtrl = StreamController<String>.broadcast();

  @override
  Stream<String> get onNotificationTap => _tapStreamCtrl.stream;

  @override
  Future<void> init() async {
    tz_data.initializeTimeZones();
    try {
      final timeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZone as String));
    } catch (_) {
      // Fallback
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          _tapStreamCtrl.add(response.payload!);
        }
      },
    );
  }

  @override
  Future<bool> requestPermissions() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImpl != null) {
      final bool? granted = await androidImpl.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  int _generateId(String idStr) {
    return idStr.hashCode & 0x7FFFFFFF;
  }

  @override
  Future<void> scheduleMedicationReminder(String occurrenceId, String medicationName, DateTime time) async {
    if (time.isBefore(DateTime.now())) return;

    final id = _generateId('med_$occurrenceId');
    await _plugin.zonedSchedule(
      id,
      'Medication Reminder',
      'It is time to take $medicationName.',
      tz.TZDateTime.from(time, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_channel',
          'Medication Reminders',
          channelDescription: 'Reminders for taking medications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: '/medications',
    );
  }

  @override
  Future<void> scheduleAppointmentReminder(String appointmentId, String purpose, DateTime time) async {
    final reminderTime = time.subtract(const Duration(minutes: 30));
    if (reminderTime.isBefore(DateTime.now())) return;

    final id = _generateId('appt_$appointmentId');
    await _plugin.zonedSchedule(
      id,
      'Upcoming Appointment',
      'You have an appointment in 30 minutes: $purpose',
      tz.TZDateTime.from(reminderTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'appointment_channel',
          'Appointment Reminders',
          channelDescription: 'Reminders for upcoming appointments',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: '/appointments',
    );
  }

  @override
  Future<void> cancelNotification(String idStr) async {
    await _plugin.cancel(_generateId(idStr));
  }
  
  @override
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}

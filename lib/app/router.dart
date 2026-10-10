import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/care_recipient/presentation/care_recipient_screen.dart';
import '../features/care_recipient/presentation/edit_care_recipient_screen.dart';
import '../features/medications/presentation/medications_screen.dart';
import '../features/medications/presentation/add_medication_screen.dart';
import '../features/medications/presentation/medication_detail_screen.dart';
import '../features/measurements/presentation/measurements_screen.dart';
import '../features/measurements/presentation/add_measurement_screen.dart';
import '../features/measurements/presentation/camera_pulse_screen.dart';
import '../features/appointments/presentation/appointments_screen.dart';
import '../features/appointments/presentation/add_appointment_screen.dart';
import '../features/care_notes/presentation/care_notes_screen.dart';
import '../features/care_notes/presentation/add_care_note_screen.dart';
import '../features/care_brief/presentation/care_brief_screen.dart';
import '../features/handover/presentation/handover_screen.dart';
import '../features/emergency/presentation/emergency_screen.dart';
import '../features/family_contacts/presentation/family_contacts_screen.dart';
import '../features/family_contacts/presentation/add_family_contact_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/presentation/ai_privacy_panel.dart';
import '../features/settings/presentation/health_connect_screen.dart';
import 'sos_sensor_guard.dart';
import '../features/ai_setup/presentation/ai_setup_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/capture/presentation/voice_capture_screen.dart';
import '../features/capture/presentation/snap_capture_screen.dart';
import '../features/ask/presentation/ask_screen.dart';
import '../features/onboarding/presentation/initialization_screen.dart';
import 'app_ready_provider.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

// Shell Navigation Widget — redesigned per AILaga v2 spec §4.2
// Tabs: Ngayon · Ulat · 🎙 Capture (center FAB) · Tanong · Higit pa
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Get the current location to determine selected tab
    final location = GoRouterState.of(context).uri.path;

    int getIndex() {
      if (location.startsWith('/medications') ||
          location.startsWith('/measurements') ||
          location.startsWith('/appointments') ||
          location.startsWith('/care-notes') ||
          location.startsWith('/settings') ||
          location.startsWith('/family-contacts') ||
          location.startsWith('/care-recipient') ||
          location.startsWith('/ai-privacy')) {
        return 4;
      }
      return 0; // default to Ngayon (Home)
    }

    void go(int index) {
      switch (index) {
        case 0:
          context.go('/');
        case 1:
          // Pushed, not a shell tab — full screen without the nav bar so
          // the action buttons sit at the screen bottom.
          context.push('/brief');
        case 2:
          // Pushed, not a shell tab — full screen without the nav bar,
          // back button returns to the last tab.
          context.push('/capture');
        case 3:
          context.push('/ask');
        case 4:
          context.push('/settings');
      }
    }

    return Scaffold(
      body: SosSensorGuard(child: child),
      bottomNavigationBar: _ModernNavBar(
        selectedIndex: getIndex(),
        onSelect: go,
      ),
    );
  }
}

/// Elder-friendly floating nav: tall pill bar, large icons with words,
/// raised teal mic button in the middle (the app's primary action).
/// Border only — no soft shadows (UI spec). All targets ≥ 48dp.
class _ModernNavBar extends StatelessWidget {
  static const _teal = Color(0xFF0B6B6B);
  static const _inactive = Color(0xFF5E5748); // darker gray — readable

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _ModernNavBar({required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.viewPaddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 10 + bottomPad),
      child: SizedBox(
        height: 104,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Pill bar — the center slot is empty space for the mic button.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 78,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFD9D2C3), width: 2),
                ),
                child: Row(
                  children: [
                    _item(0, Symbols.today_rounded, Symbols.today_rounded, 'Today'),
                    _item(1, Symbols.summarize_rounded, Symbols.summarize_rounded,
                        'Reports'),
                    const Expanded(child: SizedBox()),
                    _item(3, Symbols.chat_bubble_rounded, Symbols.chat_bubble_rounded,
                        'Ask'),
                    _item(4, Symbols.settings_rounded, Symbols.settings_rounded, 'Settings'),
                  ],
                ),
              ),
            ),
            // Raised center Speak button — biggest target on the bar.
            Positioned(
              bottom: 32,
              child: SizedBox(
                width: 72,
                height: 72,
                child: Material(
                  shape: const CircleBorder(
                      side: BorderSide(color: Colors.white, width: 4)),
                  color: _teal,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onSelect(2),
                    child: const Icon(Symbols.mic_rounded,
                        color: Colors.white, size: 36),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
      int index, IconData icon, IconData selectedIcon, String label) {
    final selected = selectedIndex == index;
    final color = selected ? _teal : _inactive;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => onSelect(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, color: color, size: 32),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final path = state.uri.path;

      // These routes are always passthrough — never redirect away from them.
      if (path == '/splash' ||
          path == '/initialization' ||
          path == '/onboarding' ||
          path == '/emergency') {
        return null;
      }

      // Read the combined readiness state (care recipient + device + model).
      final ready = await ref.read(appReadyProvider.future);

      switch (ready) {
        case AppReadyState.needsOnboarding:
          return '/onboarding';

        case AppReadyState.needsModelSetup:
          // Model not yet installed on a supported device — gate until done.
          return '/initialization';

        case AppReadyState.unsupportedDevice:
        case AppReadyState.modelReady:
          // Proceed normally. Prevent going back to onboarding if set up.
          if (path == '/onboarding') return '/';
          return null;
      }
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/initialization',
        builder: (context, state) => const InitializationScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/emergency',
        builder: (context, state) => const EmergencyScreen(),
      ),
      // Capture & Ask: full-screen pages WITHOUT the bottom nav — the
      // action buttons / message box sit at the screen bottom and the
      // app bar shows a back button. Reached via the Speak/Ask nav items.
      GoRoute(
        path: '/capture',
        builder: (context, state) => const VoiceCaptureScreen(),
      ),
      GoRoute(
        path: '/capture/snap',
        builder: (context, state) => const SnapCaptureScreen(),
      ),
      GoRoute(
        path: '/ask',
        builder: (context, state) => const AskScreen(),
      ),
      // Reports & its forward screens — also nav-free pages so their
      // action buttons can sit at the bottom of the screen.
      GoRoute(
        path: '/brief',
        builder: (context, state) => const CareBriefScreen(),
      ),
      GoRoute(
        path: '/handover',
        builder: (context, state) => const HandoverScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // Tab 0: Ngayon (Today)
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          // Higit pa (More) sub-routes — kept in shell
          GoRoute(
            path: '/medications',
            builder: (context, state) => const MedicationsScreen(),
          ),
          GoRoute(
            path: '/measurements',
            builder: (context, state) => const MeasurementsScreen(),
          ),
          GoRoute(
            path: '/appointments',
            builder: (context, state) => const AppointmentsScreen(),
          ),
          GoRoute(
            path: '/care-recipient',
            builder: (context, state) => const CareRecipientScreen(),
          ),
          GoRoute(
            path: '/care-notes',
            builder: (context, state) => const CareNotesScreen(),
          ),
          GoRoute(
            path: '/family-contacts',
            builder: (context, state) => const FamilyContactsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/ai-privacy',
            builder: (context, state) => const AiPrivacyPanel(),
          ),
          GoRoute(
            path: '/ai-setup',
            builder: (context, state) => const AiSetupScreen(),
          ),
          GoRoute(
            path: '/health-connect',
            builder: (context, state) => const HealthConnectScreen(),
          ),
        ],
      ),
      // Screens without bottom navigation (full screen forms)
      GoRoute(
        path: '/care-recipient/edit',
        builder: (context, state) => const EditCareRecipientScreen(),
      ),
      GoRoute(
        path: '/medications/add',
        builder: (context, state) {
          final extra = state.extra;
          String recipientId;
          String? scheduleId;
          Map<String, dynamic>? initialValues;
          if (extra is String) {
            recipientId = extra;
          } else if (extra is Map) {
            recipientId = extra['recipientId'] as String;
            scheduleId = extra['scheduleId'] as String?;
            initialValues = extra['initialValues'] as Map<String, dynamic>?;
          } else {
            recipientId = '';
          }
          return AddMedicationScreen(
            recipientId: recipientId,
            scheduleId: scheduleId,
            initialValues: initialValues,
          );
        },
      ),
      GoRoute(
        path: '/medications/:id',
        builder: (context, state) => MedicationDetailScreen(
          medicationId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/measurements/add',
        builder: (context, state) {
          final extra = state.extra;
          String recipientId = '';
          Map<String, dynamic>? initialValues;
          if (extra is String) {
            recipientId = extra;
          } else if (extra is Map) {
            recipientId = extra['recipientId'] as String? ?? '';
            initialValues = extra['initialValues'] as Map<String, dynamic>?;
          }
          return AddMeasurementScreen(
            recipientId: recipientId,
            initialValues: initialValues,
          );
        },
      ),
      GoRoute(
        path: '/measurements/pulse-cam',
        builder: (context, state) {
          final recipientId =
              state.extra is String ? state.extra as String : '';
          return CameraPulseScreen(recipientId: recipientId);
        },
      ),
      GoRoute(
        path: '/appointments/add',
        builder: (context, state) {
          final extra = state.extra;
          String recipientId = '';
          String? appointmentId;
          Map<String, dynamic>? initialValues;
          if (extra is String) {
            recipientId = extra;
          } else if (extra is Map) {
            recipientId = extra['recipientId'] as String;
            appointmentId = extra['appointmentId'] as String?;
            initialValues = extra['initialValues'] as Map<String, dynamic>?;
          }
          return AddAppointmentScreen(
            recipientId: recipientId,
            appointmentId: appointmentId,
            initialValues: initialValues,
          );
        },
      ),
      GoRoute(
        path: '/care-notes/add',
        builder: (context, state) {
          final extra = state.extra;
          String recipientId = '';
          Map<String, dynamic>? initialValues;
          if (extra is String) {
            recipientId = extra;
          } else if (extra is Map) {
            recipientId = extra['recipientId'] as String? ?? '';
            initialValues = extra['initialValues'] as Map<String, dynamic>?;
          }
          return AddCareNoteScreen(
            recipientId: recipientId,
            initialValues: initialValues,
          );
        },
      ),
      GoRoute(
        path: '/family-contacts/add',
        builder: (context, state) {
          final extra = state.extra;
          String recipientId;
          String? contactId;
          if (extra is String) {
            recipientId = extra;
          } else if (extra is Map) {
            recipientId = extra['recipientId'] as String;
            contactId = extra['contactId'] as String?;
          } else {
            recipientId = '';
          }
          return AddFamilyContactScreen(
            recipientId: recipientId,
            contactId: contactId,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
});

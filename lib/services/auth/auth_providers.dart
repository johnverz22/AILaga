import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';
import 'firebase_auth_service.dart';

/// Singleton [AuthService] backed by Firebase.
///
/// Override in tests by using `ProviderContainer(overrides: [...])` with a
/// mock [AuthService].
final authServiceProvider = Provider<AuthService>((ref) {
  return FirebaseAuthService();
});

/// Stream of Firebase [User] auth state changes.
///
/// Emits the current [User] when signed in, or `null` when signed out.
/// Widgets should `watch` this to reactively respond to auth changes.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Convenience boolean: `true` when a user is currently signed in.
///
/// Derived from [authStateProvider] so it stays in sync automatically.
final isSignedInProvider = Provider<bool>((ref) {
  // AsyncValue.value is null while loading or on error — treat as signed out.
  return ref.watch(authStateProvider).value != null;
});

/// The signed-in user's Firebase UID, or `null` when signed out.
///
/// Use this as the `firebase_uid` row-owner key for all Supabase operations.
/// NEVER pass email or display name as a row-owner key.
final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).value?.uid;
});

/// The signed-in user's display email, or `null` when signed out.
///
/// Safe to show in UI (e.g. "Signed in as user@example.com").
final currentEmailProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).value?.email;
});

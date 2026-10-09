// SECURITY NOTE:
// The Supabase anon key and the Firebase Android client ID are intentionally
// included in source code. They are *publishable* (not secret) credentials:
//   • Supabase anon key  — access is gated by Row-Level Security (RLS); the
//     key alone cannot read or modify any user's data without a valid JWT.
//   • Firebase client ID — security is enforced by the SHA-1/SHA-256
//     certificate fingerprint restrictions set in the Firebase console.
//
// FIREBASE API KEY (in android/app/google-services.json):
//   The Firebase API key (`current_key` in google-services.json) is
//   intentionally committed to source control. Firebase API keys are
//   designed to be public and are restricted in two ways:
//     1. Package-name restriction: only requests from com.ailaga.ailaga
//        are accepted.
//     2. SHA-1/SHA-256 fingerprint restriction: only signed APKs whose
//        certificate matches the registered fingerprint are accepted.
//   The key cannot be used to access Firebase data directly — access is
//   controlled by Firebase Authentication and Firestore/Storage rules.
//   See: https://firebase.google.com/docs/projects/api-keys
//
// HEALTH DATA ISOLATION:
//   No health data (medication names, diagnoses, measurements, care notes,
//   or appointment details) is ever sent to Firebase. Firebase handles
//   only account identity (UID, email, display name). All health data
//   flows exclusively to Supabase, protected by RLS policies that ensure
//   each user can only access their own rows.
class AuthConstants {
  AuthConstants._();

  static const supabaseUrl = 'https://sgistmejqsbssutscbda.supabase.co';
  static const supabaseAnonKey =
      'sb_publishable_iFKfTlTpn1FfQtQbhsH7jA_Kea8UJOW';
  static const firebaseProjectId = 'ailaga-d77b8';

  // OAuth 2.0 Android client ID from google-services.json.
  static const androidClientId =
      '884019261468-djo0avq5cpufn1dfsmrg456tuk65m2ni.apps.googleusercontent.com';

  // flutter_secure_storage key names.
  static const secureKeyFirebaseUid = 'firebase_uid';
  static const secureKeyLastSyncAt = 'last_sync_at';
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/errors/app_exception.dart';
import 'auth_constants.dart';
import 'auth_service.dart';

/// Firebase implementation of [AuthService].
///
/// Responsibilities:
///   - Delegates auth operations to [FirebaseAuth].
///   - Maps [FirebaseAuthException] codes to user-friendly [AuthException]s.
///   - Stores the Firebase UID in [FlutterSecureStorage] on sign-in and
///     clears it on sign-out so the Sync service can use it as the row owner.
///
/// IMPORTANT: This service is identity-only.
/// Health/care data is NEVER read or written through this class.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    FlutterSecureStorage? secureStorage,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _storage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            ),
        _googleSignIn = googleSignIn ??
            GoogleSignIn(clientId: AuthConstants.androidClientId);

  final FirebaseAuth _auth;
  final FlutterSecureStorage _storage;
  final GoogleSignIn _googleSignIn;

  // ---------------------------------------------------------------------------
  // Interface getters
  // ---------------------------------------------------------------------------

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  bool get isSignedIn => _auth.currentUser != null;

  // ---------------------------------------------------------------------------
  // Sign-in / sign-up
  // ---------------------------------------------------------------------------

  @override
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _storeUid(credential.user?.uid);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (e) {
      throw AuthException('Sign in failed. Please try again.', cause: e);
    }
  }

  @override
  Future<UserCredential> createAccountWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _storeUid(credential.user?.uid);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (e) {
      throw AuthException('Account creation failed. Please try again.',
          cause: e);
    }
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        // User dismissed the account picker — silent return, not an error.
        return null;
      }

      final googleAuth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _storeUid(userCredential.user?.uid);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (e) {
      throw AuthException('Google sign in failed. Please try again.', cause: e);
    }
  }

  // ---------------------------------------------------------------------------
  // Sign-out
  // ---------------------------------------------------------------------------

  @override
  Future<void> signOut() async {
    try {
      // Sign out from Google (if that method was used) to clear account picker.
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
      await _clearUid();
    } catch (e) {
      // Sign-out errors are non-fatal; still clear local state.
      debugPrint('[D] FirebaseAuthService: signOut error (continuing): $e');
      await _clearUid();
    }
  }

  // ---------------------------------------------------------------------------
  // Password reset
  // ---------------------------------------------------------------------------

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (e) {
      throw AuthException(
          'Could not send reset email. Please check your connection.',
          cause: e);
    }
  }

  // ---------------------------------------------------------------------------
  // Secure storage helpers
  //
  // SECURITY: The Firebase UID is stored in flutter_secure_storage, which
  // uses Android Keystore (API 23+) / iOS Keychain for encryption at rest.
  // The UID is used as the row-owner key in Supabase — never as a display
  // value and never written to logs or analytics.
  // ---------------------------------------------------------------------------

  Future<void> _storeUid(String? uid) async {
    if (uid == null) return;
    try {
      await _storage.write(
        key: AuthConstants.secureKeyFirebaseUid,
        value: uid,
      );
    } catch (e) {
      // Storage failure is non-fatal — auth is still valid.
      debugPrint('[D] FirebaseAuthService: could not persist UID: $e');
    }
  }

  Future<void> _clearUid() async {
    try {
      await _storage.delete(key: AuthConstants.secureKeyFirebaseUid);
    } catch (e) {
      debugPrint('[D] FirebaseAuthService: could not clear UID: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // FirebaseAuthException → AuthException mapping
  // ---------------------------------------------------------------------------

  /// Maps Firebase error codes to user-readable messages.
  ///
  /// SECURITY: Only the error *code* (e.g. "wrong-password") is logged —
  /// never the email address, password, or Firebase UID.
  /// [debugPrint] is a no-op in release builds (kReleaseMode == true), so
  /// no auth metadata is written to production logs or crash reporters.
  AuthException _mapFirebaseError(FirebaseAuthException e) {
    // Only log the code, never the email or UID, to avoid PII in logs.
    debugPrint('[D] FirebaseAuthService: Firebase error code=${e.code}');

    final message = switch (e.code) {
      'wrong-password' ||
      'invalid-credential' =>
        'Incorrect password. Please try again.',
      'user-not-found' => 'No account found with this email.',
      'email-already-in-use' => 'An account already exists with this email.',
      'weak-password' => 'Password is too weak. Use at least 8 characters.',
      'invalid-email' => 'That email address doesn\'t look right.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' =>
        'Too many attempts. Please wait a moment and try again.',
      'network-request-failed' =>
        'No internet connection. Please check your network.',
      'requires-recent-login' =>
        'Please sign out and sign in again to continue.',
      'operation-not-allowed' => 'This sign-in method is not enabled.',
      _ => 'Something went wrong. Please try again.',
    };

    return AuthException(message, code: e.code, cause: e);
  }
}

import 'package:firebase_auth/firebase_auth.dart';

/// Abstract interface for Firebase Authentication.
///
/// Health data is NEVER sent through this service — it is identity-only.
/// Errors are always mapped to [AuthException] with user-friendly messages.
abstract class AuthService {
  /// The currently signed-in Firebase [User], or `null` when signed out.
  User? get currentUser;

  /// Stream that emits [User] on sign-in and `null` on sign-out.
  Stream<User?> get authStateChanges;

  /// `true` when a user is currently signed in.
  bool get isSignedIn;

  /// Signs in with [email] and [password].
  /// Throws [AuthException] on failure.
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  );

  /// Creates a new account with [email] and [password].
  /// Throws [AuthException] on failure.
  Future<UserCredential> createAccountWithEmailAndPassword(
    String email,
    String password,
  );

  /// Starts the Google Sign-In flow and completes Firebase authentication.
  /// Throws [AuthException] on failure.
  /// Returns `null` silently when the user cancels the account picker.
  Future<UserCredential?> signInWithGoogle();

  /// Signs out the current user and clears the locally stored UID.
  Future<void> signOut();

  /// Sends a password-reset email to [email].
  /// Throws [AuthException] on failure.
  Future<void> sendPasswordResetEmail(String email);
}

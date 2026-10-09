// test/services/auth/auth_service_test.dart
//
// Unit tests for [FirebaseAuthService].
//
// Strategy:
//   • [FirebaseAuth], [FlutterSecureStorage], and [GoogleSignIn] are injected
//     via the constructor so we can supply mocks without touching the Firebase
//     SDK globals.
//   • [mocktail] is used for mocking. We create thin Fake/Mock classes for the
//     Firebase types that are sealed or final.
//   • All tests are pure Dart — no widget or platform code runs.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ailaga/core/errors/app_exception.dart';
import 'package:ailaga/services/auth/firebase_auth_service.dart';
import 'package:ailaga/services/auth/auth_constants.dart';

// ---------------------------------------------------------------------------
// Mocks & Fakes
// ---------------------------------------------------------------------------

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

/// Minimal fake for GoogleSignIn — only the methods we exercise.
class FakeGoogleSignIn extends Fake {
  // We never call GoogleSignIn in these tests (Google sign-in tests are
  // integration-level). Return a no-op stub so construction doesn't fail.
  Future<bool> isSignedIn() async => false;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Build a [FirebaseAuthService] with injected mocks.
FirebaseAuthService _makeService({
  required MockFirebaseAuth auth,
  MockFlutterSecureStorage? storage,
}) {
  return FirebaseAuthService(
    firebaseAuth: auth,
    secureStorage: storage ?? MockFlutterSecureStorage(),
  );
}

/// Returns a [FirebaseAuthException] with the given code.
FirebaseAuthException _fbEx(String code) =>
    FirebaseAuthException(code: code, message: 'test error');

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockFirebaseAuth mockAuth;
  late MockFlutterSecureStorage mockStorage;
  late MockUserCredential mockCredential;
  late MockUser mockUser;

  setUpAll(() {
    // Register fallback values required by mocktail for any() matchers.
    registerFallbackValue(const AuthCredential(
      providerId: 'password',
      signInMethod: 'password',
    ));
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockStorage = MockFlutterSecureStorage();
    mockCredential = MockUserCredential();
    mockUser = MockUser();

    // Default: storage operations succeed silently.
    when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    when(() => mockStorage.delete(key: any(named: 'key')))
        .thenAnswer((_) async {});

    // Default: user has a UID.
    when(() => mockUser.uid).thenReturn('test-uid-123');
    when(() => mockCredential.user).thenReturn(mockUser);
  });

  // -------------------------------------------------------------------------
  // Sign-in success
  // -------------------------------------------------------------------------

  group('signInWithEmailAndPassword', () {
    test('returns UserCredential on success', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: 'user@test.com',
            password: 'password123',
          )).thenAnswer((_) async => mockCredential);

      final svc = _makeService(auth: mockAuth, storage: mockStorage);
      final result = await svc.signInWithEmailAndPassword(
        'user@test.com',
        'password123',
      );

      expect(result, equals(mockCredential));
    });

    test('stores Firebase UID in secure storage on success', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCredential);

      final svc = _makeService(auth: mockAuth, storage: mockStorage);
      await svc.signInWithEmailAndPassword('user@test.com', 'password123');

      verify(() => mockStorage.write(
            key: AuthConstants.secureKeyFirebaseUid,
            value: 'test-uid-123',
          )).called(1);
    });

    test('maps wrong-password to user-friendly AuthException', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(_fbEx('wrong-password'));

      final svc = _makeService(auth: mockAuth, storage: mockStorage);

      expect(
        () => svc.signInWithEmailAndPassword('user@test.com', 'wrongpass'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Incorrect password'),
          ),
        ),
      );
    });

    test('maps invalid-credential to same message as wrong-password', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(_fbEx('invalid-credential'));

      final svc = _makeService(auth: mockAuth, storage: mockStorage);

      expect(
        () => svc.signInWithEmailAndPassword('user@test.com', 'wrongpass'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Incorrect password'),
          ),
        ),
      );
    });

    test('maps user-not-found to user-friendly AuthException', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(_fbEx('user-not-found'));

      final svc = _makeService(auth: mockAuth, storage: mockStorage);

      expect(
        () => svc.signInWithEmailAndPassword('nobody@test.com', 'pass'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('No account found'),
          ),
        ),
      );
    });

    test('maps email-already-in-use to user-friendly AuthException', () async {
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(_fbEx('email-already-in-use'));

      final svc = _makeService(auth: mockAuth, storage: mockStorage);

      expect(
        () => svc.createAccountWithEmailAndPassword('exists@test.com', 'pass1234'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('already exists'),
          ),
        ),
      );
    });

    test('maps network-request-failed to user-friendly AuthException', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(_fbEx('network-request-failed'));

      final svc = _makeService(auth: mockAuth, storage: mockStorage);

      expect(
        () => svc.signInWithEmailAndPassword('user@test.com', 'pass'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('No internet connection'),
          ),
        ),
      );
    });

    test('maps unknown error code to generic user-friendly message', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(_fbEx('some-unknown-code'));

      final svc = _makeService(auth: mockAuth, storage: mockStorage);

      expect(
        () => svc.signInWithEmailAndPassword('user@test.com', 'pass'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Something went wrong'),
          ),
        ),
      );
    });
  });

  // -------------------------------------------------------------------------
  // Sign-out
  // -------------------------------------------------------------------------

  group('signOut', () {
    test('clears UID from secure storage on sign-out', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      // GoogleSignIn is not injected in this test — we rely on the internal
      // mock path (isSignedIn check). Use a service with a stub storage only.
      final svc = _makeService(auth: mockAuth, storage: mockStorage);
      await svc.signOut();

      verify(() => mockStorage.delete(
            key: AuthConstants.secureKeyFirebaseUid,
          )).called(1);
    });

    test('still clears UID if sign-out throws', () async {
      when(() => mockAuth.signOut())
          .thenThrow(Exception('sign out network error'));

      final svc = _makeService(auth: mockAuth, storage: mockStorage);
      // Should not throw.
      await svc.signOut();

      verify(() => mockStorage.delete(
            key: AuthConstants.secureKeyFirebaseUid,
          )).called(1);
    });
  });

  // -------------------------------------------------------------------------
  // isSignedIn / auth state
  // -------------------------------------------------------------------------

  group('isSignedIn', () {
    test('returns false when currentUser is null', () {
      when(() => mockAuth.currentUser).thenReturn(null);

      final svc = _makeService(auth: mockAuth, storage: mockStorage);
      expect(svc.isSignedIn, isFalse);
    });

    test('returns true when currentUser is set', () {
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      final svc = _makeService(auth: mockAuth, storage: mockStorage);
      expect(svc.isSignedIn, isTrue);
    });
  });

  group('authStateChanges', () {
    test('emits User on sign-in and null on sign-out', () async {
      final controller = StreamController<User?>();
      when(() => mockAuth.authStateChanges())
          .thenAnswer((_) => controller.stream);

      final svc = _makeService(auth: mockAuth, storage: mockStorage);
      final events = <User?>[];
      final sub = svc.authStateChanges.listen(events.add);

      controller.add(mockUser);
      controller.add(null);
      await Future<void>.delayed(Duration.zero);

      expect(events, [mockUser, null]);
      await sub.cancel();
      await controller.close();
    });
  });

  // -------------------------------------------------------------------------
  // createAccountWithEmailAndPassword
  // -------------------------------------------------------------------------

  group('createAccountWithEmailAndPassword', () {
    test('returns UserCredential on success', () async {
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: 'new@test.com',
            password: 'strongpass123',
          )).thenAnswer((_) async => mockCredential);

      final svc = _makeService(auth: mockAuth, storage: mockStorage);
      final result = await svc.createAccountWithEmailAndPassword(
        'new@test.com',
        'strongpass123',
      );

      expect(result, equals(mockCredential));
    });

    test('stores UID in secure storage on account creation', () async {
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCredential);

      final svc = _makeService(auth: mockAuth, storage: mockStorage);
      await svc.createAccountWithEmailAndPassword('new@test.com', 'pass123');

      verify(() => mockStorage.write(
            key: AuthConstants.secureKeyFirebaseUid,
            value: 'test-uid-123',
          )).called(1);
    });
  });
}

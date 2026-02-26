import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';

// ─── Auth State Provider ───
// Watches Firebase auth state changes and emits User? stream
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// ─── Firestore Service Provider ───
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// ─── Auth Service Provider ───
final authServiceProvider = Provider<AuthService>((ref) {
  final firestore = ref.read(firestoreServiceProvider);
  return AuthService(firestore);
});

// ─── Auth Service ───
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore;

  AuthService(this._firestore);

  User? get currentUser => _auth.currentUser;

  /// Sign in with email & password
  /// Marks onboarding as complete (existing users skip onboarding)
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Existing users who sign in have already been through the app,
    // so mark onboarding as complete to skip it
    if (credential.user != null) {
      try {
        await _firestore.updateUserProfile({'onboardingComplete': true});
      } catch (_) {
        // Ignore if profile doesn't exist yet
      }
    }

    return credential;
  }

  /// Create a new account with email & password
  /// Also creates a user profile document in Firestore
  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Update display name
    await credential.user?.updateDisplayName(name.trim());
    await credential.user?.reload();

    // Create Firestore user profile
    if (credential.user != null) {
      await _firestore.createUserProfile(
        uid: credential.user!.uid,
        displayName: name.trim(),
        email: email.trim(),
      );
    }

    return credential;
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get a user-friendly error message from FirebaseAuthException
  static String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}

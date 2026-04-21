import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Handles all Firebase Auth operations.
///
/// Account merging: when a social sign-in returns
/// [FirebaseAuthException] with code 'account-exists-with-different-credential',
/// this service fetches the existing sign-in methods and links the new
/// credential to the existing account automatically.
class AuthService {
  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ── Google Sign-In ─────────────────────────────────────────────────────────
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw const _CancelledException();

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _signInWithCredentialMerging(credential);
  }

  // ── Apple Sign-In ──────────────────────────────────────────────────────────
  Future<UserCredential> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    return _signInWithCredentialMerging(oauthCredential);
  }

  // ── Email / Password ───────────────────────────────────────────────────────
  Future<UserCredential> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> createAccountWithEmail(
    String email,
    String password,
  ) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  // ── Sign out ───────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ── Account merging ────────────────────────────────────────────────────────
  /// Signs in with [credential] and, if the email already exists with a
  /// different provider, links both credentials to a single account.
  Future<UserCredential> _signInWithCredentialMerging(
    AuthCredential credential,
  ) async {
    try {
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code != 'account-exists-with-different-credential') rethrow;

      final email = e.email;
      final pendingCredential = e.credential;
      if (email == null || pendingCredential == null) rethrow;

      // fetchSignInMethodsForEmail is deprecated (email enumeration risk).
      // Firebase provides the email + pending credential in the exception.
      // The UI will prompt the user to sign in with their original provider
      // so we can link the new credential to the existing account.
      throw AccountMergeRequiredException(
        email: email,
        pendingCredential: pendingCredential,
      );
    }
  }

  /// Called after the user has signed in with their existing provider.
  /// Links the pending social credential to their account.
  Future<void> linkPendingCredential(AuthCredential pending) async {
    await _auth.currentUser?.linkWithCredential(pending);
  }
}

// ── Exceptions ─────────────────────────────────────────────────────────────
class _CancelledException implements Exception {
  const _CancelledException();
  @override
  String toString() => 'Sign-in cancelled by user.';
}

class AccountMergeRequiredException implements Exception {
  const AccountMergeRequiredException({
    required this.email,
    required this.pendingCredential,
  });

  final String email;
  final AuthCredential pendingCredential;

  @override
  String toString() => 'Account merge required for $email';
}

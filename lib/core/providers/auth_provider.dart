import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../services/user_service.dart';
import '../services/iap_service.dart';
import '../services/wallet_service.dart';

// ── Service providers ──────────────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((_) => AuthService());
final biometricServiceProvider = Provider<BiometricService>((_) => BiometricService());
final userServiceProvider = Provider<UserService>((_) => UserService());
final walletServiceProvider = Provider<WalletService>((_) => WalletService());
final iapServiceProvider = Provider<IapService>((_) => IapService());

// ── Auth state ─────────────────────────────────────────────────────────────
/// Live Firebase Auth stream — null when signed out.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Convenience: true when a Firebase session is active.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).valueOrNull != null;
});

// ── Biometric availability ─────────────────────────────────────────────────
final biometricAvailableProvider = FutureProvider<bool>((ref) {
  return ref.read(biometricServiceProvider).isAvailable();
});

// ── Sign-in notifier ───────────────────────────────────────────────────────
/// Manages the async state of a sign-in operation.
/// UI listens to this for loading spinners and error messages.
class SignInNotifier extends StateNotifier<AsyncValue<void>> {
  SignInNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> signInWithGoogle() => _run(
        () => _ref.read(authServiceProvider).signInWithGoogle(),
      );

  Future<bool> signInWithApple() => _run(
        () => _ref.read(authServiceProvider).signInWithApple(),
      );

  Future<bool> signInWithEmail(String email, String password) => _run(
        () => _ref.read(authServiceProvider).signInWithEmail(email, password),
      );

  Future<bool> createAccount(String email, String password) => _run(
        () => _ref
            .read(authServiceProvider)
            .createAccountWithEmail(email, password),
      );

  Future<bool> sendPasswordReset(String email) => _run(
        () => _ref.read(authServiceProvider).sendPasswordResetEmail(email),
      );

  Future<bool> signInWithBiometric(String localizedReason) async {
    state = const AsyncValue.loading();
    final authenticated = await _ref
        .read(biometricServiceProvider)
        .authenticate(reason: localizedReason);
    if (authenticated) {
      state = const AsyncValue.data(null);
      return true;
    }
    state = AsyncValue.error('Biometric auth failed', StackTrace.current);
    return false;
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    await _ref.read(authServiceProvider).signOut();
    state = const AsyncValue.data(null);
  }

  /// Returns true on success, sets error state on failure.
  Future<bool> _run(Future<dynamic> Function() action) async {
    state = const AsyncValue.loading();
    try {
      await action();
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final signInProvider =
    StateNotifierProvider<SignInNotifier, AsyncValue<void>>(
  (ref) => SignInNotifier(ref),
);

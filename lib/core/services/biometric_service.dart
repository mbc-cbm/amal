import 'package:local_auth/local_auth.dart';

/// Wraps local_auth for biometric / device credential authentication.
class BiometricService {
  BiometricService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  /// True if the device supports any form of biometric or device credential.
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Returns the list of enrolled biometric types (Face, Fingerprint, Iris).
  Future<List<BiometricType>> enrolledTypes() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Prompts the user to authenticate.
  /// [reason] is shown in the system biometric dialog.
  /// Returns true on success, false on failure or cancel.
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // allow device PIN / pattern as fallback
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// Cancels any in-progress authentication dialog.
  Future<void> cancel() => _auth.stopAuthentication();
}

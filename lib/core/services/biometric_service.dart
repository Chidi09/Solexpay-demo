import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Checks if the device has biometric hardware (Face ID, Touch ID, or fingerprint scanner)
  Future<bool> get isBiometricSupported async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Checks if the user has actually enrolled any biometrics on the device
  Future<bool> get hasBiometricsEnrolled async {
    try {
      final List<BiometricType> availableBiometrics =
          await _auth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Prompts the user to authenticate using biometrics.
  /// Returns [true] if authenticated successfully, [false] otherwise.
  Future<bool> authenticate({
    String localizedReason = 'Please authenticate to proceed',
  }) async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: localizedReason,
      );
      return didAuthenticate;
    } on PlatformException catch (_) {
      // Typically happens if the app is put to background while authenticating, 
      // or if the user cancels out too fast.
      return false;
    }
  }
}

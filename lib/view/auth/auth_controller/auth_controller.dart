import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

import '../ui/storage.dart';

class AuthController extends GetxController {
  final LocalAuthentication auth = LocalAuthentication();
  var isAuthenticated = false.obs;
  var statusMessage = "Not Authenticated".obs;

  /// First time setup (Enable fingerprint)
  Future<void> setupBiometric() async {
    try {
      bool canCheck = await auth.canCheckBiometrics;
      if (!canCheck) {
        statusMessage.value = "Device does not support biometrics";
        return;
      }

      bool didAuthenticate = await auth.authenticate(
        localizedReason: "Register your fingerprint to lock this app",
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (didAuthenticate) {
        AppStorage.setBiometricEnabled(true);
        statusMessage.value = "Fingerprint Lock Enabled";
      } else {
        statusMessage.value = "Setup Failed";
      }
    } catch (e) {
      statusMessage.value = "Error: $e";
    }
  }

  /// Verify on every app launch
  Future<void> verifyBiometric() async {
    if (!AppStorage.isBiometricEnabled) {
      statusMessage.value = "Fingerprint not setup yet";
      return;
    }

    try {
      bool didAuthenticate = await auth.authenticate(
        localizedReason: "Unlock app using fingerprint",
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (didAuthenticate) {
        isAuthenticated.value = true;
        statusMessage.value = "App Unlocked";
      } else {
        statusMessage.value = "Authentication Failed";
      }
    } catch (e) {
      statusMessage.value = "Error: $e";
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

/// Controller to handle biometric authentication logic
class BiometricController extends GetxController {
  final LocalAuthentication auth = LocalAuthentication();

  /// Reactive variable for authentication status
  var authStatus = "Not Authenticated".obs;

  /// Function to authenticate user with biometrics
  Future<void> authenticate() async {
    try {
      bool isBiometricAvailable = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();

      if (!isBiometricAvailable || !isDeviceSupported) {
        authStatus.value = "Biometric not available on this device";
        return;
      }

      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      authStatus.value = didAuthenticate ? "Authenticated ✅" : "Authentication Failed ❌";
    } catch (e) {
      authStatus.value = "Error: $e";
    }
  }
}

/// Biometric Authentication Page
class BiometricAuthPage extends StatelessWidget {
  BiometricAuthPage({super.key});

  /// Initialize controller
  final BiometricController controller = Get.put(BiometricController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Biometric Authentication")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text(
                  controller.authStatus.value,
                  style: const TextStyle(fontSize: 18),
                )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.authenticate,
              child: const Text("Authenticate"),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/auth/auth_controller/auth_controller.dart';
import 'package:folderlockerapp/view/auth/ui/storage.dart';
import 'package:get/get.dart';

class LockScreen extends StatelessWidget {
  final AuthController controller = Get.put(AuthController());

  LockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Agar already biometric enabled hai → start verification
    if (AppStorage.isBiometricEnabled) {
      controller.verifyBiometric();
    }

    return Scaffold(
      body: Center(
        child: Obx(() {
          if (controller.isAuthenticated.value) {
            Future.delayed(Duration.zero, () {});
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(controller.statusMessage.value, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              // First Time → Enable button
              if (!AppStorage.isBiometricEnabled)
                ElevatedButton(
                  onPressed: controller.setupBiometric,
                  child: const Text("Enable Fingerprint Lock"),
                ),
              // Next Time → Verify button
              if (AppStorage.isBiometricEnabled)
                ElevatedButton(
                  onPressed: controller.verifyBiometric,
                  child: const Text("Unlock with Fingerprint"),
                ),
            ],
          );
        }),
      ),
    );
  }
}

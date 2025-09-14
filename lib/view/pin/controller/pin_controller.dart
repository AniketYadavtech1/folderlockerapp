import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

class PinController extends GetxController {
  final storage = const FlutterSecureStorage();
  final LocalAuthentication auth = LocalAuthentication();

  var pin = ''.obs;
  var isPinCreated = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkPin();
  }

  Future<void> checkPin() async {
    String? storedPin = await storage.read(key: 'user_pin');
    if (storedPin != null) {
      isPinCreated.value = true;
    }
  }

  // Save PIN
  Future<void> createPin(String newPin) async {
    await storage.write(key: 'user_pin', value: newPin);
    isPinCreated.value = true;
  }

  // Verify PIN
  Future<bool> verifyPin(String enteredPin) async {
    String? storedPin = await storage.read(key: 'user_pin');
    return storedPin == enteredPin;
  }
}

import 'package:get_storage/get_storage.dart';

class AppStorage {
  static final box = GetStorage();
  static bool get isBiometricEnabled => box.read("isBiometricEnabled") ?? false;
  static void setBiometricEnabled(bool value) => box.write("isBiometricEnabled", value);
}

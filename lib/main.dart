import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/folder/ui/folder_locker.dart';
import 'package:folderlockerapp/view/pin/controller/pin_controller.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller globally
    final PinController pinController = Get.put(PinController());

    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Folder Locker App',
        theme: ThemeData(primarySwatch: Colors.blue),
        // Decide initial screen dynamically
        home: LockedFoldersScreen()
        // Obx(() {
        //   if (pinController.isPinCreated.value) {
        //     return VerifyPinScreen(); // If PIN already set → verify screen
        //   } else {
        //     return CreatePinScreen(); // If no PIN → create PIN screen
        //   }
        // }),
        );
  }
}
